module ImportProducts
  module UserMailerExt
    def self.included(base)
      base.class_eval do
        def product_import_results(user, error_message = nil)
          @user = user
          @error_message = error_message
          attachment["import_products.log"] = File.read(ImportProductSettings::LOGFILE) if @error_message.nil?
          mail(:to => @user.email, :subject => "Spree: Import Products #{error_message.nil? ? "Success" : "Failure"}")
        end     
      end
    end
  end
end
