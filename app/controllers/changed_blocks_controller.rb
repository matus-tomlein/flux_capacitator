class ChangedBlocksController < ApplicationController
  before_filter :find_changed_block, :only => [:edit, :show, :destroy, :update]

  def find_changed_block
    return redirect_to :action => :index unless params.has_key? :id
    @changed_block = ChangedBlock.find_by_id params[:id]
    return redirect_to :action => :index if @changed_block.nil?
  end

  def index
    @changed_blocks = ChangedBlock.all(:order => 'created_at DESC', :limit => 100)
  end

  def show
  end

  def new
    @changed_block = ChangedBlock.new
  end

  def create
    @changed_block = ChangedBlock.new(params[:page])
    @changed_block.save
    redirect_to(@changed_block)
  end

  def edit
  end

  def update
    if @changed_block.update_attributes(params[:page])
      redirect_to(@changed_block)
    else
      render "edit"
    end
  end

  def destroy
    @changed_block.delete
    redirect_to :action => :index
  end
end
