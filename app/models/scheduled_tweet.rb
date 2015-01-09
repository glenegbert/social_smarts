class ScheduledTweet < ActiveRecord::Base

  def scheduled_date_and_time_combined
    Time.parse(scheduled_date[0..9] + scheduled_time[10..-1])
  end

  def scheduled_time
    self.time
  end

  def scheduled_date
    self.date
  end

end
