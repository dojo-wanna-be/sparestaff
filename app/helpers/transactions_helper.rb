module TransactionsHelper
	def price transaction
		if transaction.hirer_id == current_user.id
			transaction.total_amount
		else
			transaction.poster_total_amount
		end
	end
end
