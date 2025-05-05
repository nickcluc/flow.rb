class TrackService
  def initialize(api)
    @api = api
  end

  def find_track_by_duration(music_type, duration_minutes)
    tracks = @api.get_tracks_by_duration(music_type, duration_minutes)

    if tracks && !tracks.empty?
      track = tracks.sample
      return track["permalink_url"]
    else
      return "https://soundcloud.com/track/293" # Default track if none found
    end
  end

  def get_playlist_url(playlist_id)
    "https://soundcloud.com/playlists/#{playlist_id}"
  end

  def get_playlist_details(playlist_id)
    @api.get_playlist(playlist_id)
  rescue => e
    nil
  end
end
