class Admin::CouponsController < Admin::AdminBaseController 

  def index
    @coupons = Coupon.all
    @coupons = @coupons.paginate(:page => params[:page], :per_page => 10)
    @users = User.exclude(current_user).order(id: :desc)
  end

  def create
    @coupon = Coupon.new
    @coupon.coupon_code = params[:coupon_code]
    @coupon.discount = params[:discount].to_f
    @coupon.expiry_date = params[:expiry_date]
    @coupon.save
    if params[:users].present?
      @users = User.where(id: params[:users])
      @users.each do |user|
        @user_coupon = user.user_coupons.create(coupon_id: @coupon.id)
      end
    end
    redirect_to admin_coupons_path
  end

  def update
    @coupon = Coupon.find(params[:id])
    @coupon.user_coupons.destroy_all
    params[:users].each do |id|
      UserCoupon.create(coupon_id: @coupon.id, user_id: id)
    end
    redirect_to admin_coupons_path
  end
end