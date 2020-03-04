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
        @amount = @transaction.hirer_weekly_amount
        refund = Stripe::Refund.create({
          charge: @charge_id,
          amount: (@amount*100).to_i,
        })
      elsif @transaction.start_date == Date.today
        @amount = @transaction.hirer_weekly_amount
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
            amount = (amount + @transaction.service_fee - @transaction.tax_withholding_amount).round(2)
            
            poster_recieve = (amount - @transaction.tax_withholding_amount - @transaction.poster_service_fee).round(2)
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
        @amount = @transaction.hirer_weekly_amount
        if @transaction.frequency == "weekly"
          if diff < 7
            amount = 0
            work_days = (@transaction.start_date..Date.today).to_a
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
            work_days = (Date.today - count_days.days..Date.today).to_a
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
            work_days = (@transaction.start_date..Date.today).to_a
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
            work_days = (Date.today - count_days.days..Date.today).to_a
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
        amoun_with_service_fee = (@transaction.service_fee + amount - @transaction.tax_withholding_amount).round(2)
        amoun_with_service_fee = 0.50 if amoun_with_service_fee < 0.50
        poster_recieve = (amount - @transaction.tax_withholding_amount - @transaction.poster_service_fee).round(2)
        charge = Stripe::Charge.create(
          customer:  cutsomer_id,
          amount:    (amoun_with_service_fee * 100).to_i,
          currency:  'aud',
          capture: true,
          destination: {
            account: poster.stripe_info.stripe_account_id,
            amount: (poster_recieve*100).to_i
          }
        )
        refund = Stripe::Refund.create({
          charge: @charge_id,
          amount: (@amount*100).to_i,
        })
      end
      #end
    end
  end

  def poster_service_fee amount
    amount * 0.1
  end
end