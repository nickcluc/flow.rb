require 'soundcloud'
require 'sinatra'

def get_tracks(input, music_type)

  time = input.to_i * 60000

  client = SoundCloud.new(
    :client_id => '71d297a0573a3d0e909f86ed41f160c5'
  )

  playlists = client.get(
    '/tracks',
    :q => "#{music_type}",
    :duration =>{
      :from => time - 300000, :to => time + 300000},
    :limit => 50
  )

  uri = playlists.sample["uri"]
  # binding.pry
  uri

end


get '/' do
  erb :ask
end

get '/list' do
  input = params[:query]
  music_type = params[:option]
  if params[:option] == "steve"
    @tracks = "https://api.soundcloud.com/playlists/56155594&amp;color=ff5500&amp;auto_play=false&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false"
  else
    @tracks = get_tracks(input, music_type)
  end
  erb :list
end
