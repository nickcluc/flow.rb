require 'soundcloud'
require 'sinatra'
# require 'pry'

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
  @tracks = get_tracks(input, music_type)
  erb :list
end
