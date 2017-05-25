namespace :crm do
  desc "Inserting the default procedures"
  task insert_default_procedures: :environment do
  	@current_org = Business::Organization.first
    [['bbl', 'Buttock Augmentation (BBL)'], ['silicone_injection_removal', 'Silicon Injection Removal'], ['breast', 'Breast Augmentation'], ['lipo', 'Liposuction'], ['mendieta_technique', 'The Mendieta Technique'], ['mommy', 'The Mommy Makeover'], ['other', 'Other'], ['butt_implant', 'Buttock Implant'], ['butt_lift', 'Buttock Implant'], ['breast_reconstruction', 'Breast Reduction'], ['tummy_tuck', 'Tummy Tuck'], ['body', 'Body Procedure'], ['face', 'Face Procedure'], ['injectables', 'Injectables']].each do |p|
        
        unless @current_org.procedures.where(slug_value: p.first).first.present?
          puts "creating #{p.last}"
          p @current_org.procedures.create( :slug_value => p.first, :name=>p.last)
        end
      end
  end
end
