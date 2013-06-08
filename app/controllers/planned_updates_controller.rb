class PlannedUpdatesController < ApplicationController
  before_filter :find_planned_update, :only => [:edit, :show, :destroy, :update]

  def find_planned_update
    return redirect_to :action => :index unless params.has_key? :id
    @planned_update = PlannedUpdate.find_by_id params[:id]
    return redirect_to :action => :index if @planned_update.nil?
  end

  def index
    @planned_updates = PlannedUpdate.all(:order => 'execute_after', :limit => 100)
  end

  def show
  end

  def new
    @planned_update = PlannedUpdate.new
  end

  def create
    @planned_update = PlannedUpdate.new(params[:page])
    @planned_update.save
    redirect_to(@planned_update)
  end

  def edit
  end

  def update
    if @planned_update.update_attributes(params[:page])
      redirect_to(@planned_update)
    else
      render "edit"
    end
  end

  def destroy
    @planned_update.delete
    redirect_to :action => :index
  end
end
