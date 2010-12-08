require 'facebook_oauth/objects'

module FacebookOAuth
  class Client

    def initialize(options = {})
      defaults_from_config_file
      @application_id = options[:application_id] || @settings[:app_id]
      @application_secret = options[:application_secret] || @settings[:secret]
      @callback = options[:callback]
      @token = options[:token]
    end
  
    def authorize_url(options = {})
      options[:scope] ||= 'offline_access,publish_stream'
      consumer.web_server.authorize_url(
        :redirect_uri => options[:callback] || @callback,
        :scope => options[:scope]
      )
    end
    
    def authorize(options = {})
      @access_token ||= consumer.web_server.get_access_token(
        options[:code],
        :redirect_uri => options[:callback] || @callback
      )
      @token = @access_token.token
      @access_token
    end
    
    private
      def consumer
        @consumer ||= OAuth2::Client.new(
          @application_id,
          @application_secret,
          { :site=>"https://graph.facebook.com" }
        )
      end

      def access_token
        OAuth2::AccessToken.new(consumer, @token)
      end
      
      def _get(url)
        oauth_response = access_token.get(url)
        JSON.parse(oauth_response)
      end

      def _post(url, params={}, headers={})
        oauth_response = access_token.post(url, params, headers)
        JSON.parse(oauth_response)
      end

      def _delete(url)
        oauth_response = access_token.delete(url)
        JSON.parse(oauth_response)
      end

      def defaults_from_config_file
        path = "#{Rails.root}/config/facebook.yml"
        @settings = {}
        if File.exist?(path)
          @settings = YAML::load(File.open(path))[Rails.env.to_s]
        end
      end
  end
end
   
