require 'soundcloud'
require 'sinatra'

def get_tracks(input)
  time = input.to_i * 60000
  client = SoundCloud.new(:client_id => '71d297a0573a3d0e909f86ed41f160c5')
  playlists = client.get('/tracks', :q => 'house chill', :duration => { :from => time - 300000, :to => time + 300000}, :limit => 30)
  uri = playlists.sample["uri"]
  uri
end


get '/' do
  erb :ask
end

get '/list' do
  input = params[:query]
  @tracks = get_tracks(input)
  if get_tracks != nil
    erb :list
  else
    redirect '/'
  end 
end
