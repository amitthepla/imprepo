module Business
  class Procedure
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: 'Business::Organization'
    belongs_to :procedure_mapping, :class_name => 'Business::ProcedureMapping'
    has_many :injection_procedures, :class_name => 'Business::InjectionProcedure'

    field :name,          type: String,   default: nil
    field :cost,          type: Integer,  default: nil
    field :details,       type: String,   default: nil
    field :slug_value,    type: String,   default: nil
    field :type,          type: String,   default: 'Body'
    field :procedure_for, type: String,   default: 'F'
    field :surgical,      type: Boolean,  default: false
    field :medspa,        type: Boolean,  default: false



    validates_presence_of :name, :cost, :details, :type, :procedure_for
    validates :cost, numericality: true
    before_save :set_slug_value

    def display_name
      self.name.titleize
    end

    protected
    def set_slug_value
      self.slug_value = self.name.parameterize.underscore
    end

  end
end
