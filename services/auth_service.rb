require "securerandom"
require "base64"
require "digest"
require "httparty"
require "json"

class AuthService
  attr_reader :client_id, :client_secret, :redirect_uri

  def initialize(client_id, client_secret, redirect_uri)
    @client_id = client_id
    @client_secret = client_secret
    @redirect_uri = redirect_uri
  end

  def generate_code_verifier
    SecureRandom.urlsafe_base64(64).tr("+/=", "")
  end

  def generate_code_challenge(verifier)
    Base64.urlsafe_encode64(Digest::SHA256.digest(verifier)).tr("+/=", "")
  end

  def generate_state
    SecureRandom.hex(16)
  end

  def authorization_url(code_challenge, state)
    "https://secure.soundcloud.com/authorize" +
      "?client_id=#{client_id}" +
      "&redirect_uri=#{redirect_uri}" +
      "&response_type=code" +
      "&code_challenge=#{code_challenge}" +
      "&code_challenge_method=S256" +
      "&state=#{state}" +
      "&scope=non-expiring"
  end

  def exchange_token(code, code_verifier)
    response = HTTParty.post(
      "https://secure.soundcloud.com/oauth/token",
      headers: {
        "Accept" => "application/json; charset=utf-8",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "authorization_code",
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: redirect_uri,
        code_verifier: code_verifier,
        code: code
      }
    )

    if response.code == 200
      JSON.parse(response.body)
    else
      raise "Failed to obtain access token: #{response.body}"
    end
  end

  def refresh_token(refresh_token)
    response = HTTParty.post(
      "https://secure.soundcloud.com/oauth/token",
      headers: {
        "Accept" => "application/json; charset=utf-8",
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      body: {
        grant_type: "refresh_token",
        client_id: client_id,
        client_secret: client_secret,
        refresh_token: refresh_token
      }
    )

    if response.code == 200
      JSON.parse(response.body)
    else
      raise "Failed to refresh token: #{response.body}"
    end
  end
end
