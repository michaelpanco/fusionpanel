class AdminController < ApplicationController

  layout :set_layout
  before_action :check_admin_slug
  
  def index

  end

  def login_connect

    username = params[:username]
    password = params[:password]
    remember = params[:remember]
    if username.empty? || password.empty?
      flash.now[:error] = "Please enter your username and password"
      render :login
    else
      user = User.login(username, password)
      if user
        if remember
          auth_token = SecureRandom.urlsafe_base64
        else
          auth_token = nil
        end
        authenticate_user(username, auth_token, admin_path)
      else
        flash.now[:error] = "Your Username and/or Password is incorrect."
        render :login
      end
    end

  end

  def logout

    if params[:mainslug] == admin_backend_slug
      user = User.find_by_id(cookies[:user_id])
      if user
        user.update_attributes(:authentication_token => nil)
      end
      cookies.permanent[:auth_token] = nil
      reset_session
      redirect_to admin_index_path
    else
      render "public/404.html"
    end
  end

  def add_user
    @username = params[:username]
  end

  def create_user

    input_username = params[:username]
    input_fullname = params[:fullname]
    input_email = params[:email]
    input_password = params[:password]
    user_input = User.new
    user_input.username = input_username
    user_input.fullname = input_fullname
    user_input.email = input_email
    user_input.crypted_password = input_password
    user_state = user_input.save

    if user_state
      else
      flash.now[:create_error] = user_input.errors
    end
    render :action=>'add_user'
  end

  private

  def admin_backend_slug
    return Setting.find_by_setting_name("admin_slug").setting_value
  end

end