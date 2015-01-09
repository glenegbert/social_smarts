class ScheduledTweetSender

  def self.send_tweets
    ScheduledTweet.all.each do |tweet|
      if tweet.scheduled_date_and_time_combined < Time.zone.now
        user = User.find(tweet.user_id)
        user.client.update(tweet.text)
        tweet.delete
      end
    end
  end

end
