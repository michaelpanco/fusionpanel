class CategoriesController < ApplicationController

	layout :set_layout
  before_action :require_login, :check_admin_slug
  
	def index
	  @admin_slug = admin_backend_slug
	  @my_permissions = my_permissions
	  if my_permissions.include?("can_view_categories")
      @category_parent_lists = Category.where.not(id: 1)
  		page = params[:page]
  		search_query = params[:category_name]
  		@record_count = Category.count
  		@search_keyword = search_query
  		
  		if params.has_key?(:category_name)
  			@categories = Category.search(search_query)
  		else
  			@categories = Category.page(page).per(15)
  		end
  
  		if @categories.class == Array
  			@categories = Category.paginate_array(@categories).page(page).per(15) 
  		else
  			@categories = @categories.page(page).per(15)
  		end
  		
      unless @categories.empty?
        @category_count = @categories.first.id == 1 ? @categories.count - 1 : @categories.count
      end
      
  		render 'admin/categories/index'
  		
		else
      render 'admin/restricted'
    end
	end

  def add
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_categories")
      @my_permissions = my_permissions
      @category_parent_lists = Category.where.not(id: 1)
      render 'admin/categories/add'
    else
       render 'admin/restricted'
    end
  end

	def create
	  @my_permissions = my_permissions
	  if my_permissions.include?("can_modify_categories")
      sleep 1.5
      response = Hash.new
  		@category = Category.new()
  		@category.name = params[:category_name]
  		@category.slug = params[:category_slug]
  		@category.parent_category = params[:parent_category]
  		@category.save
  
  		if @category.errors.any?
  			response["code"] = 201
  			response["message"] = @category.errors.full_messages[0]
  		else
  			flash[:notice] = "<strong>Category Added!</strong> You've successfully created \"" + @category.name + "\"."
  			log_user_activities 'create_category', 'created <strong>' + params[:category_name] + '</strong> category'
  			response["code"] = 100
  			response["message"] = "Success"
  		end	

    else
        response["code"] = 201
        response["message"] = User::PERMISSION_ERROR_MSG
    end
    
		render json:response

	end

	def delete
	  @my_permissions = my_permissions
	  if my_permissions.include?("can_modify_categories")
  		if can_delete_category(params[:category_ids])
  		  #Category.destroy_all(:id => params[:category_ids])
        params[:category_ids].each do |cat_id|
          category_title = Category.find_by_id(cat_id).name
          Category.destroy(cat_id)
          log_user_activities 'delete_category', 'deleted <strong>' + category_title + '</strong> category'
        end
  		else
  			flash[:error] = "Delete Failed! Some Category may have contain an active pages."
  		end
  		redirect_to admin_category_path
    else
      render 'admin/restricted'
    end
	end

	def edit
	  @my_permissions = my_permissions
	  
    if my_permissions.include?("can_modify_categories")
  	  @category_parent_lists = Category.where.not(id: [1, params[:id]]).where.not(parent_category: params[:id])
  		@category = Category.find_by_id(params[:id])
  		
  		if @category
        render 'admin/categories/edit'
      else
        @title = "Category not found"
        @description = 'The category you requested does not exist. <a href="' + admin_category_path + '" >Back to Categories</a>'
        @message = @description.html_safe
        render 'admin/extras/404_internal'
      end
      
    else
      render 'admin/restricted'
    end
		
	end

	def update
	  @my_permissions = my_permissions
	  if my_permissions.include?("can_modify_categories")
  		@category = Category.find(params[:id])
  		#parentCategory
      @category_parent_lists = Category.where.not(id: [1, params[:id]])
  		if @category.update(params[:category].permit(:name, :slug, :parent_category))
  			flash[:notice] = "<strong>Category Updated!</strong> You've successfully updated \"" + @category.name + "\"."
  			log_user_activities 'update_category', 'updated <strong>' + @category.name + '</strong> category'
  			redirect_to admin_edit_category_path(:id=>params[:id])
  		else
  			flash.now[:error] = @category.errors.full_messages
  			render 'admin/categories/edit'
  		end
  	else
      render 'admin/restricted'
  	end
	end

	private
	
	def can_delete_category(cat_ids)
			cat_ids.each do |id|
				category = Category.find(id)			  
				if category.page.present?
					return false
				end
			end

			return true
	end

  def post_category_params
    params.require(:category).permit(:name, :slug)
  end
	  
end