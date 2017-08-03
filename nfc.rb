require 'nfc'


ctx = NFC::Context.new
dev = ctx.open nil

loop do
  card_uuid = dev.poll.to_s
  if card_uuid != '-90'
     p "Card: #{card_uuid}"
  end
end
