class Admin::CommunityServiceFeesController < Admin::AdminBaseController
  def new
    @community_service_fee = CommunityServiceFee.last.present? ? CommunityServiceFee.last : CommunityServiceFee.new
    @redirect_url_path = CommunityServiceFee.last.present? ? admin_community_service_fee_path(CommunityServiceFee.last.id) : admin_community_service_fees_path
  end

  def create
    @community_service_fee = CommunityServiceFee.new(params[:community_service_fee].permit!)
    @community_service_fee.save
    flash[:success] = "Created successfully!"
    redirect_to new_admin_community_service_fee_path
  end

  def update
    CommunityServiceFee.last.update(params[:community_service_fee].permit!)
    flash[:success] = "Updated successfully!"
    redirect_to new_admin_community_service_fee_path
  end
end