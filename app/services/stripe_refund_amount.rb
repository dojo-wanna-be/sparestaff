class StripeRefundAmount
  def initialize(transaction)
    @transaction = transaction    
  end

  def stripe_refund_ammount
    if @transaction.stripe_payments.present?
      #if @transaction.stripe_payments.last.capture == "true"
      hirer = @transaction.hirer
      poster = @transaction.poster
      diff = (Date.today - @transaction.start_date).to_i
      cutsomer_id = customer = Stripe::Customer.retrieve(hirer.stripe_info.stripe_customer_id).id
      @charge_id = @transaction.stripe_payments.last.stripe_charge_id
      # @amount = if (@transaction.state.eql?("created") && @transaction.created_at + 2.days <= Date.today) || (@transaction.state.eql?("accepted") && @transaction.start_date - 1 <= Date.today)
      #     @transaction.hirer_weekly_amount
      #   else
      #     @transaction.hirer_weekly_amount
      #   end
      if @transaction.start_date > Date.today
        @amount = @transaction.amount - @transaction.tax_withholding_amount + @transaction.service_fee
        stripe_refund = StripeRefund.create!(transaction_id: @transaction.id, amount: @amount, tax_withholding_amount: @transaction.tax_withholding_amount, service_fee: @transaction.service_fee, stripe_charge_id: @charge_id, status: "failed")
        begin
          refund = Stripe::Refund.create({
            charge: @charge_id,
            amount: (@amount*100).to_i,
          })
          stripe_refund.update(refund_id: refund.id, status: refund.status, reason: refund.reason)
        rescue => e
          stripe_refund.update(reason: e.error.message)
        end
        StripeRefundReceipt.create!(transaction_id: @transaction.id, amount: @amount, tax_withholding_amount: @transaction.tax_withholding_amount, service_fee: @transaction.service_fee)
      elsif @transaction.start_date == Date.today
        @amount = @transaction.amount + @transaction.amount * 0.03
        day = Date.today.strftime("%A").downcase
        service_fee = @transaction.service_fee < 0.50 ? 0.50 : @transaction.service_fee
        if @transaction.bookings.where(day: day).blank?
          refund = Stripe::Refund.create({
            charge: @charge_id,
            amount: (@amount*100).to_i,
          })
          charge = Stripe::Charge.create(
            customer:  cutsomer_id,
            amount:    (service_fee * 100).to_i,
            currency:  'aud',
            capture: true,
            destination: {
              account: poster.stripe_info.stripe_account_id,
              amount: (service_fee * 100).to_i
            }
          )
        else
          if @transaction.bookings.where(day: day).last.end_time.to_time < Time.now
            if ["sunday","saturday"].include?(day)
              unless @transaction.bookings.where(day: day).blank?
                amount = ((@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600) * @transaction.employee_listing.weekend_price.to_f
              end
            else
              unless @transaction.bookings.where(day: day).blank?
                amount = ((@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600) * @transaction.employee_listing.weekday_price.to_f
              end
            end
            amount = (amount + @transaction.service_fee).round(2)
            
            poster_recieve = (amount - (amount * 10/100)).round(2)
            refund = Stripe::Refund.create({
              charge: @charge_id,
              amount: (@amount*100).to_i,
            })
            charge = Stripe::Charge.create(
              customer:  cutsomer_id,
              amount:    (amount * 100).to_i,
              currency:  'aud',
              capture: true,
              destination: {
                account: poster.stripe_info.stripe_account_id,
                amount: (poster_recieve*100).to_i
              }
            )
          else
            service_fee = @transaction.service_fee < 0.50 ? 0.50 : @transaction.service_fee
            refund = Stripe::Refund.create({
              charge: @charge_id,
              amount: (@amount*100).to_i,
            })
            charge = Stripe::Charge.create(
              customer:  cutsomer_id,
              amount:    (service_fee * 100).to_i,
              currency:  'aud',
              capture: true,
              destination: {
                account: poster.stripe_info.stripe_account_id,
                amount: (service_fee * 100).to_i
              }
            )
          end
        end
      else
        @amount = (@transaction.amount - @transaction.tax_withholding_amount) + (@transaction.amount - @transaction.tax_withholding_amount) * 0.03
        amount = already_start_refund_amont
        amount_with_taxwithholding = amount - @transaction.remaining_tax_withholding(amount)
        amount_with_service_fee = ((amount_with_taxwithholding) + @transaction.service_fee).round(2)
        amount_with_service_fee = 0.50 if amount_with_service_fee < 0.50
        poster_recieve = (amount_with_taxwithholding - (amount_with_taxwithholding * 10/100)).round(2)
        with_destination = poster_recieve > 0
        stripe_payment = StripePayment.create!(transaction_id: @transaction.id, amount: amount, poster_service_fee: poster_recieve, status: "failed", charge_type: "partial")
        begin
          if with_destination
            charge = Stripe::Charge.create(
              customer:  cutsomer_id,
              amount:    (amount_with_service_fee * 100).to_i,
              currency:  'aud',
              capture: true,
              destination: {
                account: poster.stripe_info.stripe_account_id,
                amount: (poster_recieve*100).to_i
              }
            )
          else
            charge = Stripe::Charge.create(
              customer:  cutsomer_id,
              amount:    (amount_with_service_fee * 100).to_i,
              currency:  'aud',
              capture: true
            )
          end
          stripe_payment.update(stripe_charge_id: charge.id, status: charge.status, reason: charge.failure_message)
        rescue => e
          stripe_payment.update(reason: e.error.message)
        end
        stripe_refund = StripeRefund.create!(transaction_id: @transaction.id, amount: @amount, tax_withholding_amount: @transaction.tax_withholding_amount, service_fee: @transaction.service_fee, stripe_charge_id: @charge_id, status: "failed", refund_type: "partial")
        begin
          refund = Stripe::Refund.create({
            charge: @charge_id,
            amount: (@amount * 100).to_i,
          })
          stripe_refund.update(refund_id: refund.id, status: refund.status, reason: refund.reason)
        rescue => e
          stripe_refund.update(status: e.error.message)
        end
        StripeRefundReceipt.create!(transaction_id: @transaction.id, amount: @amount - amount_with_service_fee, tax_withholding_amount: @transaction.remaining_tax_withholding(amount), service_fee: @transaction.service_fee)
      end
      #end
    end
  end

  def poster_service_fee amount
    amount * 0.1
  end

  def already_start_refund_amont
    diff = (Date.today - @transaction.start_date).to_i
    if @transaction.frequency == "weekly"
      if diff < 7
        amount = 0
        work_days = (@transaction.start_date...Date.today).to_a
        work_days.each do |workday|
          day = workday.strftime("%A").downcase
          if ["sunday","saturday"].include?(day)
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + ((@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600) * @transaction.employee_listing.weekend_price.to_f
            end
          else
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + ((@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600) * @transaction.employee_listing.weekday_price.to_f
            end
          end
        end
        amount
      else
        count_days = diff % 7
        amount = 0
        work_days = (Date.today - count_days.days...Date.today).to_a
        work_days.each do |workday|
          day = workday.strftime("%A").downcase
          if ["sunday","saturday"].include?(day)
            unless @transaction.bookings.where(day: day).blank?
            amount = amount + (
                (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                ) * @transaction.employee_listing.weekend_price.to_f
            end
          else
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + (
                  (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                  ) * @transaction.employee_listing.weekday_price.to_f
            end
          end
        end
        amount
      end
    elsif @transaction.frequency == "fortnight"
      if diff < 14
        amount = 0
        work_days = (@transaction.start_date...Date.today).to_a
        work_days.each do |workday|
          day = workday.strftime("%A").downcase
          if ["sunday","saturday"].include?(day)
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + (
                  (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                  ) * @transaction.employee_listing.weekend_price.to_f
            end
          else
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + (
                  (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                  ) * @transaction.employee_listing.weekday_price.to_f
            end
          end
        end
        amount
      else
        count_days = diff % 14
        amount = 0
        work_days = (Date.today - count_days.days...Date.today).to_a
        work_days.each do |workday|
          day = workday.strftime("%A").downcase
          if ["sunday","saturday"].include?(day)
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + (
                  (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                  ) * @transaction.employee_listing.weekend_price.to_f
            end
          else
            unless @transaction.bookings.where(day: day).blank?
              amount = amount + (
                  (@transaction.bookings.where(day: day).last.end_time.to_time - @transaction.bookings.where(day: day).last.start_time.to_time) / 3600
                  ) * @transaction.employee_listing.weekday_price.to_f
            end
          end
        end
        amount
      end
    end
  end
end