require 'rails_helper'

RSpec.describe ScheduledTweet, :type => :model do

  describe "combines scheduled date and time to create a date_time" do
    scheduled_tweet = ScheduledTweet.create(text: "Yo", user_id: "1", time: "1970-01-01T21:57:00.000Z", date:)
  end

end
