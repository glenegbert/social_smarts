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
    parser.coordinate_from_profile("lat")
  end

  def longitude_from_profile
    parser = LocationDataParser.new(tweet)
    parser.coordinate_from_profile("lng")
  end

end

class LocationDataParser

  def initialize(tweet)
    @tweet = tweet
  end

  def location_data
    unless location_missing?
      Faraday.get('https://maps.googleapis.com/maps/api/geocode/json?address=' + @tweet.user.location + '&key=' + 'AIzaSyCkCtk5jlm5ZiT47hqEsqVlQ5u97k7my4A')
    end
  end

  def parsed_location_data
    JSON.parse(location_data.body) if location_data
  end

  def coordinate_from_profile(lat_lng)
    unless location_missing?
      if cached_coordinates?
        cached_coordinate(lat_lng) + offset(0.01, 0.05)
      elsif geocode_exists_for_profile_location?
        Rails.cache.write(profile_location, coordinates)
        coordinates[lat_lng] + offset(0.01, 0.05)
      end
    end
  end

  def coordinates
    parsed_location_data["results"][0]["geometry"]["location"]
  end

  def profile_location
    @tweet.user.location
  end

  def geocode_exists_for_profile_location?
    parsed_location_data["results"] != []
  end

  def cached_coordinates?
    Rails.cache.read(@tweet.user.location)
  end

  def cached_coordinate(lat_lng)
    Rails.cache.read(@tweet.user.location)[lat_lng]
  end

  def location_missing?
    @tweet.user.location.instance_of?(Twitter::NullObject)
  end

  def offset (min, max)
    rand * (max-min) + min
  end

end
