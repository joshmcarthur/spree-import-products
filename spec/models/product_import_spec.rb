require 'spec_helper'

module Spree
  describe ProductImport do
    describe "#create_variant_for" do
      before do
        product; size; color; option_color; option_size
      end

      let(:product) { Factory(:product, :sku => "001", :permalink => "S0388G-bloch-kids-tap-flexewe") }
      let(:size) { Factory(:option_type, :name => "tshirt-size") }
      let(:color) { Factory(:option_type, :name => "tshirt-color", :presentation => "Color") }
      let(:option_color) { Factory(:option_value, :name => "blue", :presentation => "Blue", :option_type => color) }
      let(:option_size) { Factory(:option_value, :name => "s", :presentation => "Small", :option_type => size) }

      let(:params) do
        {:sku=>"002", :name=>"S0388G Bloch Kids Tap Flexww", :description=>"Lace Up Split Sole Leather Tap Shoe",
          :cost_price=>"29.25", :master_price=>"54.46", :available_on=>"1/1/10", :"tshirt-color"=>"Blue", :"tshirt-size"=>"Small",
          :on_hand=>"2", :height=>"3", :width=>"4", :depth=>"9", :weight=>"1", :position=>"0", :category=>"Categories >
          Clothing", :permalink=>"S0388G-bloch-kids-tap-flexewe"
        }
      end

      it "creates a new variant when product already exist" do
        product.variants_with_only_master.count.should == 1
        expect do
          ProductImport.new.send(:create_variant_for, product, :with => params)
        end.to change(product.variants, :count).by(1)
        product.variants_with_only_master.count.should == 1
        variant = product.variants.last
        variant.price.to_f.should == 54.46
        variant.cost_price.to_f.should == 29.25
        product.option_types.should =~ [size, color]
        variant.option_values.should =~ [option_size, option_color]
      end

      it "creates missing option_values for new variant" do
        ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
        variant = product.variants.last
        product.option_types.should =~ [size, color]
        variant.option_values.should =~ Spree::OptionValue.where(:name => %w(Large Yellow))
      end

      it "should not duplicate option_values for existing variant" do
        expect do
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
        end.to change(product.variants, :count).by(1)
        variant = product.variants.last
        product.option_types.should =~ [size, color]
        variant.option_values.reload.should =~ Spree::OptionValue.where(:name => %w(Large Yellow))
      end

      it "throws an exception when variant with sku exist for another product" do
        other_product = Factory(:product, :sku => "002")
        expect do
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
        end.to raise_error(SkuError)
      end
    end

    describe "#import_data!" do
      let(:valid_import) { ProductImport.create :data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'valid.csv')) }
      let(:invalid_import) { ProductImport.create :data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'invalid.csv')) }

      it "create products successfully with valid csv" do
        expect { valid_import.import_data! }.to change(Spree::Product, :count).by(1)
        Spree::Product.last.variants.count.should == 2
      end

      it "tracks product created ids" do
        valid_import.import_data!
        valid_import.reload
        valid_import.product_ids.should == [Spree::Product.last.id]
        valid_import.products.should == [Spree::Product.last]
      end

      it "rollback transation on invalid csv and params = true (transaction)" do
        expect { invalid_import.import_data! }.to raise_error(ImportError)
        Spree::Product.count.should == 0
      end

      it "sql are permanent on invalid csv and params = false (no transaction)" do
        expect { invalid_import.import_data!(false) }.to raise_error(ImportError)
        Spree::Product.count.should == 1
      end

      it "handles product properties" do
        Spree::Property.create :name => "brand", :presentation => "Brand"
        expect { @import = ProductImport.create(:data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'products_with_properties.csv'))).import_data!(true) }.to change(Spree::Product, :count).by(1)
        (product = Spree::Product.last).product_properties.map(&:value).should == ["Rails"]
        product.variants.count.should == 2
      end
    end

    describe "#destroy_products" do
      it "should also destroy associations" do
        expect { (@import = ProductImport.create(:data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'products_with_properties.csv')))).import_data!(true) }.to change(Spree::Product, :count).by(1)
        @import.destroy
        Spree::Variant.count.should == 0
      end
    end
  end
end