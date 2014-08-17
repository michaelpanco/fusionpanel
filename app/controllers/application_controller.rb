class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  after_filter :log_visitor
  def index
    @my_permissions = my_permissions
  end

  private

  def set_layout
    if session[:logged] == true && params[:mainslug] == admin_backend_slug
      "fusionpanel/fusionpanel"
    else
      "fusionpanel/plain"
    end
  end

  def require_login
    unless session[:logged]
      if params[:mainslug] == back_end_slug_from_db
        url_origin = root_url + back_end_slug_from_db
        if not cookies[:auth_token] == nil
          token_exist = User.find_by_authentication_token(cookies[:auth_token])

          if token_exist
            auth_token = SecureRandom.urlsafe_base64
            authenticate_user(token_exist.username, auth_token, request.fullpath)
          else
            flash[:error] = "You need to login to access this page."
            redirect_to url_origin + "/?goto=" + request.url
          end
        else
          flash[:error] = "You need to login to access this page."
          redirect_to url_origin + "/?goto=" + request.url
        end
      else
        render "public/404.html"
      end
    end
  end

  def authenticate_user username, auth_token, redirection_url

    if username.rindex('@')
      userinfo = User.find_by_email(username)
    else
      userinfo = User.find_by_username(username)
    end

    session[:logged] = true
    session[:username] = userinfo.username
    session[:email] = userinfo.email
    session[:fullname] = userinfo.fullname
    session[:role] = userinfo.role.name
    session[:user_id] = userinfo.id
    cookies[:user_id] = userinfo.id
    email_address = userinfo.email.downcase
    hash = Digest::MD5.hexdigest(email_address)
    session[:gravatar_hash] = hash
    session[:admin_title] = Setting.find_by_setting_name('admin_title').setting_value
    session[:permissions]  = userinfo.role.permissions.split(',').collect(&:strip)
    session[:admin_slug]  = Setting.find_by_setting_name("admin_slug").setting_value
    update_session_id(userinfo.id,request.session_options[:id])
    if not auth_token == nil
      token_hash = SecureRandom.urlsafe_base64
      cookies.permanent[:auth_token] = token_hash
      userinfo.update_attributes(:authentication_token => token_hash)
    else
      userinfo.update_attributes(:authentication_token => nil)
    end
    if params.has_key?(:goto) && params[:goto] != ''
      redirect_to params[:goto]
    else
      redirect_to redirection_url
    end
  end

  def log_visitor
    unless params[:mainslug] == back_end_slug_from_db
      visitor_log = Traffic.new()
      visitor_log.ip = request.remote_ip
      visitor_log.url = request.original_url #+ @status
      visitor_log.browser = request.env['HTTP_USER_AGENT']
      visitor_log.status = @status_response
      visitor_log.created_at = DateTime.now
    visitor_log.save
    end
  end

  def log_user_activities(type,message)
    activity_log = Activity.new()
    activity_log.user_id = session[:user_id]
    activity_log.activity_type = type
    activity_log.activity_message = message
    activity_log.created_at = DateTime.now
    activity_log.save
  end

  def my_permissions
    user = User.find(session[:user_id])
    user.role.permissions.split(',').collect(&:strip)
  end

  def update_session_id(id,session_id)
    user = User.find(id)
    user.session_id = session_id
    user.save
  end

  def destroy_user_session(session_id)
    session = Session.find_by_session_id(session_id)
    if session
    session.destroy
    end
  end

	def page_exist? page_id
		get_page = Page.find_by id: page_id
		
		if get_page
			return true
		end
		
	end

  def back_end_slug_from_db
    return Setting.find_by_setting_name("admin_slug").setting_value
  end

  def check_admin_slug
    if params[:mainslug] != admin_backend_slug
      if is_page_exist?(params[:mainslug])
        render :text => "Page Exist"
      else
        render "public/404.html"
      end
    end
  end

  def admin_backend_slug
    return session[:admin_slug]
  end

  def is_page_exist? page_slug
    return Page.exists?(url_slug: page_slug) || page_slug.nil?
  end

end
