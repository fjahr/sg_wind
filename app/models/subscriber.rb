class Subscriber < ApplicationRecord
  include Facebook::Messenger

  validates :facebook_id, uniqueness: true

  def self.notify_all
    Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

    Subscriber.all.each do |s|
      Bot.deliver({recipient: {'id': s.facebook_id},
                   message: {text: "Wind at East Coast Parkway has gone over 20km/h!"}
      }, access_token: ENV["ACCESS_TOKEN"])
    end
  end
end
