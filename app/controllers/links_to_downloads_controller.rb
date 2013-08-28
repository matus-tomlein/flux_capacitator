class LinksToDownloadsController < ApplicationController
  def take
    links = LinksToDownload.order("rank").limit(100)
    urls = []
    ids = []
    links.each do |link|
      next if link.update.nil?
      urls << { "url" => link.url, "page_id" => link.update.page_id }
      ids << link.id
    end
    ActiveRecord::Base.connection.execute("DELETE FROM links_to_downloads WHERE id IN (" + ids.join(',') + ")") if ids.count > 0

    respond_to do |format|
      format.json { render :json => urls.to_json }
    end
  end

end
