class User < ActiveRecord::Base

  has_many :follow_instances, :foreign_key => "follower_id",
      :class_name => "FollowTable"

  has_many :twits

end
