class FrontpageController < ApplicationController
  layout false
  def index
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

end