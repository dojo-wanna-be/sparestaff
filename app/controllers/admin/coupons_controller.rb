class Admin::CouponsController < Admin::AdminBaseController

	def index
		@coupons = Coupon.all
		@coupons = @coupons.paginate(:page => params[:page], :per_page => 10)
		@users = User.all.where.not(id: current_user.id).order(id: :desc)
	end

	def coupon_details
		@coupon = Coupon.find(params[:id])
		@coupon.user_coupons.destroy_all
		params[:users].each do |id|
			@user_coupon = UserCoupon.create(coupon_id: @coupon.id, user_id: id)
			@user_coupon.save
		end
		redirect_to admin_coupons_path
	end

	def create
		@coupon = Coupon.new
		@coupon.coupon_code = params[:coupon_code]
		@coupon.discount = params[:discount].to_f
		@coupon.save
		if params[:users].present?
			@users = User.where(id: params[:users])
			@users.each do |user|
				# @user_coupon = user.user_coupons.new
				# @user_coupon.coupon_id = @coupon.id
				@user_coupon = user.user_coupons.create(coupon_id: @coupon.id)
				@user_coupon.save
			end
		end
		redirect_to admin_coupons_path
	end
end