class Admin::CouponsController < Admin::AdminBaseController 
  def index
    @coupons = Coupon.all
    @users = User.all.where.not(id: current_user.id).order(id: :desc).paginate(:page => params[:page], :per_page => 50)
  end

  # def user_details
  #   coupon = Coupon.find(params[:id])
  # end

  def create
    @coupon = Coupon.new
    @coupon.coupon_code = params[:coupon_code]
    @coupon.discount = params[:discount].to_f
    @coupon.save
  end
end