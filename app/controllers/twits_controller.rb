class TwitsController < ApplicationController
  
  CLIENT_ID = '571308755426.apps.googleusercontent.com'
  CLIENT_SECRET ='D9O7PKMwPCZwrOifsTwR6GC9'
  REDIRECT_URI ='http://localhost:3000/oauth2callback'
  
  before_filter :check_session
  
  def check_session

    @client = Google::APIClient.new
    @client.authorization.client_id = CLIENT_ID
    @client.authorization.client_secret = CLIENT_SECRET
    @client.authorization.scope = ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.code = params[:code] if params[:code]
    
    unless session[:token_id]
      redirect_to(login_path)
    end
    
    token_pair = Tokenpair.find_by_id(session[:token_id])
    @client.authorization.update_token!(token_pair.to_hash)
    
    if !@client.authorization.access_token || @client.authorization.expired?
      redirect_to(login_path)
    end
    
    @oauth2 = @client.discovered_api('oauth2','v2')
    @user_details = @client.execute(:api_method=>@oauth2.userinfo.v2.me.get).data.to_hash
  end
  
  def index
    @twits = Twit.all
  end
  
  def create
    @user = User.where(:google_id => @user_details['id']).first_or_create(:google_email => @user_details['email'], :google_name=> @user_details['name'], :google_pic=> @user_details['picture'])
    debugger
    Twit.create!({:status=>params['twit'], :user_id=>@user['id']})
    redirect_to :action=>'index'
  end
end
