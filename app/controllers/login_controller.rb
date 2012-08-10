require 'google/api_client'

class LoginController < ApplicationController
  CLIENT_ID = '571308755426.apps.googleusercontent.com'
  CLIENT_SECRET ='D9O7PKMwPCZwrOifsTwR6GC9'
  REDIRECT_URI ='http://localhost:3000/oauth2callback'
  
  before_filter :login
  
  def login
    @client = Google::APIClient.new
    @client.authorization.client_id = CLIENT_ID
    @client.authorization.client_secret = CLIENT_SECRET
    @client.authorization.scope = ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.code = params[:code] if params[:code]
    if session[:token_id]
    # Load the access token here if it's available
      token_pair = Tokenpair.find_by_id(session[:token_id])
      @client.authorization.update_token!(token_pair.to_hash)
    end
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
    end
    @oauth2 = @client.discovered_api('oauth2','v2')
    unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
      redirect_to(@client.authorization.authorization_uri.to_s)
    end
  end

  def oauth2callback
    @client.authorization.fetch_access_token!
    # Persist the token here
    token_pair = if session[:token_id]
      Tokenpair.find_by_id(session[:token_id])
    else
      Tokenpair.new
    end
    token_pair.update_token!(@client.authorization)
    session[:token_id] = token_pair.id
    print @client.execute(:api_method=>@oauth2.userinfo.v2.me.get).data.to_hash
    debugger
    redirect_to(twits_path)
  end
end