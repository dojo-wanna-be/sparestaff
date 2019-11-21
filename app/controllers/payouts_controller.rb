class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def stripe_account
		unless request.get?
			binding.pry
			StripeAccount.new(params, current_user).create
		end
	end
end
