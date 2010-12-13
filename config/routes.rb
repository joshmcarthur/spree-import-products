Rails.application.routes.draw do
    namespace :admin do
      resources :product_import, :only => [:index, :new, :create]
    end
end
