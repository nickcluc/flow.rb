require "httparty"
require "json"

class SoundcloudAPI
  BASE_URL = "https://api.soundcloud.com"

  def initialize(token)
    @token = token
  end

  def get(path, params = {})
    url = "#{BASE_URL}#{path}"
    headers = {
      "Accept" => "application/json; charset=utf-8"
    }

    # Add authorization header if we have a token
    headers["Authorization"] = "Bearer #{@token}" if @token

    response = HTTParty.get(url,
      headers: headers,
      query: params
    )

    JSON.parse(response.body)
  end

  def get_current_user
    get("/me")
  end

  def get_user_playlists(limit = 50)
    user = get_current_user
    get("/users/#{user["id"]}/playlists", { limit: limit })
  end

  def get_playlist(playlist_id)
    get("/playlists/#{playlist_id}")
  end

  def search_tracks(query, options = {})
    get("/tracks", { q: query }.merge(options))
  end

  def get_tracks_by_duration(query, duration_minutes, variance_minutes = 5)
    time = duration_minutes.to_i * 60000
    variance = variance_minutes * 60000

    search_tracks(query, {
      duration: {
        from: time - variance,
        to: time + variance
      },
      limit: 50
    })
  end
end
