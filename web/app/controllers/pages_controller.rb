class PagesController < ApplicationController
  before_filter :find_page, :only => [:edit, :show, :destroy, :update]

  def find_page
    return redirect_to :action => :index unless params.has_key? :id
    @page = Page.find_by_id params[:id]
    return redirect_to :action => :index if @page.nil?
  end

  def index
    @pages = Page.all(:order => :stripped_url)
  end

  def show
  end

  def new
    @page = Page.new
  end

  def create
    @page = Page.strip_url_and_find params[:page][:url]
    return redirect_to @page unless @page.nil?
    @page = Page.new(params[:page])
    @page.save
    @page.plan_next_update
    redirect_to(@page)
  end

  def edit
  end

  def update
    if @page.update_attributes(params[:page])
      redirect_to(@page)
    else
      render "edit"
    end
  end

  def destroy
    @page.delete
    redirect_to :action => :index
  end
end
