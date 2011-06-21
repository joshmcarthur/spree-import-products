Spree Import Products
==============

This extension adds product import functionality to Spree, with a bunch of features that give it similar functionality to Shopify's importer.

It's been built to be as simple as possible while still doing it's job, and almost the entire workflow of the script beyond creating products from a CSV file is configurable.

This extension adds a tab to the administration area of Spree, allowing a logged-in user to select and upload a CSV file containing product information. The upload is then placed on queue for processing. Once it has been processed, the user who initiated the job is notified by email that their import has completed.


FEATURES
==============

* A reasonably opinionated product import model should take the heavy lifting out of batch-importing products.
* Using things like `class_eval`, it can be extended or changed to do more, less, or something differently.
* Using delayed_job, the import is no longer processed when the user uploads the CSV file (**Note**: this requires the proper installation and configuration of delayed job). 
* Columns are mapped dynamically by default. This means that if you have a SKU column in your CSV file, it will be automatically set as the `sku` attribute of the Product model.
* Multiple taxonomies are supported (By default, the importer looks for Brand and Taxonomy). Multiple taxonomy nesting is also supported. (See the 'Taxonomies' area below)
* Multiple images are supported (By default, the importer looks for Image Main, Image 2, Image 3 and Image 4). Images can be loaded either from disk, or from a publicly-accessible URL.
* Automatically creating variants is supported out-of-the-box - the importer compares the imported data with already-created products (By default, on the Product's `permalink` attribute), and creates a variant of that product if it exists already. Custom fields are also supported if dynamic column mapping is enabled - simply having 'Color', 'Size', 'Material' columns in your CSV file for example, will automatically set the relevant custom fields on the variant to the values from the CSV.
* It now uses the Ruby 1.9.2 standard CSV library (a.k.a FasterCSV).


DELAYED JOB
==============
This gem will require (or will install for you), [delayed_job](https://www.github.com/tobi/delayed_job).
Once the gem has installed and you have run migrations, you should also run `rails generator delayed_job` to create the tables that delayed_job requires.

Delayed Job also requires that you run 'workers' in the background to pop jobs off the queue and process them.
This setup may seem like extra work, but believe me, it pays off - with this method, users get an immediate confirmation that their import is on it's way, with a confirmation later on with full details - this is much better than the previous method where the actual processing was completed during the request, with no feedback reaching the user until after the import had finished.

Run `rake jobs:work` to start Delayed Job, and `rake jobs:clear` to clear all queued jobs. Also see delayed_job's Githut page for info on Capistrano support.

For more information on Delayed Job, and for help getting a worker running, see the [Github Project Page](https://www.github.com/tobi/delayed_job)

TAXONOMIES
==========

The columns of the CSV that contain taxonomies is configurable. Each of these columns can contain a number of formats that represent different hierarchies of taxonomies.

Examples
--------
* Basic taxonomy association for Category: `Furniture`
* Multiple taxonomy association for Category: `Furniture & Clearance`
* Hierarchy taxonomy association for Category: `Furniture > Dining Room > Tables`
* Multiple hierarchy taxonomy association for Category: `Furniture > Dining Room > Tables & Clearance > Hot this week`

CONFIGURATION
=============

All the configuration for this extension is inside the initializer generated when you run `rake import_products:install`. It's basically a big hash with manual column mappings (If you don't want to use dynamic column mapping), and a bunch of settings that control the workflow of the extension. Take a look at the initializer to see more details on each field.

In most cases, it's unlikely you will need to change defaults, but it's there is you need it.


TODOs
==============
Ttttteeeessssttttiiinnnggg!!

INSTALLATION
==============
1. Add the gem to your Gemfile, and run bundle install.
    `gem 'import_products', :git => 'git://github.com/joshmcarthur/spree-import-products.git'` then `bundle install`

2. 'Install' the extension - copy a migration and an initializer. `rake import_products:install`

3. Do a db migration. `rake db:migrate`

4. Configure the extension to suit your application by changing config variables in `config/initializers/import_product_settings.rb`

5. Run application!

ATTRIBUTION
==============
The product import script was based on a simple import script written by Brian Quinn [here](https://gist.github.com/31710). I've extended it quite a bit and tweaked it to fit my needs.

Copyright (c) 2010 Josh McArthur, released under the MIT License
