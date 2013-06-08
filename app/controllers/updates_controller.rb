class UpdatesController < ApplicationController
  before_filter :find_update, :only => [:edit, :show, :destroy, :update]

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
end
