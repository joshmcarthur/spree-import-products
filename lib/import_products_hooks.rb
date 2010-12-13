class ImportProductsHooks < Spree::ThemeSupport::HookListener
  # custom hooks go here
  insert_after :admin_tabs do
   %(<%= tab(:product_import_index) %>)
  end
end
