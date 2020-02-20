class HiringRequest

  def initialize(id)
    @id = id
  end

  def check_request
    transaction = Transaction.find(@id)
    if(transaction.state.eql?('created'))
      transaction.update_attributes(state: :expired)
    end
  end
end