class Business::SourcesController < BusinessController
  before_filter :set_source, except: [:index, :new, :create]

  def index
    @sources = @current_org.sources.paginate(:page => params[:page])
    @new_source = @current_org.sources.new
    respond_to do |format|
      format.js
    end
  end

  def show
  end

  def create
    start_date = params[:business_source][:start_date].present? ? Date.strptime(params[:business_source][:start_date], '%m/%d/%Y') : nil
    end_date = params[:business_source][:end_date].present? ? Date.strptime(params[:business_source][:end_date], '%m/%d/%Y') : nil
    @source = Business::Source.new(source_params)
    @source.organization = @current_org
    @source.start_date = start_date
    @source.end_date = end_date
    respond_to do |format|
      if @source.save
        if params[:landing_page]
          @site = @current_org.sites.new({"name"=>params[:form_name],"url"=> params[:url],"landing_page"=> 'true', "source_id"=> @source.id})
          @site.save
        end
        @sources = @current_org.sources.paginate(:page => params[:page])
        @new_source = @current_org.sources.new
        format.js
      else
        @source_errors = @source.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @source.errors.any?
        format.js { render :file => "app/views/business/sources/source_error.js.erb" }
      end
    end
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    start_date = params[:business_source][:start_date].present? ? Date.strptime(params[:business_source][:start_date], '%m/%d/%Y') : nil
    end_date = params[:business_source][:end_date].present? ? Date.strptime(params[:business_source][:end_date], '%m/%d/%Y') : nil
    respond_to do |format|
      if @source.update_attributes(source_params)
        @source.update_attribute(:start_date, start_date)
        @source.update_attribute(:end_date, end_date)
        format.js
      else
        @source_errors = @source.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @source.errors.any?
        format.js { render :file => "app/views/business/sources/source_error.js.erb" }
      end
    end

  end

  def destroy
    @source_id = @source.id
    @source_name = @source.name.titleize
    @source.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def set_source
    @source = @current_org.sources.find(params[:id])
  end

  def source_params
    params.require(:business_source).permit(:name, :cost, :source_type, :category)
  end

end
