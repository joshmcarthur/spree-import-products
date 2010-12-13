# This model is the master routine for uploading products
# Requires Paperclip and FasterCSV to upload the CSV file and read it nicely.

# Author:: Josh McArthur
# License:: MIT

class ProductImport < ActiveRecord::Base
  has_attached_file :data_file, :path => ":rails_root/lib/etc/product_data/data-files/:basename.:extension"
  validates_attachment_presence :data_file
  
  require 'fastercsv'
  require 'pp'
  
  ## Data Importing:
  # Supplier, room and category are all taxonomies to be found (or created) and associated
  # Model maps to product name, description, brochure text and bullets 1 - 8 are combined to form description
  # List Price maps to Master Price, Current MAP to Cost Price, Net 30 Cost unused
  # Width, height, Depth all map directly to object
  # Image main is created independtly, then each other image also created and associated with the product
  # Meta keywords and description are created on the product model
  
  def import_data
    begin
      #Get products *before* import - 
      @products_before_import = Product.all

      
      rows = FasterCSV.read(self.data_file.path)
      log("Importing products for #{self.data_file_file_name} began at #{Time.now}")
      rows[INITIAL_ROWS_TO_SKIP..-1].each do |row|
        product_information = {}
        
        #Easy ones first
        product_information[:sku] = row[COLUMN_MAPPINGS['SKU']]
        product_information[:name] = row[COLUMN_MAPPINGS['Name']]
        product_information[:price] = row[COLUMN_MAPPINGS['Master Price']]
        product_information[:cost_price] = row[COLUMN_MAPPINGS['Cost Price']]
        product_information[:available_on] = DateTime.now - 1.day #Yesterday to make SURE it shows up
        product_information[:weight] = row[COLUMN_MAPPINGS['Weight']]
        product_information[:height] = row[COLUMN_MAPPINGS['Height']]
        product_information[:depth] = row[COLUMN_MAPPINGS['Depth']]
        product_information[:width] = row[COLUMN_MAPPINGS['Width']]
        product_information[:description] = COLUMN_MAPPINGS['Description']
        

        #Create the product skeleton - should be valid
        product_obj = Product.new(product_information)
        unless product_obj.valid?
          log("A product could not be imported - here is the information we have:\n #{ pp product_information}", :error)
          next
        end
        
        #Save the object before creating asssociated objects
        product_obj.save

        #Now we have all but images and taxons loaded
        associate_taxon('Category', row[COLUMN_MAPPINGS['Category']], product_obj)
        
        #Just images 
        find_and_attach_image(row[COLUMN_MAPPINGS['Image Main']], product_obj)
        find_and_attach_image(row[COLUMN_MAPPINGS['Image 2']], product_obj)
        find_and_attach_image(row[COLUMN_MAPPINGS['Image 3']], product_obj)
        find_and_attach_image(row[COLUMN_MAPPINGS['Image 4']], product_obj)

        #Return a success message
        log("#{product_obj.name} successfully imported.\n")
      end
      
      if DESTROY_ORIGINAL_PRODUCTS_AFTER_IMPORT
        @products_before_import.each { |p| p.destroy }
      end
      
      log("Importing products for #{self.data_file_file_name} completed at #{DateTime.now}")
      
    rescue Exception => exp
      log("An error occurred during import, please check file and try again. (#{exp.message})\n#{exp.backtrace.join('\n')}", :error)
      return [:error, "The file data could not be imported. Please check that the spreadsheet is a CSV file, and is correctly formatted."]
    end
    
    #All done!
    return [:notice, "Product data was successfully imported."]
  end
  
  
  private 
  
  ### MISC HELPERS ####
  
  #Log a message to a file - logs in standard Rails format to logfile set up in the import_products initializer
  #and console.
  #Message is string, severity symbol - either :info, :warn or :error
  
  def log(message, severity = :info)   
    @rake_log ||= ActiveSupport::BufferedLogger.new(LOGFILE)
    message = "[#{Time.now.to_s(:db)}] [#{severity.to_s.capitalize}] #{message}\n"
    @rake_log.send severity, message
    puts message
  end

  
  ### IMAGE HELPERS ###
  
  ## find_and_attach_image
  #   The theory behind this method is:
  #     - We know where an 'image dump' of high-res images is - could be remote folder, or local
  #     - We know that the provided filename SHOULD be in this folder
  def find_and_attach_image(filename, product)
    #Does the file exist? Can we read it?
    return if filename.blank?
    filename = PRODUCT_IMAGE_PATH + filename
    unless File.exists?(filename) && File.readable?(filename)
      log("Image #{filename} was not found on the server, so this image was not imported.", :warn)
      return nil
    end
    
    #An image has an attachment (duh) and some object which 'views' it
    product_image = Image.new({:attachment => File.open(filename, 'rb'), 
                              :viewable => product,
                              :position => product.images.length
                              }) 
    
    product.images << product_image if product_image.save
  end

  
  
  ### TAXON HELPERS ###  
  def associate_taxon(taxonomy_name, taxon_name, product)
    master_taxon = Taxonomy.find_by_name(taxonomy_name)
    
    if master_taxon.nil?
      master_taxon = Taxonomy.create(:name => taxonomy_name)
      log("Could not find Category taxonomy, so it was created.", :warn)
    end
    
    taxon = Taxon.find_or_create_by_name_and_parent_id_and_taxonomy_id(
      taxon_name, 
      master_taxon.root.id, 
      master_taxon.id
    )
    
    product.taxons << taxon if taxon.save
  end

  
  ### END TAXON HELPERS ###
end
