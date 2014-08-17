class Traffic < ActiveRecord::Base
  default_scope order('created_at DESC')
  def date_visited
    #self.created_at.to_time.strftime('%b %d, %Y at %I:%M %p')
    if self.created_at.to_date == Date.today
      'Today ' + self.created_at.to_time.strftime('%-I:%M %p')
    elsif self.created_at.to_date == Date.yesterday
       'Yesterday ' + self.created_at.to_time.strftime('%-I:%M %p')
    else 
      self.created_at.to_time.strftime('%b %d, %Y at %-I:%M %p')
    end
  end
  
end
