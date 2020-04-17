class AddReasonToStripeRefundAndStripePayment < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_refunds, :reason, :string
    add_column :stripe_refunds, :refund_type, :string, default: "full"
    add_column :stripe_refunds, :stripe_charge_id, :string
    add_column :stripe_refunds, :payment_cycle_start_date, :datetime
    add_column :stripe_refunds, :payment_cycle_end_date, :datetime
    add_column :stripe_payments, :reason, :string
    add_column :stripe_payments, :charge_type, :string, default: "full"
    add_column :stripe_payments, :payment_cycle_start_date, :datetime
    add_column :stripe_payments, :payment_cycle_end_date, :datetime
  end
end
