require 'dotenv'

Dotenv.load

module FlowApp
  class Config
    attr_reader :client_id, :client_secret, :redirect_uri

    def initialize
      @client_id = ENV["SOUNDCLOUD_CLIENT_ID"] || "71d297a0573a3d0e909f86ed41f160c5"
      @client_secret = ENV["SOUNDCLOUD_CLIENT_SECRET"] || "YOUR_CLIENT_SECRET"
      @redirect_uri = ENV["REDIRECT_URI"] || "http://localhost:4567/callback"
    end
  end
end
