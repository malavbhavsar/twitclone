class AddMoreUsers < ActiveRecord::Migration
  
  MORE_USERS = [
    {:username=> "malavbhavsar", :google_id => "112864786461614213018",:google_email => "malav.bhavsar@gmail.com", :google_name => "Malav Bhavsar", :google_pic => "https://lh5.googleusercontent.com/-lotzANSmRjw/AAAAAAAAAAI/AAAAAAAAAAA/ljBYyjeZr4E/photo.jpg"},
    {:username=> "malavbhavsar2", :google_id => "112864786461614213019",:google_email => "malav.bhavsar2@gmail.com", :google_name => "Malav Bhavsar2", :google_pic => "https://lh5.googleusercontent.com/-lotzANSmRjw/AAAAAAAAAAI/AAAAAAAAAAA/ljBYyjeZr4E/photo.jpg"},
  ]

  def up
    MORE_USERS.each do |user|
      User.create!(user)
    end
  end

  def down
    MORE_USERS.each do |user|
      User.find_by_google_id(user[:google_id]).destroy
    end
  end
end
