class RenameProductImportsTableToSpreeProductImports < ActiveRecord::Migration
  def change
    rename_table :product_imports, :spree_product_imports
	end
end
