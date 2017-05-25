class SendCampaignWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(options)
    gibbon = Gibbon::Request.new(api_key: options['api_key'])
    batch_status = 'pending'
    qery_interval = 0
    cnt = 0

    while batch_status != 'finished' || qery_interval == 3600
      cnt += 1
      p "##{cnt} - [#{Time.now}] - Retrying to query for batch result after #{qery_interval} seconds."
      res = gibbon.batches(options['batch_id']).retrieve
      batch_status = res['status']
      sleep 5
      qery_interval += 5
    end

    if qery_interval == 3600
      p 'Batch operation exceeded one hour. Exiting the operation and sending emails to available subscribers.'
    else
      p 'Batch operation completed. Progressing to send email.'
    end

    p 'Checking whether the campaign is ready to send or not.'
    begin
      res = gibbon.campaigns(options['campaign_id']).send_checklist.retrieve
      unless res['is_ready']
        p 'Campaign is not ready. Retrying after 10 seconds.'
        sleep 10
        raise 'Retry'
      end
      p 'Ready to send campaign.'
    rescue => ex
      retry
    end

    p 'Sending campaign.'
    begin
      gibbon.campaigns(options['campaign_id']).actions.send.create
      SaveEmailTemplateWorker.perform_async(options)
    rescue Gibbon::MailChimpError => ex
      p ex.message
      p 'Error occured while sending campaign. Retrying.'
      retry if ex.title.blank?
    end

    p 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  END XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

  end

end
