class InboxesController < ApplicationController
    before_action :find_transaction, only: [:show]
    def index
    end

    def show
        @listing = @transaction.employee_listing
    end

    private

    def find_transaction
        @transaction = Transaction.find_by(id: params[:id])
    end
end
