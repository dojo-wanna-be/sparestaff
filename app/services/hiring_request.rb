class HiringRequest

  def initialize(id)
    @id = id
  end

  def check_request
    transaction = Transaction.find(@id)
    transaction.update(state: :expired) if transaction.created?
  end
end