class StripeAccount
  def initialize(params, user)
    @params = params
    @user = user
  end

  def create
    
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
