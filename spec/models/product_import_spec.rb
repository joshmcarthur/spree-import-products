require 'spec_helper'

module Spree
  describe ProductImport do
    describe "#create_variant_for" do
      before do
        product; size; color; option_color; option_size
      end

      let(:product) { FactoryGirl.create(:product, :sku => "001", :permalink => "S0388G-bloch-kids-tap-flexewe") }
      let(:size) { FactoryGirl.create(:option_type, :name => "tshirt-size") }
      let(:color) { FactoryGirl.create(:option_type, :name => "tshirt-color", :presentation => "Color") }
      let(:option_color) { FactoryGirl.create(:option_value, :name => "blue", :presentation => "Blue", :option_type => color) }
      let(:option_size) { FactoryGirl.create(:option_value, :name => "s", :presentation => "Small", :option_type => size) }

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
        variant.option_values.should =~ OptionValue.where(:name => %w(Large Yellow))
      end

      it "should not duplicate option_values for existing variant" do
        expect do
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
        end.to change(product.variants, :count).by(1)
        variant = product.variants.last
        product.option_types.should =~ [size, color]
        variant.option_values.reload.should =~ OptionValue.where(:name => %w(Large Yellow))
      end

      it "throws an exception when variant with sku exist for another product" do
        other_product = FactoryGirl.create(:product, :sku => "002")
        expect do
          ProductImport.new.send(:create_variant_for, product, :with => params.merge(:"tshirt-size" => "Large", :"tshirt-color" => "Yellow"))
        end.to raise_error(SkuError)
      end
    end

    describe "#import_data!" do
      let(:valid_import) { ProductImport.create :data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'valid.csv')) }
      let(:invalid_import) { ProductImport.create :data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'invalid.csv')) }

      context "on valid csv" do
        it "create products successfully" do
          expect { valid_import.import_data! }.to change(Product, :count).by(1)
          Product.last.variants.count.should == 2
        end

        it "tracks product created ids" do
          valid_import.import_data!
          valid_import.reload
          valid_import.product_ids.should == [Product.last.id]
          valid_import.products.should == [Product.last]
        end

        it "handles product properties" do
          Property.create :name => "brand", :presentation => "Brand"
          expect { @import = ProductImport.create(:data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'products_with_properties.csv'))).import_data!(true) }.to change(Product, :count).by(1)
          (product = Product.last).product_properties.map(&:value).should == ["Rails"]
          product.variants.count.should == 2
        end

        it "sets state to completed" do
          valid_import.import_data!
          valid_import.reload.state.should == "completed"
        end
      end

      context "on invalid csv" do
        it "should not tracks product created ids" do
          expect { invalid_import.import_data! }.to raise_error(ImportError)
          invalid_import.reload
          invalid_import.product_ids.should be_empty
          invalid_import.products.should be_empty
        end

        context "when params = true (transaction)" do
          it "rollback transation" do
            expect { invalid_import.import_data! }.to raise_error(ImportError)
            Product.count.should == 0
          end

          it "sets state to failed" do
            expect { invalid_import.import_data! }.to raise_error(ImportError)
            invalid_import.reload.state.should == "failed"
          end
        end

        context "when params = false (no transaction)" do
          it "sql are permanent" do
            expect { invalid_import.import_data!(false) }.to raise_error(ImportError)
            Product.count.should == 1
          end

          it "sets state to failed" do
            expect { invalid_import.import_data!(false) }.to raise_error(ImportError)
            invalid_import.reload.state.should == "failed"
          end
        end
      end
    end

    describe "#destroy_products" do
      it "should also destroy associations" do
        expect { (@import = ProductImport.create(:data_file => File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'products_with_properties.csv')))).import_data!(true) }.to change(Product, :count).by(1)
        @import.destroy
        Variant.count.should == 0
      end
    end
  end
end
