class HiringRequestWorker
  include Sidekiq::Worker

  def perform(transaction_id, action)
    HiringRequest.new(transaction_id).send(action)
  end
end
