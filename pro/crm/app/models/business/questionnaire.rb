module Business
  class Questionnaire
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :contact, class_name: "Business::Contact", index: true

    field :questionnaire_sent, type: Boolean, default: false
    field :questionnaire_filled, type: Boolean, default: false
    field :questionnaire_viewed, type: Boolean, default: false

    field :consultation_sent, type: Boolean, default: false
    field :consultation_filled, type: Boolean, default: false
    field :consultation_viewed, type: Boolean, default: false

    field :medications, type: String, default: nil
    field :medical_conditions, type: String, default: nil
    field :surgical_history, type: String, default: nil
    field :allergies, type: String, default: nil
    field :smoker, type: String, default: nil
    # field :recreational_drug_use, type: String, default: nil
    # field :alcholic_use, type: String, default: nil
    # field :caffine_use, type: String, default: nil
    # field :smoke_use, type: String, default: nil

    field :children, type: String, default: nil
    field :gravida, type: String, default: nil
    field :para, type: String, default: nil
    field :last_pregnancy_date, type: String, default: nil

    field :previous_cosmetics_procedure, type: String, default: nil
    field :previous_cosmetics_year, type: String, default: nil


    # field :last_mammogram, type: String, default: nil
    # field :history_of_breast_cancer, type: String, default: nil
    #
    # field :cardiologist_visit, type: String, default: nil
    # field :cardiologist_physician, type: String, default: nil
    # field :cardiologist_ekg, type: String, default: nil

    # field :anesthesia_history, type: String, default: nil

    field :financing, type: String, default: nil
    field :budget, type: Integer, default: 0

    field :planned_surgery_date, type: String, default: nil
    field :interest_level, type: String, default: nil
    field :motivation, type: String, default: nil
    field :expectations, type: String, default: nil
    field :extra_questions, type: String, default: nil

    field :appointment_timeframe, type: String, default: nil
    field :appointment_time_of_day, type: String, default: nil
    field :appointment_type, type: String, default: nil

    # field :silicone_injection_type, type: String, default: nil
    # field :silicone_injection_amount, type: String, default: nil
    # field :silicone_injection_date, type: String, default: nil
    # field :silicone_injection_qty, type: String, default: nil
    # field :silicone_injection_problem_start, type: String, default: nil
    # field :silicone_injection_problem_years, type: String, default: nil
    # field :silicone_injection_treament, type: String, default: nil
    # field :silicone_injection_symptoms, type: String, default: nil

   end
end
