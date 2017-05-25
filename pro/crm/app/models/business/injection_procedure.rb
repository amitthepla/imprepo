module Business
  class InjectionProcedure
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :procedure, :class_name => 'Business::Procedure'
    belongs_to :treatment, :class_name => 'Business::Treatment'

    field :coordinates, type: Array
    field :quantity, type: Integer
    field :measurement, type: String
    field :product_id, type: String

    def product_name
      Business::InjectionProduct.find(self.product_id).product_name
    end

    validates :coordinates, presence: true, allow_blank: false
  end
end
