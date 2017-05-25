module Business
  class Site
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :organization, class_name: "Business::Organization"
    belongs_to :source, class_name: "Business::Source"

    field :name, type: String, default: nil
    field :url, type: String, default: nil
    field :site_id, type: String, default: nil
    field :landing_page, type: Boolean, default: false

    validates :name, presence: true, allow_blank: false
    validates :url, presence: true, allow_blank: false

    before_create :generate_token
    after_create :assign_org

	private

  	def generate_token
  		self.site_id = SecureRandom.uuid
  	end

    def assign_org
      org = self.organization
    end
  end
end
