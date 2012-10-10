class Twit < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :tags, :usernames
  scope :by_join_date, order("created_at DESC")
  self.per_page = 10
end
