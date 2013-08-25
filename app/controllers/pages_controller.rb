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

  def by_priority
    @pages = ActiveRecord::Base.connection.execute "SELECT page_id, google_rank, google_backlinks,
      bing_backlinks, yahoo_backlinks, alexa_global_rank, priority, url FROM
      (SELECT DISTINCT ON (page_id) page_id, google_rank, google_backlinks,
        bing_backlinks, yahoo_backlinks, alexa_global_rank, pages.priority, pages.url
        FROM page_rankings
        JOIN pages on page_rankings.page_id = pages.id AND pages.num_failed_accesses < 2
        ORDER BY page_id, page_rankings.created_at DESC) AS t ORDER BY google_rank DESC NULLS LAST"
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

  def multiple_new
  end

  def save_multiple_new
    params[:urls].lines.each do |url|
      url = url.strip
      page = Page.strip_url_and_find url
      if page.nil?
        page = Page.new
        page.url = url
        page.save
        page.plan_next_update
      end
    end
    redirect_to :action => :index
  end
end
