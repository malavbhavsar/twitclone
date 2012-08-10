class AddMoreTwits < ActiveRecord::Migration
  
    MORE_TWITS = [
    {:status=>"gg",:user_id=>1},
    {:status=>"gg2",:user_id=>1},
    {:status=>"gg3",:user_id=>1},
    {:status=>"gg4",:user_id=>2},
    ]
  
  def up
    MORE_TWITS.each do |twit|
      Twit.create!(twit)
    end
  end

  def down
    Twit.all.each do |twit|
      twit.destroy
    end
  end
end
