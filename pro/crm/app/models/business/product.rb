module Business
  class Product
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"
  end
end