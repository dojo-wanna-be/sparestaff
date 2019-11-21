class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def stripe_account
		unless request.get?
			account = StripeAccount.new(params, current_user, request.remote_ip).create
      if account.present?
        current_user.update_attribute(:stripe_account_id, account.id)
        flash[:notice] = "Account Created Successfully"
        redirect_to root_path
      else
        flash[:error] = "Invalid Request"
        redirect_to stripe_account_payouts_path
      end
		end
	end


	def update
    new_card = params[:stripeToken]
    begin
      last = AddNewCardOnStripe.new(user: current_user, new_card: params[:stripeToken]).update
      # current_user.update(last_4_of_card_on_file: last.last4, card_type: last.brand)
      redirect_to root_path
    rescue
      redirect_to root_path
    end
  end
end
