# Flow.rb

Flow.rb helps you get into a flow state while coding by providing music from SoundCloud timed to your work session.

## Setup

1. Register an application on SoundCloud Developer Portal
2. Set up environment variables:

   ```
   SOUNDCLOUD_CLIENT_ID=your_client_id
   SOUNDCLOUD_CLIENT_SECRET=your_client_secret
   REDIRECT_URI=http://localhost:4567/callback
   ```

3. Install dependencies:

   ```
   bundle install
   ```

4. Run the application:

   ```
   ruby server.rb
   ```

5. Visit http://localhost:4567 in your browser

## Architecture

The application is built using the following components:

- **server.rb**: Main Sinatra application with routes and controllers
- **config/initializer.rb**: Configuration loader for environment variables
- **services/**: Directory containing service objects
  - **auth_service.rb**: Handles OAuth authentication with SoundCloud
  - **soundcloud_api.rb**: Manages API requests to SoundCloud
  - **track_service.rb**: Service for finding and managing tracks
  - **session_manager.rb**: Manages user sessions and token refreshing

## OAuth Flow

This application uses OAuth 2.0 with PKCE for SoundCloud authentication:

1. User visits the application and is redirected to login
2. Application generates PKCE code verifier and challenge
3. User is redirected to SoundCloud to authorize the application
4. SoundCloud redirects back with an authorization code
5. Application exchanges the code for access and refresh tokens
6. Application uses the access token for API calls
7. When the token expires, it's refreshed automatically

## Features

- Select music genre: Chill House, Rap Flow, Jazz, Classical, or a curated playlist
- Specify work duration and get tracks of similar length
- Play your own SoundCloud playlists
- Quick access to your recently played playlists
- Automatic authentication with SoundCloud
- Token refresh when expired

## User Playlists

After authenticating with SoundCloud, you can:

1. Select "My SoundCloud Playlist" from the dropdown
2. Choose from your list of playlists
3. Enjoy your own curated music while coding

The application will fetch up to 50 of your playlists. The 5 most recent playlists will be available for quick access on the player page.
