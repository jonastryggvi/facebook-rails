# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  before_filter :current_user
  
  private
  
    def current_user
      # Load the current user once, from facebook cookie
      @current_user ||= user_from_cookie(get_facebook_cookie)
    end  

    def get_facebook_cookie
      # Read cookie, and stop if there is none
      fb_cookie = cookies["fbs_#{FacebookConfig['app_id']}"]
      return unless fb_cookie

      # The cookie is a string of key=value separated with &, which we split into a hash
      fb_info = Hash[fb_cookie.gsub('"','').split('&').collect { |i| i.split('=') }]

      # Get the md5 signature, and verify that the cookie hasn't been tampered with
      fb_signature = fb_info.delete('sig')    
      md5 = Digest::MD5.hexdigest(fb_info.sort.collect { |i| i.join('=') }.join + FacebookConfig['app_secret'])
      if fb_signature != md5
        logger.warn "MD5 sum incorrect for #{request.remote_ip}"
        return nil
      end    
      fb_info # return the values of the cookie
    end
    
    def user_from_cookie(cookie_info)
      return unless cookie_info

      user = User.find_by_facebook_uid(cookie_info['uid'])
      user ||= User.new

      user.access_token = cookie_info['access_token']

      # If the access_token has changed, then this is either a new user 
      # or a user that just logged in, so we reload the users data
      if user.access_token_changed?
        fb_info = user_from_facebook(cookie_info)
        return unless fb_info
        user.update_attributes(fb_info.slice(*User.column_names))      
      end

      user  
    end

    def user_from_facebook(cookie_info)
      # Create a AccessToken based on the users access_token from the cookie
      facebook = OAuth2::AccessToken.new(FacebookGraph, cookie_info['access_token'])

      begin
        # Fetch user data from Facebook
        fb_info = JSON.parse(facebook.get('/me'))
        # Check if the access token is for the given user
        raise "Received wrong user from facebook" unless fb_info['id'] == cookie_info['uid']
        fb_info['facebook_uid'] = fb_info.delete('id')
        return fb_info
      rescue Exception => exc
        logger.warn "Token verification failed for #{cookie_info.inspect} from #{request.remote_ip}, reason: #{exc}"
      end      
    end

end
