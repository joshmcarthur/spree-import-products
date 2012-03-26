Spree::Core::Engine.routes.prepend do
    namespace :admin do
      resources :product_imports, :only => [:index, :new, :create]
    end
end
