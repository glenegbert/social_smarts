class TwitterClientController < ApplicationController
  respond_to :json
  # before_filter :require_sigin!

  def index
    if current_user
      @tweets = current_user.fetch_tweets
      @mentions = current_user.fetch_mentions
    end
  end

  def create
    current_user.tweet(params[:tweet])
    redirect_to root_path
  end
end
