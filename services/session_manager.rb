class SessionManager
  def initialize(session, auth_service)
    @session = session
    @auth_service = auth_service
  end

  def store_token_data(token_data)
    @session[:access_token] = token_data["access_token"]
    @session[:refresh_token] = token_data["refresh_token"]
    @session[:expires_at] = Time.now.to_i + token_data["expires_in"]
  end

  def clear_session
    @session.clear
  end

  def authenticated?
    !@session[:access_token].nil?
  end

  def store_oauth_state(state, code_verifier)
    @session[:state] = state
    @session[:code_verifier] = code_verifier
  end

  def get_oauth_state
    @session[:state]
  end

  def get_code_verifier
    @session[:code_verifier]
  end

  def get_access_token
    ensure_fresh_token
  end

  def ensure_fresh_token
    if @session[:expires_at] && Time.now.to_i > @session[:expires_at]
      begin
        token_data = @auth_service.refresh_token(@session[:refresh_token])
        store_token_data(token_data)
      rescue => e
        # If refresh fails, clear session
        clear_session
        return nil
      end
    end

    @session[:access_token]
  end
end
