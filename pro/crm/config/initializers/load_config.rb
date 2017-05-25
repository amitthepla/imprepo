# MANDRIL_CONFIG = YAML.load_file("#{Rails.root}/config/mandrill.yml")[Rails.env]
# MANDRILL_APIKEY= MANDRIL_CONFIG[:key]
# MANDRILL_USERNAME = MANDRIL_CONFIG[:email]
# MANDRILL_API_KEY = MANDRIL_CONFIG[:key]

# GROUPED_PROCEDURES = {
#                     'Buttock' => [['Buttock Augmentation (BBL)', 'bbl'],['Buttock Implant','butt-implant'],['Buttock Implant Removal','butt-implant'],['Buttock Implant Removal & Replacement','butt-implant'],['Buttock Lift','butt-lift'],['Silicon Injection Removal', 'silicone_injection_removal']],
#                     'Breast' => [['Standard Breast Augmentation', 'breast'],['TUBA Breast Augmentation', 'breast'],['Transaxillary Breast Augmentation', 'breast'],['Pectoral Implants (Male Chest Augmentation)', 'breast'],['Breast Lift', 'breast'],['Breast Reduction', 'breast-reconstruction']],
#                     'Body' => [['Tummy Tuck','tummy-tuck'],['Liposuction','liposuction'],['Arm Lift (Brachioplasty)','body'],['Inner Leg Lift','body'],['Calf Augmentation','body']],
#                     'Face' =>[['Face/Neck/Brow Lift','face'],['Chin Implant','face'],['Eye Lid Sx (Blepharoplasty)','face'],['Fat Transfer','face'],['Buccal Fat Pads (Cheeks) Removal','face'],['Nose Surgery (Rhinoplasty)','face'],['Ear Surgery (Otoplasty)','face'],['Ear Repair (ex: torn earlobe from piercing)','face']],
#                     'Injectables' => [['Botox','injectables'],['Juvederm','injectables'],['Juvederm Ultra Plus XE','injectables'],['Restaleyne','injectables']]

#                 }
GROUPED_PROCEDURES = {
                    "Buttock": [["Buttock Augmentation (BBL)", "bbl"],["Buttock Implant","butt-implant"],["Buttock Implant Removal","butt-implant"],["Buttock Implant Removal & Replacement","butt-implant"],["Buttock Lift","butt-lift"],["Silicon Injection Removal", "silicone_injection_removal"]],
                    "Breast": [["Standard Breast Augmentation", "breast"],["TUBA Breast Augmentation", "breast"],["Transaxillary Breast Augmentation", "breast"],["Pectoral Implants (Male Chest Augmentation)", "breast"],["Breast Lift", "breast"],["Breast Reduction", "breast-reconstruction"]],
                    "Body": [["Tummy Tuck","tummy-tuck"],["Liposuction","liposuction"],["Arm Lift (Brachioplasty)","body"],["Inner Leg Lift","body"],["Calf Augmentation","body"]],
                    "Face":[["Face/Neck/Brow Lift","face"],["Chin Implant","face"],["Eye Lid Sx (Blepharoplasty)","face"],["Fat Transfer","face"],["Buccal Fat Pads (Cheeks) Removal","face"],["Nose Surgery (Rhinoplasty)","face"],["Ear Surgery (Otoplasty)","face"],["Ear Repair (ex: torn earlobe from piercing)","face"]],
                    "Injectables": [["Botox","injectables"],["Juvederm","injectables"],["Juvederm Ultra Plus XE","injectables"],["Restaleyne","injectables"]]

                }
INTERESTED_PROCEDURES = [['Brazilian Butt Lift', 'bbl'], ['Breast Augmentation', 'breast'], ['Liposuction', 'lipo'], ['The Mendieta Technique', 'mendieta_technique'], ['The Mommy Makeover', 'mommy'], ['Other', 'other']]