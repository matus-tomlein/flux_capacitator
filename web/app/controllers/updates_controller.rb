class UpdatesController < ApplicationController
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

end
