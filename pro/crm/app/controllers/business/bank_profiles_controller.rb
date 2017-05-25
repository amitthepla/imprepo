class Business::BankProfilesController < BusinessController
  before_action :set_bank_profile, only: [:show, :edit, :update]
  skip_before_action :require_login, :set_user, :set_org, :get_unread_threads, only: [:profile_submission]
  def index
    @bank_profiles = @current_org.bank_profiles
  end

  def show
  end

  def new
    @bank_profile = @current_org.bank_profiles.new
  end

  def create
    @bank_profile = @current_org.bank_profiles.new(bank_profile_params)
    @bank_profile.score = JSON.parse(params[:score]).sort_by {|k,v| v}.reverse
    if @bank_profile.save
      redirect_to @bank_profile
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @bank_profile.update(bank_profiles)
      redirect_to @bank_profile
    else
      render :edit
    end
  end

  def profile_submission
    @score = JSON.parse(params[:business_bank_profile][:score]).sort_by {|k,v| v}.reverse.to_h
    params[:business_bank_profile][:score] = @score
    @bank_profile = Business::Organization.first.bank_profiles.new(bank_profile_params)
    @bank_profile.score = @score
    if @bank_profile.save
      redirect_to thank_you_path
    else
      render :new
    end    
  end

  private

  def set_bank_profile
    @bank_profile = @current_org.bank_profiles.find(params[:id])
  end

  def bank_profile_params
    params.require(:business_bank_profile).permit(:first_name,:last_name,:score,:referral,:email)
  end
end