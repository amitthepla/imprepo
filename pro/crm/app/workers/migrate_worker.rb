class MigrateWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(lead_id)
    if Business::Lead.where(id: lead_id).first.present?
      lead = Business::Lead.find_by(id: lead_id)

      return if lead.stage != 'inquiry' && lead.auto_communicate

      lead.update_attribute(:stage, "cold")
      lead.save
    end
  end

end
