class AssetsController < ApplicationController
	# http_basic_authenticate_with name: "wallen", password: "beta2016autowriter"
	before_filter  :authenticate_user!
	
	#listing of all uploaded research photos
	def index
		@asests = current_user.is_admin? ? Asset.includes(:user).order("created_at desc") : Asset.includes(:user).where(created_by: current_user.id).order(:created_at)
	end
	
	#logic for uploading the photos
	def upload_asset
		asset = Asset.new(:file=>params[:asset][:file])
		asset.created_by = current_user.id
	    asset.save!
	    redirect_to assets_path
	end
	
	#Deleting existing photos
	def destroy
	  connection  = AWS::S3.new(access_key_id: S3_CREDENTIALS["access_key_id"], secret_access_key: S3_CREDENTIALS["secret_access_key"])    
      # file_obj = connection.buckets[S3_CREDENTIALS["bucket"]].objects[self.file_name]
      # file_obj.delete if file_obj.exists?
      folder_obj = connection.buckets[S3_CREDENTIALS["bucket"]].objects.with_prefix(params[:id])
      folder_obj.delete_all if folder_obj
      asset = Asset.find_by_id params[:id]
      asset.destroy
      redirect_to assets_path
	end
end
