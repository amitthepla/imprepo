class Api::V1::ProceduresController < ApiController
	def index
		@current_org = Business::Site.where(site_id: params[:site_id]).first.organization
		@procedures = @current_org.procedures
		respond_to do |format|
			format.json { render json: { :procedures => @procedures ,:status => :ok, :message => "Lead Sumbitted"} }
		end
	end

end
