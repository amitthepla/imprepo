class FeaturesMailer < ActionMailer::Base
  default from: "WakeUpSales <no-reply@wakeupsales.com>"

  def send_product_update(to,subject)
  	@email = to
  	mail(to: to, subject: subject)
  end
end
