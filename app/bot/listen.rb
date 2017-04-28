require "facebook/messenger"
include Facebook::Messenger
Facebook::Messenger::Subscriptions.subscribe(access_token: ENV["ACCESS_TOKEN"])

# message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
# message.sender      # => { 'id' => '1008372609250235' }
# message.sent_at     # => 2016-04-22 21:30:36 +0200
# message.text        # => 'Hello, bot!'

Bot.on :message do |message|
  if message.text == "subscribe"
    Subscriber.new(facebook_id: message.sender['id']).save

    Bot.deliver({
      recipient: message.sender,
      message: {
        text: "You are now subscribed."
      }
    }, access_token: ENV["ACCESS_TOKEN"])
  elsif message.text == "unsubscribe"
    Subscriber.find_by(facebook_id: message.sender['id']).destroy

    Bot.deliver({
      recipient: message.sender,
      message: {
        text: "You are now unsubscribed."
      }
    }, access_token: ENV["ACCESS_TOKEN"])
  else
    Bot.deliver({
      recipient: message.sender,
      message: {
        text: "Say 'subscribe' to subscribe for wind updates and 'unsubscribe' for unsubscribing."
      }
    }, access_token: ENV["ACCESS_TOKEN"])
  end
end
