module PayoutsHelper
  def is_active_menu(menu)
    action_name == menu ? "active": nil
  end

  def is_active_navi(menu, control)
    action_name.eql?(menu) && controller_name.eql?(control) ? "active": nil
  end

  def hirer_weekly_amount(tx)
  	hiring_amount = (tx.amount - tx.tax_withholding_amount + tx.service_fee)
  end

  def total_pay_by_hirer(payment)
    @transaction = Transaction.find_by(id: payment.transaction_id)
    mid_cancel_amount = discount_amount(@transaction, StripeRefundAmount.new(@transaction).already_start_refund_amont)
    if mid_cancel_amount > 0
      new_charge_amount = mid_cancel_amount - @transaction.remaining_tax_withholding(mid_cancel_amount)
      new_charge_amount_with_service_fee = (new_charge_amount + (new_charge_amount * @transaction.commission_from_hirer)).round(2)
    else
      hiring_amount = ( @transaction.amount -  @transaction.tax_withholding_amount +  @transaction.service_fee)
    end
  end

  def total_pay_to_poster(payment)
    @transaction = Transaction.find_by(id: payment.transaction_id)
    mid_cancel_amount = discount_amount(@transaction, StripeRefundAmount.new(@transaction).already_start_refund_amont)
    if mid_cancel_amount > 0
      new_charge_amount = mid_cancel_amount - @transaction.remaining_tax_withholding(mid_cancel_amount)
      new_charge_amount_with_service_fee = (new_charge_amount - (new_charge_amount * @transaction.commission_from_poster)).round(2)
    else
      payment.poster_service_fee
    end
  end

end
 