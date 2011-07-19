class ImportProductsHooks < Spree::ThemeSupport::HookListener
  # custom hooks go here
  insert_after :admin_tabs do
   %(<%= tab(:product_imports) %>)
  end
end
