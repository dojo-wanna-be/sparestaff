class Admin::GettingStartContentsController < Admin::AdminBaseController
  def new
    @new_form = GettingStartContent.last.present? ? GettingStartContent.last : GettingStartContent.new
    @url = GettingStartContent.last.present? ? admin_getting_start_content_path(GettingStartContent.last.id) : admin_getting_start_contents_path
    unless GettingStartContent.last.present?
      @new_form.homepage_contents.build
      @new_form.frequently_ask_questions.build
    end
  end

  def create
    @new_form = GettingStartContent.new(content_params)
    if @new_form.save
      flash[:success] = "Created successfully!"
      redirect_to new_admin_getting_start_content_path
    else
      flash[:error] = @new_form.errors.messages
      redirect_to new_admin_getting_start_content_path
    end
  end

  def update
    @update_form = GettingStartContent.find_by(id: params[:id])
    @update_form.update(content_params)
  end

  private

  def content_params
    params.require(:getting_start_content).permit(:cover_title, 
      :cover_subtitle,
      :button_title,
      :list_your_self_title,
      :how_it_works_title,
      :safety_title,
      :frequently_asked_title,
      :easy_online_title,
      :cover_image,homepage_contents_attributes: [:id, :content_image, :content, :section_type, :_destroy], frequently_ask_questions_attributes: [:id, :section_type, :question, :answer , :_destroy])
  end
end