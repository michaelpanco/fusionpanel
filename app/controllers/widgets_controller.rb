class WidgetsController < ApplicationController

  layout :set_layout
  before_action :require_login, :check_admin_slug
  
  def index
    @my_permissions = my_permissions
    @admin_slug = admin_backend_slug
    if my_permissions.include?("can_view_widgets")
      page = params[:page]
      search_query = params[:search]
      @record_count = Widget.count
      @search_keyword = search_query
      
      if params.has_key?(:search)
        @widgets = Widget.search(search_query)
      else
        @widgets = Widget.page(page).per(15)
      end
    
      status_list = ['active', 'inactive']
  
      if params.has_key?(:status) && status_list.include?(params[:status])
  
        widget_params = Hash.new
        
        widget_params["status"] = params[:status] if params.has_key?(:status) && params[:status] != "all"
        @widgets = Widget.where_value(widget_params)
  
        @stat_filter_value = params.has_key?(:status) && params[:status] != "all" ? params[:status].capitalize : "All Status"
        
      else
        @stat_filter_value = "All Status"
      end
  
      if @widgets.class == Array
        @widgets = Widget.paginate_array(@widgets).page(page).per(15)
      else
        @widgets = @widgets.page(page).per(15)
      end
  
      render 'admin/widgets/index'
      
    else
      render 'admin/restricted'
    end

  end

  def add
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_widgets")
      
      # Set empty default in all inputs
      @params_widget_title = ""
      @params_widget_alias = ""
      @params_widget_content = ""
      @params_widget_status = "Active"
      
      render 'admin/widgets/add'
    else
      render 'admin/restricted'
    end
  end

  def create
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_widgets")
      @widget = Widget.new(post_widget_params)
      @widget.created_by = session[:user_id]
      @widget.save
      if @widget.errors.any?
        
        # Retain all the user input
        @params_widget_title = @widget.title
        @params_widget_alias = @widget.alias
        @params_widget_content = @widget.content
        @params_widget_status = @widget.status.capitalize

        flash.now[:error] = @widget.errors.full_messages
        render 'admin/widgets/add'
      else
        flash[:notice] = "<strong>Widget Added!</strong> You've successfully created \"" + @widget.title + "\"."
        log_user_activities 'create_widget', 'created <strong>' + @widget.title + '</strong> widget'
        redirect_to admin_widget_path
      end
    else
       render 'admin/restricted'
    end
  end
  
  def edit
    @my_permissions = my_permissions
    if my_permissions.include?("can_view_widgets")
      @widget = Widget.find(params[:id])
      render 'admin/widgets/edit'
    else
       render 'admin/restricted'
    end
  end
  
  def update
    @my_permissions = my_permissions
    
    if my_permissions.include?("can_modify_widgets")
      
      @widget = Widget.find(params[:id])
      if @widget.update(params[:widget].permit(:title, :alias, :content, :status))
        flash[:notice] = "<strong>Widget Updated!</strong> You've successfully updated \"" + @widget.title + "\"."
        log_user_activities 'update_widget', 'updated <strong>' + @widget.title + '</strong> widget'
        redirect_to admin_edit_widget_path(:id=>params[:id])
      else
        flash.now[:error] = @widget.errors.full_messages
        render 'admin/widgets/edit'
      end
      
    else
      render 'admin/restricted'
    end
  end
  
  def delete
    if my_permissions.include?("can_modify_widgets")
      @my_permissions = my_permissions
      params[:widget_ids].each do |widget_id|
        widget_title = Widget.find_by_id(widget_id).title
        Widget.destroy(widget_id)
        log_user_activities 'delete_widget', 'deleted <strong>' + widget_title + '</strong> widget'
      end
      redirect_to admin_widget_path
    else
      render 'admin/restricted'
    end
  end
  
  private

  def post_widget_params
    params.require(:widget).permit(:title, :alias, :content, :status)
  end

end