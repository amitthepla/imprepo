require 'csv'
class ContentsController < ApplicationController
  include ContentsHelper
  include PHPClient
  # http_basic_authenticate_with name: "wallen", password: "ai@2016!"
  before_filter :authenticate_user!

  layout false, :only => :download

  # Fetch all the projects based on the api key
  def index
    @projects = Wordsmith::Project.all
    if params[:content].present?
      @contents = Content.where('id IN (?)', params[:records])
    end
  end

  # Fetch respective template that has been created under a project
  def fetch_templates
    @project = Wordsmith::Project.find params[:slug] if params[:slug].present?
    @templates = @project.templates.all if @project.present?
    render :partial => 'templates'
  end

  # Upload and generate content from wordsmith API
  def upload_file
    begin
      @records = []
      # Following code has been commented by Sambit Mohanty on Nov 1, 2016 to read data from excel instead of CSV.
      # OLD CODE BLOCK
      # trow = 0
      # CSV.foreach(params[:file].path, headers: true, encoding: 'iso-8859-1:utf-8') do |row|
      #   break if trow == 1
      #   project = Wordsmith::Project.find(params[:project_slug])
      #   @template = project.templates.find(params[:template_slug])
      #   data = {}
      #   if row.headers.length == row.fields.length
      #     (0..row.headers.length-1).each do |i|
      #       data[row.headers[i]] = row.fields[i]
      #     end
      #   else
      #     raise 'Heades count does not match the fields count'
      #   end
      #   generate_data = @template.generate(data)
      #   content = Content.new({
      #                             :content => generate_data[:content],
      #                             :created_by => current_user.id,
      #                             :is_ppt => params[:template_slug].downcase.include?('ppt'),
      #                             attachment: params[:file]
      #                         })
      #   content.save
      #   PHPClient.fetch_image_urls('http://192.168.2.199/excel_parsing/', content)
      #   @records << content.id
      #   p trow == 1
      #   trow = trow + 1
      # end
      # OLD CODE BLOCK END

      # Following new code has been added to read from excel sheet
      #
      # NEW CODE BLOCK BEGIN
      #
      xlsx = Roo::Spreadsheet.open(params[:file].path, extension: :xlsx)
      sheet = xlsx.sheet('CONTROL TAB') rescue nil
      raise "Sheet 'CONTROL TAB' is not found in the uploaded excel sheet." if sheet.nil?

      project = Wordsmith::Project.find(params[:project_slug])
      @template = project.templates.find(params[:template_slug])

      data = {}
      if sheet.row(1).length == sheet.row(2).length
        (0...sheet.row(1).length).each do |i|
          data[sheet.row(1)[i]] = sheet.row(2)[i]
        end
      else
        raise 'Heades count does not match the fields count'
      end

      generate_data = @template.generate(data)
      content = Content.new({
                                :content => generate_data[:content],
                                :created_by => current_user.id,
                                :is_ppt => params[:template_slug].downcase.include?('ppt'),
                                attachment: params[:file]
                            })
      content.save
      PHPClient.fetch_image_urls(ENV['PHP_API_URL'], content)
      @records << content.id
      #
      # NEW CODE BLOCK END

      flash[:success] = 'Successfully uploaded.'
      redirect_to authenticated_path(:content => 'true', :records => @records)
    rescue => e
      err_msg = (e.class == Zip::Error) ? 'Invalid file format. Please upload a valid Excel(.xlsx) file.' : e.message
      flash[:error] = err_msg
      redirect_to '/'
    end
  end

  def download
    @contents = Content.where('id IN (?)', params[:records].split(','))
    respond_to do |format|
      format.html #redirect_to root_path
      format.docx { headers['Content-Disposition'] = "attachment; filename=\"content-#{Time.zone.now.strftime('%Y%m%d%I%M%S').to_s}.docx\"" }
      format.pptx {
        generate_ppt
        File.open(Rails.root + 'generate.pptx', 'r') do |f|
          send_data(f.read, type: 'text/excel', :filename => "content-#{Time.zone.now.strftime('%Y%m%d%I%M%S').to_s}.pptx")
        end
        File.delete(Rails.root + 'generate.pptx')
      }
    end
  end
end
