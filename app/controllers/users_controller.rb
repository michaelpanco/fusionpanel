class UsersController < ApplicationController

	layout :set_layout
	require 'securerandom'
	before_action :require_login, :except => [:create_account, :create]
	before_action :check_admin_slug, :except => [:create_account, :create]

	def index
	  @my_permissions = my_permissions
	  
    if my_permissions.include?("can_view_users")
  	  @admin_slug = admin_backend_slug
  		page = params[:page]
  		search_query = params[:search]
  		@search_keyword = search_query
  		@record_count = User.count
  
  		if params.has_key?(:search)
  			@users = User.search(search_query)
  		else
  			@users = User.page(page).per(15)
  		end
  
  		@roles = Role.all
  		@admin_slug = admin_backend_slug
  
  		if @users.class == Array
  			@users = User.paginate_array(@users).page(page).per(15) 
  		else
  			@users = @users.page(page).per(15)
  		end
  		render 'admin/users/index'
  		
    else
      render 'admin/restricted'
    end
    
	end

	def add
    @my_permissions = my_permissions
		response = Hash.new
    if my_permissions.include?("can_invite_users")
  		@user_request = UserRequest.new()
  		@user_request.email = params[:email]
  		@user_request.role = params[:role]
  		@user_request.token = SecureRandom.hex(32)
  		@user_request.status = "pending"
  		@user_request.save
  
  		if @user_request.errors.any?
  			response["code"] = 201
  			response["message"] = @user_request.errors.full_messages[0]
  		else
  			request_link = root_url + admin_backend_slug + "/create-account/" + @user_request.token
  			# Get the role name base on the role id
  			user_role = Role.find(@user_request.role).name
  			# Send Email to the new user
  			begin
    			UserMailer.send_user_invitation(@user_request.email, request_link, user_role, session[:fullname]).deliver
    			log_user_activities 'invite_user', 'invited <strong>' + params[:email] + ' as ' + user_role + '</strong>'
    			response["code"] = 100
          response["message"] = "Email request has been sent successfully."
  			rescue 
    			response["code"] = 201
          response["message"] = "Error Sending Email. Please check your SMTP settings and try again."
          # Delete Save user_request save
          UserRequest.find_by_email(params[:email]).destroy
        end
  		end
    else
      response["code"] = 201
      response["message"] = [User::PERMISSION_ERROR_MSG]
    end
		render json:response
	end

	def profile
	  @my_permissions = my_permissions
	  @admin_slug = admin_backend_slug
	  @roles = Role.all
		@user = User.find_by_username(params[:username])
		if @user
		  render 'admin/users/profile'
		else
      @title = "User not found"
      @description = 'The user you requested does not exist. <a href="' + admin_user_path + '" >Back to Users</a>'
      @message = @description.html_safe
      render 'admin/extras/404_internal'
		end
	end

	def create_account
	  ##@my_permissions = my_permissions
		user_request = UserRequest.where("token = ? AND status = ?", params[:token], "pending").take
		if user_request
			@user_token = user_request.token
			@user_email = user_request.email
			render 'admin/users/create_account'
		else
			render 'admin/extras/404'
		end
	end

	def delete
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_users")
  		if can_delete_user(params[:user_ids])
  			# Delete data on user request table
  			params[:user_ids].each do |userid|
  			  user = User.find(userid)
  			  User.find(userid).destroy
  			  UserRequest.find_by_email(user.email).destroy
  			  
          #page_title = Page.find_by_id(item_id).content_title
          #Page.destroy(item_id)
          #Meta.destroy(item_id)
          log_user_activities 'delete_user', 'deleted <strong>' + user.fullname + '</strong>'
  			  
  			  destroy_user_session(user.session_id)
  			end
  		else
  			flash[:error] = "You cannot delete your own account."
  		end
    else
      flash[:error] = User::PERMISSION_ERROR_MSG
    end
		redirect_to admin_user_path
	end

	def create
    #@my_permissions = my_permissions
		user_request = UserRequest.find_by_token(params[:users]["token"])

		if user_request
			@user_token = user_request.token
			@user_email = user_request.email
			@user = User.new(post_create_user_params)
			@user.email = user_request.email
			@user.role_id = user_request.role
			@user.status = "active"
			@user.crypted_password = params[:users]["password"]
			@user.crypted_password_confirmation = params[:users]["password_confirmation"]
			@user.save
			if @user.errors.any?
				@fullname = @user.fullname
				@username = @user.username
				flash.now[:error] = @user.errors.full_messages
				render 'admin/users/create_account'
			else
				user_request.update_attributes(status: 'confirmed')
				login_page_path = root_url + Setting.find_by_setting_name("admin_slug").setting_value
				flash.now[:notice] = 'You have successfully created your account.<br/><a href="' + login_page_path + '">Click here</a> to login your account.'
				session[:user_id] = @user.id
				log_user_activities 'create_account', ' created an account'
				render 'admin/users/create_account'
			end	
		else
			flash.now[:error] = ["Invalid request token"]
			render 'admin/users/create_account'
		end
	end

  def changepassword
    
    input_old_password = params[:oldpassword]
    input_new_password = params[:newpassword]
    
    
    change_user_password = User.find(session[:user_id])
    correct_password = User.login(change_user_password.username, input_old_password)
    response = Hash.new
    
    if correct_password
     
      change_user_password.crypted_password = BCrypt::Engine.hash_secret(input_new_password, change_user_password.password_salt)
      sleep 2
      change_user_password.save
      
      if change_user_password.errors.any?
        response["code"] = 201
        response["message"] = change_user_password.errors.full_messages[0]
      else
        response["code"] = 100
        log_user_activities 'change_password', 'has <strong>change the password</strong>'
        response["message"] = "Your password has been successfully changed."
      end

    else
      response["code"] = 201
      response["message"] = "Please enter correct old password"
    end
     
    render json:response
    
  end

  def changerole
    @my_permissions = my_permissions
    response = Hash.new
      if my_permissions.include?("can_modify_users")
      change_user_role = User.find(params[:userid])
      change_user_role.role_id = params[:role]
      sleep 2
      change_user_role.save
      
      if change_user_role.errors.any?
        response["code"] = 201
        response["message"] = change_user_role.errors.full_messages[0]
      else
        response["code"] = 100
        log_user_activities 'update_user', 'changed <strong>' + change_user_role.fullname + ' role to ' + change_user_role.role.name + '</strong>'
        response["message"] = "User role has been successfully changed."
      end
    else
      response["code"] = 201
      response["message"] = [User::PERMISSION_ERROR_MSG]
    end
    render json:response
  end
  
  def role_index
    @my_permissions = my_permissions
    @admin_slug = admin_backend_slug
    if my_permissions.include?("can_view_roles")
      @roles = Role.all
      page = params[:page]
      search_query = params[:search]
      @search_keyword = search_query
      @record_count = Role.count
  
      if params.has_key?(:search)
        @roles = Role.search(search_query)
      else
        @roles = Role.page(page).per(15)
      end
      
      page = params[:page]
      if @roles.class == Array
        @roles = Role.paginate_array(@roles).page(page).per(15) 
      else
        @roles = @roles.page(page).per(15)
      end
      render 'admin/users/role/index'
    else
      render 'admin/restricted'
    end
  end

  def add_role
    @my_permissions = my_permissions
    @params_role_name = ""
    @params_role_status = "Active"
    @roles = Role::PERMISSIONS
    render 'admin/users/role/add'
  end
  
  def create_role
    @my_permissions = my_permissions
    @roles = Role::PERMISSIONS
    if my_permissions.include?("can_modify_roles")
      role = Role.new
      role.name = params[:role]["name"]
      role.status = params[:role]["status"]
      input_role = params[:permissions]
      role_field = ""
      if !input_role.nil?
      input_role.each do |inputrole|
        role_field += inputrole + ", "
      end
      end
      role.permissions = role_field.chop.chop
      if role.save
        flash[:notice] = "<strong>Role Added!</strong> You've successfully added \"" + role.name + "\"."
        log_user_activities 'create_role', 'created <strong>' + params[:role]["name"] + '</strong> role'
        redirect_to admin_user_role_path
      else
        @params_role_name = role.name
        @params_role_status = role.status.capitalize
        @params_role_permissions = params[:permissions]
        flash.now[:error] = role.errors.full_messages
        render 'admin/users/role/add'
      end
    else
      render 'admin/restricted'
    end
  end
  
  def edit_role
    @my_permissions = my_permissions
    if my_permissions.include?("can_view_roles")
      @roles = Role::PERMISSIONS
      @role = Role.find(params[:id])
      render 'admin/users/role/edit'
    else
      render 'admin/restricted'
    end
  end
  
  def update_role
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_roles")
      @roles = Role::PERMISSIONS
      @role = Role.find(params[:id])
      if params[:id] != "1"
        role = Role.find(params[:id])
        role.name = params[:role]["name"]
        role.status = params[:role]["status"]
        input_role = params[:permissions]
        role_field = ""
        if not input_role.nil?
          input_role.each do |inputrole|
            role_field += inputrole + ", "
          end
        end
        role.permissions = role_field.chop.chop
        if role.save
          flash[:notice] = "<strong>Role Updated!</strong> You've successfully updated \"" + role.name + "\"."
          log_user_activities 'update_role', 'updated <strong>' + params[:role]["name"] + '</strong> role'
          redirect_to admin_user_editrole_path(:id=>params[:id])
        else
          flash.now[:error] = role.errors.full_messages
          render 'admin/users/role/edit'
        end
        
      else
  
        flash.now[:error] = ["You cannot make any changes to this role."]
        render 'admin/users/role/edit'
      end
    else
      render 'admin/restricted'
    end
  end
  
  def delete_role
    @my_permissions = my_permissions
    if my_permissions.include?("can_modify_roles")
      if not params[:role_ids].include? "1"
        
      #Role.destroy_all(:id => params[:role_ids])
      
      params[:role_ids].each do |item_id|
         role_name = Role.find_by_id(item_id).name
         Role.destroy(item_id)
         log_user_activities 'delete_role', 'deleted <strong>' + role_name + '</strong> role'
      end
      
      
      redirect_to admin_user_role_path
      else
        flash[:error] = ["You cannot delete Administrator role"]
            redirect_to admin_user_role_path
      end
    else
      render 'admin/restricted'
    end
  end

	private

	def post_create_user_params
		params.require(:users).permit(:fullname, :username)
	end

	def post_user_params
		params.require(:user_request).permit(:email, :role)
	end

	
	def plain_pages
		['create_account', 'create']
	end

	def can_delete_user(user_ids)
		user_ids.each do |id|
			user = User.find(id)			  
			if session[:user_id] == user.id
				return false
			end
		end

		return true
	end
	
  private
  
	def set_layout
		if session[:logged] == true and not plain_pages.include? action_name
			"fusionpanel/fusionpanel"
		else
			"fusionpanel/plain"
		end
	end

end