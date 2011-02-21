Spree Import Products
==============

I've used this combination of model/controller/script to add product import functionality to a couple of projects now.
It's a fairly simple (but easy to extend), drop-in Spree extension that adds an interface to the Administration area
that allows a user to select and upload a CSV file containing information on products.

The script portion of this extension then reads the file, creating products with associated information, and
finding, attaching and saving images and taxonomies to the product object.


FEATURES
==============

* A reasonably opinionated product import model should take the heavy lifting out of batch-importing products.
* Using things like `class_eval`, it can be extended or changed to do more, less, or something differently.
* It now uses DELAYED JOB after I faced some 10-15min page loads. Now the user is emailed after the import
completes with details of the import, as well as specific details if something went wrong.
* It now uses the Ruby 1.9.2 standard CSV library (a.k.a FasterCSV).


DELAYED JOB
==============
This gem will require (or will install for you), [delayed_job](https://www.github.com/tobi/delayed_job).
Once the gem has installed and you have run migrations, you should also run `rails generator delayed_job_migrations` to create the tables that delayed_job requires.

Delayed Job also requires that you run 'workers' in the background to pop jobs off the queue and process them.
This setup may seem like extra work, but believe me, it pays off - with this method, users get an immediate confirmation that their import is on it's way, with a confirmation later on with full details - this is much better than the previous method where the actual processing was completed during the request, with no feedback reaching the user until after the import had finished.

For more information on Delayed Job, and for help getting a worker running, see the [Github Project Page](https://www.github.com/tobi/delayed_job)


TODOs
==============
Ttttteeeessssttttiiinnnggg!!

INSTALLATION
==============
1. Add the gem to your Gemfile, and run bundle install.
    gem 'import_products, :git => 'git://github.com/joshmcarthur/spree-import-products.git'
    bundle install
2. 'Install' the extension - copy a migration and an initializer
    rake import_products:install
3. rake db:migrate
4. Configure the extension to suit your application by changing config variables in config/initializers/import_product_settings.rb
5. Run application!

ATTRIBUTION
==============
The product import script was based on a simple import script written by Brian Quinn [here](https://gist.github.com/31710). I've extended it and tweaked it to fit my needs.

Copyright (c) 2010 Josh McArthur, released under the MIT License
