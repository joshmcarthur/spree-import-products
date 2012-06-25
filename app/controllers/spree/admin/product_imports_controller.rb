module Spree
  module Admin
    class ProductImportsController < BaseController

      #Sorry for not using resource_controller railsdog - I wanted to, but then... I did it this way.
      #Verbosity is nice?
      #Feel free to refactor and submit a pull request.

      def index
        @product_import = Spree::ProductImport.new
      end

      def show
        @product_import = Spree::ProductImport.find(params[:id])
        @products = @product_import.products
      end

      def create
        @product_import = Spree::ProductImport.create(params[:product_import])
        Delayed::Job.enqueue ImportProducts::ImportJob.new(@product_import, @current_user)
        flash[:notice] = t('product_import_processing')
        redirect_to admin_product_imports_path
      end

      def destroy
        @product_import = Spree::ProductImport.find(params[:id])
        if @product_import.destroy
          flash[:notice] = t('delete_product_import_successful')
        end
        redirect_to admin_product_imports_path
      end
    end
  end
end
