module Business
  class InjectionProduct
    include Mongoid::Document

    belongs_to :organization, class_name: "Business::Organization", index: true

    field :hex_color, type: String
    field :product_name, type: String

  end
end
