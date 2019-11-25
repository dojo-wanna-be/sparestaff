class StripeAccount
  def initialize(params, user, remote_ip)
    @params = params
    @user = user
    @ip = remote_ip
  end

  def create
    if @params[:user_type].eql?("individual")
      individual
    elsif @params[:user_type].eql?("company")
      company
    else
      return nil
    end
  end

  def individual
    file = File.new(@params[:stripe_verification_file].path) rescue nil
    upload_result = upload_identity(file)
    begin
      account = Stripe::Account.create(
        type: 'custom',
        country: 'AU',
        email: @user.email,
        tos_acceptance: {
          ip: @ip,
          date: Time.now.to_i
        },
        business_type: 'individual',
        individual: {
          first_name: @params[:first_name],
          last_name: @params[:last_name],
          email: @user.email,
          # phone: @params[:phone],
          dob: {
            year: @params[:dob]["(1i)"],
            month: @params[:dob]["(2i)"],
            day: @params[:dob]["(3i)"]
          },
          verification: {
            document: {
              front: upload_result.id
            }
          },
          address: {
            city: @params[:city],
            line1: @params[:address_line1],
            postal_code: @params[:postal_code],
            state: @params[:state],
            country: @params[:country]
          }
        },
        external_account: {
          object: 'bank_account',
          country: 'AU',
          currency: 'aud',
          account_number: @params[:bank_account_number],
          account_holder_name: @params[:bank_holder_name],
          routing_number: @params[:bank_routing_number],
          account_holder_type: 'individual'
        }
      )
      stripe_info = @user.stripe_info.present? ? @user.stripe_info : @user.build_stripe_info
      stripe_info.stripe_account_id = account.id
      stripe_info.save
      {message: "Account Created Successfully", success: true}
    rescue Exception => e
      {message: e.message, success: false} 
    end
  end

  def company
    file = File.new(@params[:stripe_verification_file].path) rescue nil
    upload_result = upload_identity(file)
    begin
      @account = Stripe::Account.create(
        type: 'custom',
        country: 'AU',
        email: @user.email,
        tos_acceptance: {
          ip: @ip,
          date: Time.now.to_i
        },
        business_type: 'company',
        company: {
          name: @params[:business_name],
          # phone: @params[:phone],
          tax_id: @params[:business_tax_id],
          verification: {
            document: {
              front: upload_result.id
            }
          },
          address: {
            city: @params[:city],
            line1: @params[:address_line1],
            postal_code: @params[:postal_code],
            state: @params[:state],
            country: @params[:country]
          }
        },
        external_account: {
          object: 'bank_account',
          country: 'AU',
          currency: 'aud',
          account_number: @params[:bank_account_number],
          account_holder_name: @params[:bank_holder_name],
          routing_number: @params[:bank_routing_number],
          account_holder_type: 'company',
        }
      )
    rescue Exception => e
      e.message
    end
  end

  private

    def upload_identity(file)
      Stripe::File.create(
        {
          purpose: 'identity_document',
          file: file
        }
      )
    end
end
