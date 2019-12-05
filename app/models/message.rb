# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  conversation_id :bigint
#  sender_id       :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#
# Foreign Keys
#
#  fk_rails_...  (conversation_id => conversations.id)
#

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
end
