# == Schema Information
#
# Table name: conversations
#
#  id                  :bigint           not null, primary key
#  read                :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :integer
#  receiver_id         :integer
#  sender_id           :integer
#  transaction_id      :integer
#
# Indexes
#
#  index_conversations_on_receiver_sender_employee_listing  (receiver_id,sender_id,employee_listing_id) UNIQUE
#

class Conversation < ApplicationRecord
  has_many :messages, dependent: :destroy
  belongs_to :employee_listing
  belongs_to :sender, foreign_key: :sender_id, class_name: "User"
  belongs_to :receiver, foreign_key: :receiver_id, class_name: "User"
  belongs_to :employee_listing_transaction, class_name: "Transaction", foreign_key: "transaction_id", optional: true
  validates :sender_id, uniqueness: { scope: [:receiver_id, :transaction_id] }
  scope :between, -> (sender_id, receiver_id, transaction_id) do
    where("( conversations.sender_id = ? AND conversations.receiver_id = ? AND conversations.transaction_id = ? ) OR (conversations.sender_id = ? AND conversations.receiver_id = ? AND conversations.transaction_id = ? )", sender_id, receiver_id, transaction_id, receiver_id, sender_id, transaction_id)
  end
  scope :between_listing, -> (sender_id, receiver_id, employee_listing_id) do
    where("( conversations.sender_id = ? AND conversations.receiver_id = ? AND conversations.employee_listing_id = ? ) OR (conversations.sender_id = ? AND conversations.receiver_id = ? AND conversations.employee_listing_id = ? )", sender_id, receiver_id, employee_listing_id, receiver_id, sender_id, employee_listing_id)
  end

  scope :disallow_conversation, -> { where(is_disallowed: true)}
  def opposed_user(user)
    user == receiver ? sender : receiver
  end

  def unread_message(user)
    messages.where(read: false).where.not(sender_id: user.id)
  end

  def unread_msg_count(user)
    unread_message(user).size
  end
end
