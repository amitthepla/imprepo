class SourceType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String

  has_many :sources, :class_name => 'Business::Source'

  validates :name, presence: true, allow_blank: false
  validates_uniqueness_of :name, :case_sensitive => false

  scope :by_name, -> (source_type) { where({name: source_type}) }

end
