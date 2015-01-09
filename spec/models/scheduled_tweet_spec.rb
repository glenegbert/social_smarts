require 'rails_helper'

RSpec.describe ScheduledTweet, :type => :model do

  it "creates scheduled tweets" do
    scheduled_tweet = ScheduledTweet.create(text: "Yo", user_id: "1", time: "1970-01-01T21:57:00.000Z",
                                            date: "2015-01-09T17:51:53.837Z")
    expect(scheduled_tweet).to be_valid

  end


  it "combines scheduled date and scheduled time objects" do
   scheduled_tweet = ScheduledTweet.create(text: "Yo", user_id: "1", time: "1970-01-01T21:57:00.000Z",
                                           date: "2015-01-09T17:51:53.837Z")

     expect(scheduled_tweet.scheduled_date_and_time_combined).to eq("2015-01-09 21:57:00 UTC")
  end

end
