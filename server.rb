require "sinatra"
require "sinatra/contrib"
require_relative "config/initializer"
require_relative "services/auth_service"
require_relative "services/soundcloud_api"
require_relative "services/track_service"
require_relative "services/session_manager"

# Enable sessions to store OAuth data
enable :sessions
set :session_secret, SecureRandom.hex(32)

# Load configuration
config = FlowApp::Config.new

# Initialize services
before do
  @auth_service = AuthService.new(
    config.client_id,
    config.client_secret,
    config.redirect_uri
  )
  @session_manager = SessionManager.new(session, @auth_service)

  if @session_manager.authenticated?
    token = @session_manager.get_access_token
    @api = SoundcloudAPI.new(token) if token
    @track_service = TrackService.new(@api) if @api
  end
end

# Home route - show main page or login
get "/" do
  if @session_manager.authenticated?
    # Get user's playlists for the form
    begin
      @user_playlists = @api.get_user_playlists
    rescue => e
      @user_playlists = []
      @playlist_error = "Could not load your playlists: #{e.message}"
    end
    erb :ask
  else
    redirect "/login"
  end
end

# Login route - initiates OAuth flow
get "/login" do
  # Generate PKCE code verifier and state
  code_verifier = @auth_service.generate_code_verifier
  state = @auth_service.generate_state

  # Store in session for verification later
  @session_manager.store_oauth_state(state, code_verifier)

  # Generate code challenge from verifier
  code_challenge = @auth_service.generate_code_challenge(code_verifier)

  # Redirect to SoundCloud authorization
  auth_url = @auth_service.authorization_url(code_challenge, state)
  redirect auth_url
end

# OAuth callback handler
get "/callback" do
  # Verify state parameter to prevent CSRF
  if params[:state] != @session_manager.get_oauth_state
    halt 400, "Invalid state parameter. Possible CSRF attack."
  end

  begin
    # Exchange authorization code for access token
    token_data = @auth_service.exchange_token(
      params[:code],
      @session_manager.get_code_verifier
    )

    # Store tokens in session
    @session_manager.store_token_data(token_data)

    # Redirect to the app
    redirect "/"
  rescue => e
    halt 400, e.message
  end
end

# Logout route
get "/logout" do
  @session_manager.clear_session
  redirect "/"
end

# Play user's playlist directly
get "/play_playlist/:playlist_id" do
  redirect "/login" unless @session_manager.authenticated?

  playlist_id = params[:playlist_id]

  # Get playlist details to display
  @playlist_info = @track_service.get_playlist_details(playlist_id)

  # Get user playlists for quick access
  begin
    @user_playlists = @api.get_user_playlists
  rescue => e
    @user_playlists = []
  end

  @tracks = @track_service.get_playlist_url(playlist_id)

  erb :list
end

# List tracks route
get "/list" do
  redirect "/login" unless @session_manager.authenticated?

  input = params[:query]
  music_type = params[:option]

  # Get user playlists for quick access
  begin
    @user_playlists = @api.get_user_playlists
  rescue => e
    @user_playlists = []
  end

  if music_type == "my_playlist" && params[:playlist_id]
    # User selected one of their playlists
    playlist_id = params[:playlist_id]
    @tracks = @track_service.get_playlist_url(playlist_id)

    # Get playlist details to display
    @playlist_info = @track_service.get_playlist_details(playlist_id)
  elsif music_type == "steve"
    # For the special "steve" option, we use a fixed playlist
    @tracks = "https://soundcloud.com/playlists/56155594"
  else
    @tracks = @track_service.find_track_by_duration(music_type, input)
  end

  erb :list
end
