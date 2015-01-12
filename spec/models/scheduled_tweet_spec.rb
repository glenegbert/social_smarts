RSpec.describe ScheduledTweet, :type => :model do

  let(:scheduled_tweet) { create(:scheduled_tweet) }

  it "creates scheduled tweets" do
    expect(scheduled_tweet).to be_valid
  end

  it "combines scheduled date and scheduled time objects" do
     expect(scheduled_tweet.scheduled_date_and_time_combined).to eq("2015-01-09 21:57:00 UTC")
  end

  #if I have validation in the view layer is it necessary to
  #have them in the model? 

end
