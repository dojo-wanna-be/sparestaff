class HiringRequestWorker
  include Sidekiq::Worker

  def perform(transaction_id)
    HiringRequest.new(transaction_id).check_request
  end
end