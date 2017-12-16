class Album < ActiveRecord::Base
  self.primary_key = 'card_uuid'
end
