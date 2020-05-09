class Admin::ConversationsController < Admin::AdminBaseController
	
	def index
		if params[:search_fields].present?
			conversations = Conversation.includes(:messages).ransack(id_in: params[:q], messages_content_cont_any: params[:q], m: 'or').result(distinct: true)
      @conversations = conversations.ransack(created_at_gteq: params[:created_at_gteq], created_at_lteq: params[:created_at_lteq]).result(distinct: true).order(id: :desc).paginate(:page => params[:page], :per_page => params[:per_page])
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

	def disallow_or_delete
    conversations = Conversation.where(id: params[:ids])
    if params[:select_action].eql?("delete_selected")
      conversations.update(deleted_at: Date.today)
    else
      conversations.update(is_disallowed: true)
    end
  end
end