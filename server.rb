require 'soundcloud'
require 'sinatra'

def get_tracks(input)
  time = input.to_i * 60000

  client = SoundCloud.new(
    :client_id => ENV['SOUNDCLOUD_API_ID']
  )

  playlists = client.get(
    '/tracks',
    :q => 'house chill',
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
  @tracks = get_tracks(input)
  erb :list
end
