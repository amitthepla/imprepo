class Business::SitesController < BusinessController
  before_filter :set_site, except: [:index, :new, :create, :generate_html_form]
  def index
    @sites = @current_org.sites.paginate(:page => params[:page])
    respond_to do |format|
      format.js
    end
  end

  def show
  end


  def update
    respond_to do |format|
      if @site.update_attributes(site_params)
        @sites = @current_org.sites.paginate(:page => params[:page])
        format.js
      else
        @site_errors = @site.errors.full_messages.map(&:inspect).join(', ').gsub!('"', '').humanize if @site.errors.any?
        format.js { render :file => "app/views/business/sites/site_error.js.erb" }
      end
    end
  end

  def destroy
    @site_id = @site.id
    @site_name = @site.name.titleize
    @site.destroy
    respond_to do |format|
      format.js
    end
  end

  def generate_html_form
    form_content = File.read(File.join(Rails.root, 'html_form.html'))
    doc = Nokogiri::HTML(form_content)
    doc.at_xpath("//input[@id='site_id']")['value'] = params[:site_id]
    content = doc.at('body').children
    render inline: content.to_s
  end

  private

  def set_site
    @site = @current_org.sites.find(params[:id])
  end

  def site_params
    params.require(:business_site).permit(:name, :url, :landing_page, :source_id)
  end
end
