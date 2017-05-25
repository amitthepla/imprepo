module Business::SurgeriesHelper
  def get_name( user)
    if user.present?
      user.full_name
    end
  end
end
