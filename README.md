Spree Import Products
==============

I've used this combination of model/controller/script to add product import functionality to a couple of projects now.
It's a fairly simple (but easy to extend), drop-in Spree extension that adds an interface to the Administration area
that allows a user to select and upload a CSV file containing information on products.

The script portion of this extension then reads the file, creating products with associated information, and
finding, attaching and saving images and taxonomies to the product object.

TODOs
==============
Adding some sort of support for running this under delayed_job is something that I think is probably reasonably
necessary for a routine like this, but not something I've had time to look into.

Apart from that, just testing really.

INSTALLATION
==============
1) Add the gem to your Gemfile, and run bundle install.
2) rake db:migrate
3) Run application - you may want to check out lib/import_products.rb for settings you can configure, as well as the
default column order.

Copyright (c) 2010 Josh McArthur, released under the MIT License
