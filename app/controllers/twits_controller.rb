require 'google/api_client'
require 'acts-as-taggable-on'

class TwitsController < ApplicationController
  include Twitter::Extractor

  CLIENT_ID = Yetting.client_id
  CLIENT_SECRET =Yetting.client_secret
  REDIRECT_URI =Yetting.redirect_uri

  before_filter :check_session, :except => [:current_user]
  def check_session
    if !@user_details
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
  end

  def index
    @twits = Twit.order('created_at DESC').all
  end

  def my_timeline
    #Twit.find_by_sql("SELECT * from twits where twits.user_id="+)
    array = Array.new
    @twits = current_user.twits
    current_user.follow_instances.each do |x| (array+=x.followed.twits) end
    @twits += array
    @twits += Twit.tagged_with(current_user.username, :on => :usernames)
    @twits.sort! {|x,y| y.created_at<=>x.created_at}
  #not sure if this works correctly!
  end
  
  

  def user_timeline
    @user = User.find_by_username(params[:username])
    if !@user
      raise ActionController::RoutingError.new('Not Found')
    end
    if @user == current_user
      redirect_to(:action=> 'my_timeline')
    end

    array = Array.new
    @twits = @user.twits
    @user.follow_instances.each do |x| (array+=x.followed.twits) end
    @twits += array
    @twits += Twit.tagged_with(@user.username, :on => :usernames)
    @twits.sort! {|x,y| y.created_at<=>x.created_at} #not sure if this works correctly!
  end

  def create
    #nasty hack at pic
    # will fix later https://groups.google.com/forum/#!topic/sqlite3-ruby/SGRQE_2MZ8I%5B1-25%5D    
    
    user = User.where(:google_id => @user_details['id']).first_or_create({ 
      :username=> suggest_username(@user_details['name'].gsub(/[^a-zA-Z0-9]/, "")), 
      :google_email => @user_details['email'],
      :google_name=> @user_details['name'], 
      :google_pic=> if @user_details['picture'] then @user_details['picture']
      else 'https://ssl.gstatic.com/s2/profiles/images/silhouette96.png' end})
    twit = Twit.new({:status=>params['twit'], :user_id=>user['id']})
    twit.tag_list = extract_hashtags(params['twit']).uniq.join(",")
    twit.username_list = extract_mentioned_screen_names(params['twit']).uniq.join(",")
    twit.save
    redirect_to :action=>'index'
  end

  def follow
    FollowTable.create!(:followed_id=>User.find_by_username(params[:username]).id,:follower_id=>current_user.id)
    redirect_to :back
  end

  def unfollow
    FollowTable.find_by_follower_id_and_followed_id(current_user.id,User.find_by_username(params[:username]).id).destroy
    redirect_to :back
  end

  def current_user
    User.find_by_google_id(@user_details['id'])
  end
  
  def tag
    @twits = Twit.tagged_with(params['taglabel'], :on => :tags).by_join_date
  end
  
  def suggest_username(username)
    if !User.find_by_username(username)
      return username
    end
    count = 0
    while User.find_by_username(username+count.to_s)
      count+=1
    end
    return username+count.to_s
  end
end