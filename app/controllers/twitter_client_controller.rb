class TwitterClientController < ApplicationController

  def index
    @tweets = twitter_client.fetch_tweets('j3')
    @mentions = twitter_client.fetch_mentions
  end

  # def create
  #   @tweets = twitter_client.fetch_tweets(params[:twitter_handle])
  # end

  def twitter_client
    @twitter_client ||= TwitterClient.new
  end
end