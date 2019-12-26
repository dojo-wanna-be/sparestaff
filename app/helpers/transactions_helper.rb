module TransactionsHelper
	def price transaction
		if transaction.hirer_id == current_user.id
			transaction.total_amount
		else
			transaction.poster_total_amount
		end
	end

	def address_1
		@transaction.address.present? ? @transaction.address.address_1 : @company.address_1
	end

	def address_2
		@transaction.address.present? ? @transaction.address.address_2 : @company.address_2
	end

	def city
		@transaction.address.present? ? @transaction.address.city : @company.city
	end

end
