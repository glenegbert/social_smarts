class ScheduledTweet < ActiveRecord::Base

  def scheduled_date_and_time_combined
    time = self.time[10..-1]
    date = self.date[0..9]
    date_time = date + time
    Time.parse(date_time)
  end

end
