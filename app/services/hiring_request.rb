class HiringRequest
  attr_reader :transaction_id

  def initialize(transaction_id)
    @transaction_id = transaction_id
  end

  def expire
    transaction.update(state: :expired) if transaction.created?
  end

  private
    def transaction
      @transaction ||= Transaction.find(transaction_id)
    end
end
