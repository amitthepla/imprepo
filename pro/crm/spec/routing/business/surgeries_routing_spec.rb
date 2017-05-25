require "rails_helper"

RSpec.describe Business::SurgeriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/business/surgeries").to route_to("business/surgeries#index")
    end

    it "routes to #new" do
      expect(:get => "/business/surgeries/new").to route_to("business/surgeries#new")
    end

    it "routes to #show" do
      expect(:get => "/business/surgeries/1").to route_to("business/surgeries#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/business/surgeries/1/edit").to route_to("business/surgeries#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/business/surgeries").to route_to("business/surgeries#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/business/surgeries/1").to route_to("business/surgeries#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/business/surgeries/1").to route_to("business/surgeries#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/business/surgeries/1").to route_to("business/surgeries#destroy", :id => "1")
    end

  end
end
