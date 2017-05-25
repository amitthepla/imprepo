class Business::InjectionProductsController < BusinessController


  def create
    @product = @current_org.injection_products.new(product_params)
    @product.save

    redirect_to business_settings_path
  end


  private
   def product_params
    params.require(:business_injection_product).permit(:product_name,:hex_color)
   end
end
