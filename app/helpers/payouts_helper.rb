module PayoutsHelper
  def is_active_menu(menu)
    action_name == menu ? "active": nil
  end
end
 