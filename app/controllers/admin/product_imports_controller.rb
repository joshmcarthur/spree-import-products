class Admin::ProductImportsController < Admin::BaseController

  #Sorry for not using resource_controller railsdog - I wanted to, but then... I did it this way.
  #Verbosity is nice?
  #Feel free to refactor and submit a pull request.

  def index
    redirect_to :action => :new
  end

  def new
    @product_import = ProductImport.new
  end


  def create
    @product_import = ProductImport.create(params[:product_import])
    Delayed::Job.enqueue ImportProducts::ImportJob.new(@product_import, @current_user)
    flash[:notice] = t('product_import_processing')
    redirect_to admin_product_imports_path
  end
end
