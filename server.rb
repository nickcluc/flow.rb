require 'soundcloud'
require 'sinatra'
require 'sinatra/reloader'
require 'pry'

def get_tracks(input, music_type)

  time = input.to_i * 60000

  client = SoundCloud.new(
    :client_id => ENV['SOUNDCLOUD_API_ID']
  )

  playlists = client.get(
    '/tracks',
    :q => "#{music_type}",
    :duration =>{
      :from => time - 300000, :to => time + 300000},
    :limit => 50
  )

  uri = playlists.sample["uri"]

  uri

end


get '/' do
  erb :ask
end

get '/list' do
  input = params[:query]
  music_type = params[:option]
  @tracks = get_tracks(input, music_type)
  erb :list
end
