class Admin::ConversationsController < Admin::AdminBaseController
	
	def index
		if params[:search_fields].present? && search_fields
      if disallow_conversation_field
        @conversations = disallow_conversations
      elsif params[:selected_data] == "200"
        @conversations = conversations.paginate(:page => params[:page], :per_page => 200)
      elsif params[:selected_data] == "100"
        @conversations = conversations.paginate(:page => params[:page], :per_page => 100)
      else
       @conversations = conversations.paginate(:page => params[:page], :per_page => 50)
      end
    elsif (params[:disallow_conversation].present? && disallow_conversation_field)
      @conversations = disallow_conversations
    else
			@conversations = Conversation.all.order(id: :desc).paginate(:page => params[:page], :per_page => 50)
		end
	end

	def show
		@conversation = Conversation.find(params[:id])
    @transaction = @conversation.employee_listing_transaction
    @listing = EmployeeListing.find(@conversation.employee_listing_id)
    @messages = @conversation.messages.order(created_at: :DESC)
  end

  def delete_message
    message = Message.find_by(id: params[:id])
    message.deleted_by = current_user.id
    message.save
  end

  def update
    @message = Message.find(params[:id])
    if params[:content].present?
      @message.update(content: params[:content])
    else
      flash[:error] = "Blank content has not be updated"
    end
  end

  def edit
    @message = Message.find_by(id: params[:id])
  end

	def disallow_or_delete
    conversation = Conversation.find_by(id: params[:id])
    conversation.update(is_disallowed: params[:checked])
  end

  private

  def conversations
    name = params[:q].split().first
    conversations = Conversation.includes(:messages, :sender, :receiver).ransack(receiver_first_name_or_receiver_last_name_cont_any: name, sender_first_name_or_sender_last_name_cont_any: name, id_in: params[:q], messages_content_cont_any: params[:q], m: 'or').result(distinct: true)
    @conversations = conversations.ransack(created_at_gteq: params[:created_at_gteq], created_at_lteq: params[:created_at_lteq]).result(distinct: true).order(id: :desc)
  end

  def disallow_conversations
    conversations = Conversation.disallow_conversation.includes(:messages, :sender, :receiver).order(id: :desc).paginate(:page => params[:page], :per_page => 50)
  end

  def search_fields
    result = (params[:q].present? || params[:created_at_gteq].present? || params[:created_at_lteq].present?)
  end
  
  def disallow_conversation_field
    result = (params[:data_show] == "Disallow conversations")  
  end

end