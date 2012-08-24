class Twit < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable
  acts_as_taggable_on :tags
  scope :by_join_date, order("created_at DESC")
end
