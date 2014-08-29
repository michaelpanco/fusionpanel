class FrontpageController < ApplicationController
	
  layout false
  skip_before_action :verify_authenticity_token, :only => [:sendmessage]
  
  def index
  	
  	require 'uri'
  	
    page_urls = params[:pagecats]
    page_slug = params[:page]
    page = Page.where("url_slug = ?", page_slug).take
    
    case page_urls.split("/").count
      
    when 1
      
      if page and page.url_slug == page_slug and page.category.slug == page_urls and page.status == "active"
        @page_title = page.meta.page_title.empty? ? page.content_title : page.meta.page_title
        @content_title = page.content_title
        @content = page.content.html_safe
        @status_response = '200'
        request_url = request.original_url
        @active_page = URI(request_url).path.split('/').second
        @authenticity_token = form_authenticity_token
        render page.template.location
      else
        @status_response = '404'
        render 'public/404.html'
      end
      
    else
      
      if page and page.url_slug == page_slug and category_slugs(page.category_id) == page_urls and page.status == "active"
        @page_title = page.meta.page_title.empty? ? page.content_title : page.meta.page_title
        @content_title = page.content_title
        @content = page.content.html_safe
        @status_response = '200'
        @active_page = URI(request_url).path.split('/').second
        @authenticity_token = form_authenticity_token
        render page.template.location
      else
        @status_response = '404'
        render 'public/404.html'
      end
      
    end
      
  end
  
  def category_slugs category
    
    cat_id = category
    category_container = ""

    begin
    category = Category.find(cat_id)
    category_slug = category.slug
    category_parent = category.parent_category
    category_container = category_slug + "/" + category_container
    cat_id = category_parent
    end while category_parent != 1

    return category_container[0..-2]
    
  end
  
  def sendmessage
  	sleep 0.5
		auth_token = params[:auth_token]
  	name = params[:mpfname]
  	email = params[:mpfemail]
  	subject = params[:mpfsubject]
  	message = params[:mpfmessage]
  	
  	response = Hash.new
  	# form_authenticity_token
  	if name != "" && email != "" && subject != "" && message != ""
  		if auth_token == form_authenticity_token
  			if valid_email? email
					response["code"] = 100
					response["message"] = "Success "
					UserMailer.send_message(name, email, subject, message).deliver
				else
					response["code"] = 904
					response["message"] = "Invalid Email Address "				
				end
				
			else
				response["code"] = 905
				response["message"] = "Invalid Request form "
			end
  	else
			response["code"] = 901
			response["message"] = "Please complete all the fields."
  	end
  	
		render json:response
		
  end
  
  private

	def valid_email?(email)
    valid_email = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    email.present? &&
     (email =~ valid_email)
  end
  
end