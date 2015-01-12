require 'ostruct'

RSpec.describe Tweet do
  let(:tweet)  do
    Tweet.new(OpenStruct.new(text: "a tweet",
    user: OpenStruct.new(screen_name: "lukeaiken", id: 6253282, location: "Denver"),
    created_at: "today"))
  end
  let(:tweet2) do
    Tweet.new(OpenStruct.new(text: "a tweet",
    user: OpenStruct.new(screen_name: "lukeaiken", id: 6253282, location: Twitter::NullObject.new),
    created_at: "today"))
  end

  it "has text" do
    expect(tweet.text).to eq "a tweet"
  end

  it "has a user" do
    expect(tweet.user.screen_name).to eq "lukeaiken"
  end

  it "has a created_at" do
    expect(tweet.created_at).to eq "today"
  end

  it "gives the user's klout score" do
    VCR.use_cassette('klout') do
      expect(tweet.user_klout_score).to be_a Integer
    end
  end

  it "returns a message when klout score cannot be found" do
    tweet.user.id = ""
    VCR.use_cassette('klout_error') do
      expect(tweet.user_klout_score).to be_a String
    end
  end

  it 'gives a latitude for a tweet' do
    VCR.use_cassette('geocode') do
      expect(tweet.latitude_from_profile).to be_a Float
    end
  end

  it 'does not give a latitude for a tweet with an undefined user location' do
    expect(tweet2.latitude_from_profile).to be(nil)
  end

  it 'gives a longitude for a tweet' do
    VCR.use_cassette('geocode') do
      expect(tweet.longitude_from_profile).to be_a Float
    end
  end

  it 'does not give a longitude for a tweet with an undefined user location' do
    expect(tweet2.longitude_from_profile).to be(nil)
  end

end
