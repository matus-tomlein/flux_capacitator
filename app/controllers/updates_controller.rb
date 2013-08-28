class UpdatesController < ApplicationController
  before_filter :find_update, :only => [:edit, :show, :destroy, :update, :image]

  def find_update
    return redirect_to :action => :index unless params.has_key? :id
    @update = Update.find_by_id params[:id]
    return redirect_to :action => :index if @update.nil?
  end

  def compare
    @content = `python lib/diff.py #{params[:update1_id]} #{params[:update2_id]}` if params.has_key?(:update1_id) && params.has_key?(:update2_id)

    @content.sub! '</head>', '<style type="text/css"><!--ins {background: #bfb} del{background: #fcc} ins,del {text-decoration: none} --></style></head>'
    respond_to do |format|
      format.html { render :text => @content }
    end
  end

  def content
    @update = Update.find(params[:id])
    respond_to do |format|
      format.html { render :text => @update.content }
    end
  end

  def image
    image_path = "/updates-screenshots/#{@update.id}.png"
    unless File.exist?(Rails.public_path + image_path)
      STDERR.sync = true
      args = {
        "LISTEN_PORT" => 8123.to_s,
        "CACHE_FOLDER" => Update.get_cache_folder_path(@update.cache_folder_name),
        "NO_GUI" => "1",
        "DONT_USE_DB_FOR_CACHE" => "1"
      }
      #args["CACHE_ONLY"] = "1" if cache_only
      Open3.popen3(args, "#{Rails.application.config.proxy_app_path}") do |stdin, stdout, stderr, th|
        while !stderr.eof? do
          line = stderr.readline.strip
          if line.to_s == '"READY"'
            puts `#{Rails.application.config.phantomjs_path} --proxy=localhost:8123 /script/phantomjs/rasterize.js #{@update.page.url} #{Rails.public_path}#{image_path}`

            begin
              open('http://my.ownet/api/app/quit', { :proxy => "http://localhost:8123/" })
            rescue
            end

            break
          end
        end
        while !stderr.eof? do
          stderr.readline.strip
        end
      end
    end
    redirect_to image_path
  end

  def index
    @updates = Update.all(:order => 'created_at DESC', :limit => 100)
  end

  def show
  end

  def new
    @update = Update.new
  end

  def create
    @update = Update.new(params[:page])
    @update.save
    redirect_to(@update)
  end

  def edit
  end

  def update
    if @update.update_attributes(params[:page])
      redirect_to(@update)
    else
      render "edit"
    end
  end

  def destroy
    @update.delete
    redirect_to :action => :index
  end

  def links
    @update = Update.includes(:page).find(params[:id])
    text = File.read("#{Rails.application.config.cache_folder}parsed/#{@update.cache_folder_name}.json")
    if text[0..2] == '[{\\'
      while text[-1] != "]"
        text.chop!
      end
      text = text.gsub('\\"', '"')
    end
    unless @update.parsed
      redirect_to :status => 404
    else
      links_json = JSON.parse(text)
      respond_to do |format|
        format.json { render :text => {
          'page_id' => @update.page.id,
          'url' => @update.page.url,
          'links' => links_json
        }.to_json }
      end
    end
  end

  def parse
    @update = Update.find(params[:id])
    unless @update.parsed
      @update.parse_downloaded
      @update.save
    end
    respond_to do |format|
      format.html { render :text => "OK" }
    end
  end

  def parsed
    respond_to do |format|
      format.json { render :json => Update.where(:parsed => true).select(:id).map{|k| k.id}.to_json }
    end
  end
end
