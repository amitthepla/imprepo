class Business::Source
  include Mongoid::Document
  include Mongoid::Timestamps

  CAT = ["Ad Words", "RealSelf", "Twitter", "Facebook", "Snapchat", "Instagram",  "Website", "Magazine", "Newspaper", "Billboard", "Bus Bench", "other"]

  field :name, type: String
  field :start_date, type: Date, default: nil
  field :end_date, type: Date, default: nil
  field :cost, type: Integer, default: 0
  field :category, type: String
  field :type_slug, type: String, default: "internet"

  belongs_to :source_type, :class_name => 'SourceType'
  belongs_to :organization, :class_name => 'Business::Organization'
  has_many :leads, :class_name => 'Business::Lead'
  has_many :surgeries, :class_name => 'Business::Surgery'
  has_many :consults, :class_name => 'Business::Consultation'
  has_one :site, :class_name => 'Business::Site'

  validates :name, presence: true, allow_blank: false
  after_create :set_type_slug

  def set_type_slug
    self.type_slug = self.source_type.name
  end

  def self.pick_from_active_sources
    self.any_of({:start_date.lte => Date.today, :end_date.gte => Date.today}, {:start_date => nil, :end_date => nil})
  end

  def self.active
    self.where(:end_date.gte => Date.today.end_of_month)
  end

  def name_and_date
    "#{self.name} - #{self.ending_date || 'Perpetual'}"
  end

  def ending_date
    self.end_date.strftime('%D') if self.end_date
  end

  def booked_consults
    self.consults.count
  end

  def consult_revenue
    self.consults.sum(&:cost)
  end

  def booked_surgeries
    self.surgeries.count
  end

  def surgery_revenue
    self.surgeries.sum(&:cost)
  end

  def cached_name
    Rails.cache.fetch([self, "source_name"]) do
      self.name
    end
  end

  def cached_cost
    Rails.cache.fetch([self, "source_cost"]) do
      self.cost||0
    end
  end

end
