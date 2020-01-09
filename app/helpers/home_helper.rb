module HomeHelper
	def checked_parent(classification_id)
		if params[:parent].present?
			params[:parent].include?(classification_id.to_s) ? true : false
		else
			false
		end
	end

	def checked_child(classification_id)
		if params[:child].present?
			params[:child].include?(classification_id.to_s) ? true : false
		else
			false
		end
	end
end
