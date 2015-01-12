class Tweet
  include Twitter::Autolink
  attr_reader :tweet

  def initialize(tweet)
    @tweet = tweet
  end

  def text
    auto_link(tweet.text, target_blank: true)
  end

  def user
    tweet.user
  end

  def created_at
    tweet.created_at
  end

  def user_klout_score
    @klout ||= KloutScore.new(user.id).fetch_score
  end

  def latitude_from_profile
    parser = LocationDataParser.new(tweet)
    parser.latitude_from_profile
  end

  def longitude_from_profile
    parser = LocationDataParser.new(tweet)
    parser.longitude_from_profile
  end

end

class LocationDataParser

  def initialize(tweet)
    @tweet = tweet
  end

  def location_data
    unless @tweet.user.location.instance_of? Twitter::NullObject
      Faraday.get('https://maps.googleapis.com/maps/api/geocode/json?address=' + @tweet.user.location + '&key=' + 'AIzaSyCkCtk5jlm5ZiT47hqEsqVlQ5u97k7my4A')
    end
  end

  def parsed_location_data
    JSON.parse(location_data.body) if location_data
  end

  def latitude_from_profile
    unless @tweet.user.location.instance_of?(Twitter::NullObject)
      coordinates = Rails.cache.read(@tweet.user.location)
      if coordinates
        coordinates["lat"] + offset(0.01, 0.05)
      elsif parsed_location_data["results"] != []
        coordinates = parsed_location_data["results"][0]["geometry"]["location"]
        Rails.cache.write(@tweet.user.location, coordinates)
        coordinates["lat"] + offset(0.01, 0.05)
      end
    end
  end

  def longitude_from_profile
    unless @tweet.user.location.instance_of?(Twitter::NullObject)
      coordinates = Rails.cache.read(@tweet.user.location)
      if coordinates
        coordinates["lng"]
      elsif parsed_location_data["results"] != []
        coordinates = parsed_location_data["results"][0]["geometry"]["location"]
        Rails.cache.write(@tweet.user.location, coordinates)
        coordinates["lng"]
      end
    end
  end

  def offset (min, max)
    rand * (max-min) + min
  end

end
