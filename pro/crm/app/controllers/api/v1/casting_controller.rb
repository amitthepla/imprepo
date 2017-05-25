class Api::V1::CastingController < ApiController
def new
end

def create
	@current_org = Business::Site.where(site_id: params[:site_id]).first.organization
	if @current_org && params[:name].blank?
		@casting = @current_org.castings.find_or_create_by(email: params[:email].downcase.strip)
	      @casting.set({
	          first_name: params[:first_name].upcase.strip,
	          last_name: params[:last_name].upcase.strip,
	          phone: params[:phone],
	          gender: params[:gender],
	          casting_type: params[:casting_type],
			  story: params[:story],
	          preffered_language: params[:preffered_language]
	      })
	    if @casting.last_name.blank?
	    	@casting.last_name = 'None'
	    end

	    if @casting.save!
	    end
	else
		raise 404, 'Not Found'
	end
	respond_to do |format|
		format.html {redirect_to thank_you_path}
		format.json { render json: { :status => :ok, :message => "Story Sumbitted"} }
	end
end
end