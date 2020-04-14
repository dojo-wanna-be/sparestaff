module PayoutsHelper
  def is_active_menu(menu)
    action_name == menu ? "active": nil
  end

  def is_active_navi(menu, control)
    action_name.eql?(menu) && controller_name.eql?(control) ? "active": nil
  end
end
 