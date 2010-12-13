namespace :import_products do
  desc "Copies all migrations and assets (NOTE: This will be obsolete with Rails 3.1)"
  task :install do
    Rake::Task['import_products:install:migrations'].invoke
    Rake::Task['import_products:install:assets'].invoke
    Rake::Task['import_products:install:config'].invoke
  end

  namespace :install do
    desc "Copies all migrations (NOTE: This will be obsolete with Rails 3.1)"
    task :migrations do
      source = File.join(File.dirname(__FILE__), '..', '..', 'db')
      destination = File.join(Rails.root, 'db')
      puts "INFO: Mirroring assets from #{source} to #{destination}"
      Spree::FileUtilz.mirror_files(source, destination)
    end
    
    desc "Copies import products config (NOTE: I don't know what this will do in Rails 3.1)"
    task :config do
      source = File.join(File.dirname(__FILE__), '..', '..', 'config', 'initializers', 'import_product_settings.rb')
      destination = File.join(Rails.root, 'config', 'initializers', 'import_product_settings.rb')
      puts "INFO: Mirroring assets from #{source} to #{destination}"
      Spree::FileUtilz.mirror_files(source, destination)
    end

    desc "Copies all assets (NOTE: This will be obsolete with Rails 3.1)"
    task :assets do
      source = File.join(File.dirname(__FILE__), '..', '..', 'public')
      destination = File.join(Rails.root, 'public')
      puts "INFO: Mirroring assets from #{source} to #{destination}"
      Spree::FileUtilz.mirror_files(source, destination)
    end
  end

end
