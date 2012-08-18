require 'google/api_client'

class TwitsController < ApplicationController

  CLIENT_ID = '571308755426.apps.googleusercontent.com'
  CLIENT_SECRET ='D9O7PKMwPCZwrOifsTwR6GC9'
  REDIRECT_URI ='http://localhost:3000/oauth2callback'

  # before_filter :check_session, :only => [:index]
  def check_session

    @client = Google::APIClient.new
    @client.authorization.client_id = CLIENT_ID
    @client.authorization.client_secret = CLIENT_SECRET
    @client.authorization.scope = ['https://www.googleapis.com/auth/userinfo.profile','https://www.googleapis.com/auth/userinfo.email']
    @client.authorization.redirect_uri = REDIRECT_URI
    @client.authorization.code = params[:code] if params[:code]

    unless session[:token_id]
      redirect_to(login_path) and return
    end

    token_pair = Tokenpair.find_by_id(session[:token_id])
    unless token_pair
      redirect_to(login_path) and return
    end
    @client.authorization.update_token!(token_pair.to_hash)

    if !@client.authorization.access_token || @client.authorization.expired?
      redirect_to(login_path) and return
    end

    @oauth2 = @client.discovered_api('oauth2','v2')
    @user_details = @client.execute(:api_method=>@oauth2.userinfo.v2.me.get).data.to_hash
  end

  def index
    if !@user_details
      check_session
    end
    @twits = Twit.order('created_at DESC').all
  end
  
  def my_timeline
    if !@user_details
      check_session
    end
    #Twit.find_by_sql("SELECT * from twits where twits.user_id="+)
    array = Array.new
    FollowTable.find_all_by_follower_id(User.find_by_google_id(@user_details['id']).id).each do |x| (array<<x.followed_id) end
    
    @twits = (User.find_by_google_id(@user_details['id']).twits + 
    Twit.find_all_by_user_id(array))
  end
  
  def user_timeline
    if !@user_details
      check_session
    end
    @user = User.find(params[:id])
    if @user.google_id == @user_details['id']
      redirect_to(:action=> 'my_timeline')
    end
    
    array = Array.new
    FollowTable.find_all_by_follower_id(@user.id).each do |x| (array<<x.followed_id) end
    
    @twits = (@user.twits + 
    Twit.find_all_by_user_id(array))
  end

  def create
    if !@user_details
      check_session
    end
    #nasty hack at pic
    # will fix later https://groups.google.com/forum/#!topic/sqlite3-ruby/SGRQE_2MZ8I%5B1-25%5D
    user = User.where(:google_id => @user_details['id']).first_or_create({:google_email => @user_details['email'],
    :google_name=> @user_details['name'], :google_pic=> if @user_details['picture'] then @user_details['picture']
      else 'https://ssl.gstatic.com/s2/profiles/images/silhouette96.png' end})
    Twit.create!({:status=>params['twit'], :user_id=>user['id']})
    redirect_to :action=>'index'
  end
  
  def follow
    if !@user_details
      check_session
    end
    FollowTable.create!(:followed_id=>params[:id],:follower_id=>User.find_by_google_id(@user_details['id']).id)
    redirect_to :back
  end
  
  def unfollow
    if !@user_details
      check_session
    end
    FollowTable.find_by_follower_id_and_followed_id(User.find_by_google_id(@user_details['id']).id,params[:id]).destroy
    redirect_to :back
  end

end
