class AddStateFailedAtAndCompletedAtToProductImports < ActiveRecord::Migration
  def change
    add_column :spree_product_imports, :state, :string
    add_column :spree_product_imports, :failed_at, :datetime
    add_column :spree_product_imports, :completed_at, :datetime
  end
end