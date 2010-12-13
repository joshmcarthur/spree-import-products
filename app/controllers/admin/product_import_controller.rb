class Admin::ProductImportController < Admin::BaseController
  
  #Sorry for not using resource_controller railsdog - I wanted to, but then... I did it this way.
  #Verbosity is nice?
  #Feel free to refactor and submit a pull request.
  
  def index
    redirect_to :action => :new
  end
  
  def new
    @product_import = ProductImport.new
  end
  
  
  def create
    @product_import = ProductImport.create(params[:product_import])
    #import_data returns an array with two elements - a symbol (notice or error), and a message
    import_results = @product_import.import_data
    flash[import_results[0]] = import_results[1]
    render :new
  end
end
