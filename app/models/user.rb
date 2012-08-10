class User < ActiveRecord::Base
  has_many :twits
end
