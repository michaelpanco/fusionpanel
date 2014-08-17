class MainController < ApplicationController
	
	require 'securerandom'
  layout :set_layout_main
  
  def index
  	
  	if is_homepage_setup?
  		
  		if active_website?
	  		homepage = Page.find(Setting.find_by_setting_name('homepage').setting_value)
		    @page_title = homepage.meta.page_title.empty? ? homepage.content_title : homepage.meta.page_title
		    @content_title = homepage.content_title
		    @content = homepage.content.html_safe
		    @status = "success"
		    @status_response = '200'
		    render homepage.template.location
  		else
        @status_response = '403'
        render 'public/offline.html'
  		end
  		
	  else
			render :text => Page::PAGE_NOT_FOUND_ERR_MSG
	  end
	  
  end

  def router
  	
    if is_page_exist? params[:mainslug]
      page_slug = params[:mainslug]
      page = Page.where("url_slug = ?", page_slug).take
      if page.status == "active"
        @page_title = page.meta.page_title.empty? ? page.content_title : page.meta.page_title
        @content_title = page.content_title
        @content = page.content.html_safe
        @status_response = '200'
        render page.template.location
      else
        @status_response = '404'
        render 'public/404.html'
      end

    else
      if params[:mainslug] == back_end_slug_from_db
        if session[:logged] == true
          graph_view_type = params[:viewtype]
          graph_year_filter = params[:year]
          graph_month_filter= params[:month]
          @my_permissions = my_permissions
          @admin_slug = admin_backend_slug
          base_year = 2011
          date = Date.today
          @current_year = date.strftime("%-Y")
          @current_month = date.strftime("%b")
          @current_month_full = date.strftime("%B")
          
          if graph_view_type
            @graph_view_type = graph_view_type
          else
            @graph_view_type = 'months'
          end

          if graph_year_filter
            @graph_year_filter = graph_year_filter
            @year_filter = '&year=' + graph_year_filter
          else
            @graph_year_filter = @current_year
            @year_filter = ''
          end

          if graph_month_filter
            @graph_month_filter = graph_month_filter # January
            @month_filter = '&month=' + graph_month_filter # &month=January
          else
            @graph_month_filter = @current_month_full # January
            @month_filter = ""
          end

          if @current_year.to_i > base_year
            @year_list = []
            (base_year..@current_year.to_i).each do |year|
              @year_list.push(year.to_s)
            end
          else
            @year_list = [@current_year]
          end
          
          if @graph_year_filter == @current_year
            months = Date::MONTHNAMES.index(@current_month_full) 
          else
            months = 12
          end
          
          month_list = []
          (1..months).each do |month|
            month_list.push(Date::MONTHNAMES[month])
          end
          
          @month_selection = month_list

          if @graph_view_type == 'days'
            @day_btn = ' disabled'
            @month_btn_path = admin_path + '?viewtype=months'
          else
            @month_btn = ' disabled'
            @day_btn_path = admin_path + '?viewtype=days'
          end

          @latest_activity = Activity.all(:order => 'created_at DESC', :limit => 5)
           
          @graph_data = self.render_graph(@graph_view_type, @graph_year_filter, @graph_month_filter)
          render 'admin/dashboard/index'

        else
        	@admin_slug = params[:mainslug]
          if not cookies[:auth_token] == nil
            token_exist = User.find_by_authentication_token(cookies[:auth_token])
            if token_exist
              auth_token = SecureRandom.urlsafe_base64
              authenticate_user(token_exist.username, auth_token, admin_path)
            else
              @goto = params[:goto]
              render 'admin/login'
            end
          else
            @goto = params[:goto]
            render 'admin/login'
          end
        end
      else
        @status_response = '404'
        render "public/404.html"
      end
    end

  end

  def forgotpassword
    
    account_email_address = params[:emailaddress]
    admin_slug = params[:mainslug]
    user_by_email = User.find_by email: account_email_address

    response = Hash.new
    
    if user_by_email
    	
      user_by_email.reset_password_token = SecureRandom.urlsafe_base64
      UserMailer.forgot_password(user_by_email.id, user_by_email.email, user_by_email.reset_password_token, root_url, admin_slug, Setting.find_by_setting_name('company_name').setting_value).deliver
      sleep 2
      
      user_by_email.save
      
      if user_by_email.errors.any?
        response["code"] = 201
        response["message"] = change_user_password.errors.full_messages[0]
      else
        response["code"] = 100
        response["message"] = "Details about how to reset your password has been sent to your email address"
      end

    else
      response["code"] = 201
      response["message"] = "Email address doesn't exist"
    end
     
    render json:response
    
  end

	def resetpassword
		
		reset_token = params[:token]
		account_id = params[:account]
		
		if valid_reset_uri? reset_token, account_id
			@account_id = account_id
			@account_email = User.find(account_id = params[:account]).email
			@reset_token = reset_token
			render 'admin/users/reset_password'
		else
			render "public/404.html"
		end
		
	end
	
	def valid_reset_uri? token, account_id

		reset_token = User.where(:reset_password_token => token).where(:id => account_id).present?
		
		if reset_token
			true
		end
		
	end

	def resetpassword_submit
		@account_email = params[:account_email]
		@reset_token = params[:token]
		@account_id = params[:account]
		
		password_reset = User.where(:reset_password_token => @reset_token).where(:id => @account_id).take
		
		if password_reset
			
			password1 = params[:users]['password']
			password2 = params[:users]['password_confirmation']
			
			unless password1.empty? || password2.empty?
				
				if password1 == password2
					if password1.length >= 8
						password_reset.crypted_password = BCrypt::Engine.hash_secret(password1, password_reset.password_salt)
						password_reset.reset_password_token = ""
						password_reset.save
						
						unless password_reset.errors.any?
							admin_login = root_url + params[:mainslug]
							flash.now[:notice] = "Your password has been changed successfully. You can now <a href='"+admin_login+"'>login</a> to your account"
						else
							flash.now[:error] = ["Failed to change password, Please try again"]
						end
						
					else
						flash.now[:error] = ["Password must have at least 8 characters"]
					end
				else
					flash.now[:error] = ["Password doesn't match"]
				end
				
			else
				flash.now[:error] = ["Please enter your new passwords"]
			end
			
		else
			flash[:error] = ["Invalid reset token"]
		end

		render 'admin/users/reset_password'
		
	end

  def visitor_info
    d = Date.today
    filter_type = params[:filter_type]
    response = Hash.new
    case filter_type
    when 'overall'
      record_count = Traffic.count
    when 'month'
      record_count = Traffic.where('created_at BETWEEN ? AND ?', d.at_beginning_of_month, d.at_end_of_month).all.count
    when 'day'
      record_count = Traffic.where('created_at BETWEEN ? AND ?', d.at_beginning_of_day, d.at_end_of_day).all.count
    else
    record = 0
    end
    response["visitor_count"] = record_count
    render json:response
  end

  def render_graph graph_view_type, graph_year_filter, graph_month_filter
    labels = self.graph_labels(graph_view_type, graph_year_filter, graph_month_filter)
    datas = self.graph_datas(graph_view_type, graph_year_filter, graph_month_filter)

    '<div id="canvasDIV">
      <canvas id="canvas"></canvas>
    </div>

    <script>
    var canvas = document.querySelector("canvas"),
        ctx    = canvas.getContext("2d");
    fitToContainer(canvas);

    ctx.fillStyle="yellow";
    for (var i=0;i<5;++i) ctx.fillRect(i*18+2,2,16,16);

    function fitToContainer(canvas){
      canvas.style.width="100%";
      canvas.style.height="100%";
      canvas.width  = canvas.offsetWidth;
      canvas.height = canvas.offsetHeight;
    }

    var lineChartData = {
      labels : '+ labels +',
      datasets : [
        {
          fillColor : "rgba(151,187,205,0.5)",
          strokeColor : "rgba(151,187,205,1)",
          pointColor : "rgba(151,187,205,1)",
          pointStrokeColor : "#fff",
          data : ' + datas + '
        }
      ]
    }
    var myLine = new Chart(document.getElementById("canvas").getContext("2d")).Line(lineChartData);
    </script>'

  end

  def graph_labels graph_view_type, graph_year_filter, graph_month_filter

    date = Date.today
    labels = []
    current_year = date.strftime("%-Y")
    current_month = date.strftime("%b")
    graph_month_filter_index = Date::MONTHNAMES.index(graph_month_filter)

    if graph_view_type == 'days'
      
      if current_year == graph_year_filter && current_month == graph_month_filter
        day_range = date.strftime("%-d").to_i # 1 - 31
      else
        day_range = Time.days_in_month(graph_month_filter_index, graph_year_filter.to_i)
      end
      
      (1..day_range).each do |day|
        labels.push('"' + Date::ABBR_MONTHNAMES[graph_month_filter_index] + ' ' + day.to_s + '"')
      end
      
    else
      
      if current_year == graph_year_filter
        month_range = date.strftime("%-m").to_i # 1 -12
      else
        month_range = 12
      end
      
      (1..month_range).each do |month|
        labels.push('"' + Date::ABBR_MONTHNAMES[month] + ' ' + graph_year_filter + '"')
      end
      
    end

    return '[' + labels.join(',') + ']'

  end
  
  def graph_datas graph_view_type, graph_year_filter, graph_month_filter

    date = Date.today
    data_counts = []
    current_year = date.strftime("%-Y")
    current_month = date.strftime("%b")
    graph_month_filter_index = Date::MONTHNAMES.index(graph_month_filter)

    if graph_view_type == 'days'
      
      if current_year == graph_year_filter && current_month == graph_month_filter
        day_range = date.strftime("%-d").to_i # 1 - 31
      else
        day_range = Time.days_in_month(graph_month_filter_index, graph_year_filter.to_i)
      end
      
      (1..day_range).each do |day|
        data_count_details = self.get_traffic_data('days', graph_year_filter, graph_month_filter, day)
        data_counts.push(data_count_details)
      end
      
    else
      
      if current_year == graph_year_filter
        month_range = date.strftime("%-m").to_i # 1 -12
      else
        month_range = 12
      end
      
      (1..month_range).each do |month|
        data_count_details = self.get_traffic_data('months', graph_year_filter, month, 0)
        data_counts.push(data_count_details)
      end
      
    end

    return '[' + data_counts.join(',') + ']'

  end
  
  def is_homepage_setup?
		
		get_homepage = Setting.find_by setting_name: 'homepage'
		
		if get_homepage.setting_value != "" and page_exist? get_homepage.setting_value
			return true
		end
		
	end
	
	def active_website?
		
		get_web_status = Setting.find_by setting_name: 'web_status'
		
		if get_web_status.setting_value == "online"
			return true
		end
		
	end
  
  def get_traffic_data retrieved_type, selected_year, selected_month, selected_day
    if retrieved_type == 'months'
      setted_date = selected_year.to_s + '-' + selected_month.to_s + '-1'
      data = Traffic.where(created_at: setted_date.to_date..setted_date.to_date.end_of_month)
    else
      setted_date = selected_year.to_s + '-' + selected_month.to_s + '-' + selected_day.to_s
      data = Traffic.where('DATE(created_at) = ?', setted_date.to_date )
    end
    
    return data.count
  end

  def set_layout_main
    if is_page_exist? params[:mainslug]
    false
    else
      if session[:logged] == true && params[:mainslug] == admin_backend_slug
        "fusionpanel/fusionpanel"
      else
        "fusionpanel/plain"
      end
    end
  end
  
	private

	def post_create_user_params
		params.require(:users).permit(:email, :password)
	end

end
