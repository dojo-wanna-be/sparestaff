class Admin::ContentManagementController < Admin::AdminBaseController
	
	def index
	end

	def update_site_logo
		binding.pry
		site_logo =  Paperclip.io_adapters.for(params[:site_logo])
		if StaticContent.first.present?
			@static_content = StaticContent.first
			@static_content.update(site_logo: site_logo)
		else
			StaticContent.create(site_logo: site_logo)
		end
		redirect_to admin_content_management_index_path
	end
end