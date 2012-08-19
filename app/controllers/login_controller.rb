require 'google/api_client'

class LoginController < ApplicationController
  CLIENT_ID = Yetting.client_id
  CLIENT_SECRET =Yetting.client_secret
  REDIRECT_URI =Yetting.redirect_uri
  SCOPE = Yetting.scope

  before_filter :initialize_client, :only => [:login, :oauth2callback]
  
  def initialize_client
    @client = Google::APIClient.new
    @client.authorization.client_id = CLIENT_ID
    @client.authorization.client_secret = CLIENT_SECRET
    @client.authorization.scope = SCOPE
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.code = params[:code] if params[:code]
  end

  def title
    if session[:token_id]
      redirect_to :action=>'login'
    end
  end

  def login
    if session[:token_id]
      # Load the access token here if it's available
      token_pair = Tokenpair.find_by_id(session[:token_id])
    @client.authorization.update_token!(token_pair.to_hash)
    end
    if @client.authorization.refresh_token && @client.authorization.expired?
      @client.authorization.fetch_access_token!
      token_pair = Tokenpair.find_by_id(session[:token_id])
    token_pair.update_token!(@client.authorization)
    end
    unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
      redirect_to(@client.authorization.authorization_uri.to_s)
    else
      redirect_to(twits_path)
    end
  end

  def oauth2callback
    @client.authorization.fetch_access_token!
    # Persist the token here
    token_pair = Tokenpair.new
    token_pair.update_token!(@client.authorization)
    session[:token_id] = token_pair.id
    redirect_to(twits_path)
  end

  def logout
    if session[:token_id]
      session.delete(:token_id)
      redirect_to root_path
    end
  end
end