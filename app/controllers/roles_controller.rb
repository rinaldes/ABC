class RolesController < ApplicationController
  before_action :set_role, except: [:index, :new, :create, :destroy]
  respond_to :html
  before_filter :can_view_role, only: [:index, :show]
  before_filter :can_manage_role, only: [:new, :create, :edit, :update]

  def index
    get_paginated_roles
  end

  def show
    @role = Role.find (params[:id])
  end

  def new
    @role =Role.new
    @feature_names = FeatureName.select("DISTINCT module_name")
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      params[:features].keys.each{|feature|
        Feature.create role_id: @role.id, feature_name_id: feature
      }
      respond_to do |format|
        format.html { redirect_to roles_path }
        format.js { render :create }
      end
    else
      respond_to do |format|
        format.js { render :create }
      end
    end
  end


  def edit
    @role = Role.find(params[:id])
    @feature_names = FeatureName.select('distinct module_name')
  end

  def update
    if @role.update(role_params)
      @role.features.delete_all
      params[:features].keys.each{|feature|
        Feature.create role_id: @role.id, feature_name_id: feature
      }
      respond_to do |format|
        format.html { redirect_to roles_path }
        format.js { render :update }
      end
    else
      respond_to do |format|
        format.html { render :index }
        format.js { render :update }
      end
    end
  end

  def destroy
  	@role = Role.find(params[:id])
    @role.destroy
    redirect_to roles_path, :notice => "Your Role has been deleted"
  end

 private
    def set_role
      
      @role = Role.find(params[:id])
    end

    def set_roles
      base_role = Role.all
      @roles_count = base_role.count
      @roles = base_role.paginate(:page => params[:page])
    end

    def role_params
      params.require(:role).permit(:name, :features)
    end

  def get_paginated_roles
    conditions = []
    params[:search].each{|param|
      conditions << "LOWER(#{param[0]}) LIKE '%#{param[1]}%'"
    } if params[:search].present?
    @roles = Role.where(conditions.join(' AND ')).order(params[:sort].to_s.gsub('-', ' ')).paginate(page: params[:page], per_page: 10) || []
  end

  def can_view_role
    not_authorized unless current_user.can_view_role?
  end

  def can_manage_role
    not_authorized unless current_user.can_manage_role?
  end
end
