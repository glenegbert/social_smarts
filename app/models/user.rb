class User < ActiveRecord::Base
  has_many :tracked_tweets, dependent: :destroy

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first
    user ? user.update_auth_attrs(auth) : create do |user|
                                            user.provider = auth.provider
                                            user.image = auth.info.image
                                            user.uid = auth.uid
                                            user.name = auth.info.name
                                            user.oauth_token = auth.credentials.token
                                            user.oauth_secret = auth.credentials.secret
                                            user.save!
                                          end
  end

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["twitter_consumer_key"]
      config.consumer_secret     = ENV["twitter_api_secret_key"]
      config.access_token        = oauth_token
      config.access_token_secret = oauth_secret
    end
  end

  def tweet(tweet)
    client.update(tweet)
  end

  def fetch_tweets
    @tweets ||= client.home_timeline.map {|t| Tweet.new(t) }
  end

  def fetch_mentions
    @mentions ||= client.mentions_timeline.map { |t| Tweet.new(t) }
  end

  def fetch_followers
    Rails.cache.fetch("twitter_followers_#{uid}", expires_in: 24.hours) do
      @followers = client.followers.map do |f|
        f.class.module_eval { attr_accessor :klout_score}
        f.klout_score = User::klout_score(f.id)
        f
      end
      @followers.sort! { |a,b| b.klout_score <=> a.klout_score }
      @followers.first(20)
    end
  end

  def self.klout_score(twitter_uid)
    KloutScore.new(twitter_uid).fetch_score
  end

  def update_auth_attrs(auth)
    self.provider = auth.provider
    self.uid = auth.uid
    self.name = auth.info.name
    self.oauth_token = auth.credentials.token
    self.oauth_secret = auth.credentials.secret
    save!
    self
  end

  def location
    [client.verify_credentials.location]
  end

end
