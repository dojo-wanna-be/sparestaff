class StripeAccount
  def initialize(params, user)
    @params = params
    @user = user
  end

  def create
    ActiveRecord::Base.transaction do
      tx = Transaction.new(transaction_params)
      listing = tx.employee_listing
      tx.hirer_id = @hirer.id
      tx.poster_id = listing.poster.id
      tx.state = "initialized"
      availability_slots = ListingAvailability::TIME_SLOTS

      if tx.save
        weekly_hours = create_bookings(tx, availability_slots)
        total_weekday_hours_per_week = weekly_hours[:monday_hours] + weekly_hours[:tuesday_hours] + weekly_hours[:wednesday_hours] + weekly_hours[:thursday_hours] + weekly_hours[:friday_hours]
        total_weekday_hours = weekly_hours[:total_monday_hours] + weekly_hours[:total_tuesday_hours] + weekly_hours[:total_wednesday_hours] + weekly_hours[:total_thursday_hours] + weekly_hours[:total_friday_hours]
        total_weekend_hours_per_week = weekly_hours[:saturday_hours] + weekly_hours[:sunday_hours]
        total_weekend_hours = weekly_hours[:total_saturday_hours] + weekly_hours[:total_sunday_hours]

        number_of_weeks = @start_date.upto(@end_date).count.fdiv(7).ceil

        tx.weekday_hours = total_weekday_hours_per_week
        tx.weekend_hours = total_weekend_hours_per_week

        tx.total_weekday_hours = total_weekday_hours
        tx.total_weekend_hours = total_weekend_hours

        weekdays_price = listing.weekday_price.to_f * total_weekday_hours_per_week
        weekends_price = listing.weekend_price.to_f * total_weekend_hours_per_week

        total_weekdays_price = listing.weekday_price.to_f * total_weekday_hours
        total_weekends_price = listing.weekend_price.to_f * total_weekend_hours

        weekly_earning = weekdays_price + weekends_price
        total_earning = total_weekdays_price + total_weekends_price

        
        weekly_tax_withholding = @params[:transaction][:tax_withholding_amount].to_i
        total_tax_withholding = @params[:transaction][:tax_withholding_amount].to_i.abs


        if tx.frequency.eql?("weekly")
          tx.tax_withholding_amount = weekly_tax_withholding
          tx.amount = weekly_earning - weekly_tax_withholding
          tx.total_tax_withholding_amount = total_tax_withholding
          tx.total_amount = total_earning - total_tax_withholding
        elsif tx.frequency.eql?("fortnight")
          fortnight_tax_withholding = 2 * weekly_tax_withholding
          total_fortnight_tax_withholding = 2 * total_tax_withholding
          tx.tax_withholding_amount = fortnight_tax_withholding
          tx.amount = weekly_earning - fortnight_tax_withholding
          tx.total_tax_withholding_amount = total_fortnight_tax_withholding
          tx.total_amount = total_earning - total_fortnight_tax_withholding
        end

        tx.save

        return tx
      else
        ActiveRecord::RollBack
        return nil
      end
    end
    rescue Exception => e
      return nil
    file = File.new(params[:stripe_verification_file].path) rescue nil
    upload_result = upload_identity(file)
  end

  def individual
    begin
      @account = Stripe::Account.create(
        type: 'custom',
        country: country,
        email: user.primary_email.present? ? user.primary_email.address : nil,
        tos_acceptance: {
          ip: ip,
          date: Time.now.to_i
        },
        business_type: 'individual',
        individual: {
          first_name: params[:individual][:first_name],
          last_name: params[:individual][:last_name],
          phone: params[:phone],
          dob: {
            year: params[:account]['dob(1i)'],
            month: params[:account]['dob(2i)'],
            day: params[:account]['dob(3i)']
          },
          verification: {
            document: upload_result.id,
          },
          address: {
            city: params[:address][:city],
            line1: params[:address][:line1],
            postal_code: params[:address][:postal_code],
            state: params[:address][:state],
            country: params[:address][:country]
          }
        },
        external_account: {
          object: 'bank_account',
          country: 'US',
          currency: 'usd',
          account_number: params[:bank_account_number],
          account_holder_name: params[:bank_holder_name],
          routing_number: params[:bank_routing_number],
          account_holder_type: 'individual',
        }
      )
    rescue Exception => e
      @account = nil
      @error = e.message # TODO: improve
    end
  end

  def company
    begin
      @account = Stripe::Account.create(
        type: 'custom',
        country: country,
        email: user.primary_email.present? ? user.primary_email.address : nil,
        tos_acceptance: {
          ip: ip,
          date: Time.now.to_i
        },
        business_type: 'company',
        company: {
          name: params[:company][:name],
          phone: params[:phone],
          tax_id: params[:business_tax_id],
          dob: {
            year: params[:account]['dob(1i)'],
            month: params[:account]['dob(2i)'],
            day: params[:account]['dob(3i)']
          },
          verification: {
            document: upload_result.id,
          },
          address: {
            city: params[:address][:city],
            line1: params[:address][:line1],
            postal_code: params[:address][:postal_code],
            state: params[:address][:state],
            country: params[:address][:country]
          }
        },
        external_account: {
          object: 'bank_account',
          country: 'US',
          currency: 'usd',
          account_number: params[:bank_account_number],
          account_holder_name: params[:bank_holder_name],
          routing_number: params[:bank_routing_number],
          account_holder_type: 'company',
        }
      )
    rescue Exception => e
      @account = nil
      @error = e.message # TODO: improve
    end
  end

  private

    def upload_identity(file)
      Stripe::FileUpload.create(
        {
          purpose: 'identity_document',
          file: file
        },
      )
    end
end
