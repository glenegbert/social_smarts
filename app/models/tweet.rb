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
    LocationDataParser.new(tweet).coordinate_from_profile("lat")
  end

  def longitude_from_profile
    LocationDataParser.new(tweet).coordinate_from_profile("lng")
  end

end

class LocationDataParser

  def initialize(tweet)
    @tweet = tweet
  end

  def geolocation_json
    Faraday.get('https://maps.googleapis.com/maps/api/geocode/json?address=' + profile_location + '&key=' + 'AIzaSyCkCtk5jlm5ZiT47hqEsqVlQ5u97k7my4A')
  end

  def profile_location
    @tweet.user.location
  end

  def parsed_geolocation_json
    JSON.parse(geolocation_json.body)
  end

  def coordinate_from_profile(lat_lng)
    get_coordinate(lat_lng) unless no_profile_location?
  end

  def get_coordinate(lat_lng)
    if cached_coordinates?
      cached_coordinates(lat_lng) + offset(0.01, 0.05)
    elsif geocode_exists_for_profile_location?
      cache_coordinates
      coordinates_from_json[lat_lng] + offset(0.01, 0.05)
    end
  end

  def cache_coordinates
    Rails.cache.write(profile_location, coordinates_from_json)
  end

  def coordinates_from_json
    parsed_geolocation_json["results"][0]["geometry"]["location"]
  end

  def profile_location
    @tweet.user.location
  end

  def geocode_exists_for_profile_location?
    parsed_geolocation_json["results"] != []
  end

  def cached_coordinates?
    Rails.cache.read(@tweet.user.location)
  end

  def cached_coordinates(lat_lng)
    Rails.cache.read(@tweet.user.location)[lat_lng]
  end

  def no_profile_location?
    profile_location.instance_of?(Twitter::NullObject)
  end

  def offset (min, max)
    rand * (max-min) + min
  end

end

#where does extra class go?
#what about testing caching?
