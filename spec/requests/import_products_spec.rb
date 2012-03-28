require 'spec_helper'

feature "Import products" do
  background do
    sign_in_as! Factory(:admin_user)
  end

  scenario "admin should be able to import products and delete import" do
    visit spree.admin_product_imports_path
    attach_file("product_import_data_file", File.join(File.dirname(__FILE__), '..', 'fixtures', 'valid.csv'))
    click_button "Create"

    page.should have_content("valid.csv")
    page.should have_content("Created")

    Delayed::Worker.new.work_off

    # should have created the product
    visit spree.admin_products_path
    page.should have_content("Bloch Kids Tap Flexww")

    visit spree.admin_product_imports_path
    page.should have_content("valid.csv")
    page.should have_content("Completed")

    click_link "Show"
    page.should have_content("Bloch Kids Tap Flexww")

    click_button "Delete"
    page.should have_content("Import and products associated deleted successfully")
    page.should_not have_content("valid.csv")

    # should have deleted product created by import
    visit spree.admin_products_path
    page.should_not have_content("Bloch Kids Tap Flexww")
  end

end