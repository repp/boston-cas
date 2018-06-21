class LeasesController < ApplicationController

  before_action :authenticate_user!
  before_action :require_can_view_leases!
  before_action :require_can_edit_leases!, only: [:update, :destroy, :create]
  before_action :set_lease, only: [:edit, :update, :destroy]
  helper_method :sort_column, :sort_direction

  def index
    # search
    @leases = if params[:q].present?
                  lease_scope.text_search(params[:q])
                else
                  lease_scope
                end

    # sort / paginate
    @leases = @leases
                    .order(sort_column => sort_direction)
                    .page(params[:page]).per(25)
  end

  def new
    @lease = lease_scope.new
  end

  def create
    @lease = lease_scope.new lease_params
    if @lease.save
      redirect_to action: :index, notice: 'New lease created'
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end

  def edit
  end

  def update
    if @lease.update lease_params
      flash[:notice] = 'Lease updated'
      redirect_to action: :index
    else
      flash[:error] = 'Please review the form problems below.'
      render :new
    end
  end

  def destroy
    @lease.destroy
    flash[:notice] = 'Lease deleted'
    redirect_to({action: :index})
  end

  private
  
  def lease_source
    Lease
  end

  def lease_scope
    Lease.all
  end

  def set_lease
    @lease = lease_scope.find params[:id]
  end

  def lease_params
    params.require(:lease).permit(
        :elite_lease_id,
        :rent_total,
        :rent_program_paid,
        :utility_allowance,
        :owner_id,
        :owner,
        :lease_updated_at
    )
  end

  def sort_column
    Lease.column_names.include?(params[:sort]) ? params[:sort] : 'updated_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def query_string
    "%#{@query}%"
  end

end
