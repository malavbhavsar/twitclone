class TwitsController < ApplicationController
  def index
    @twits = Twit.all
  end
end
