class Task
  include Sidekiq::Worker
  def perform(name, count)
  	pending_leads = Business::Lead.where(stage: 'pending')
  end
end