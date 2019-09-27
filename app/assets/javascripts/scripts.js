    function highlight_menu(id) {
       var e = document.getElementById(id);
       e.classList.add('SelectedMenuLink');
    }
    
    function highlight_left_menu(id) {
       var e = document.getElementById(id);
       e.classList.add('AccountLeftMenuSelected');
    }
    
    function highlight_backend_left_menu(id) {
       var e = document.getElementById(id);
       e.classList.add('BackendLeftMenuSelected');
    }
    
    function highlight_manage_listing_menu(id) {
       var e = document.getElementById(id);
       e.classList.add('ManageListingMenuLinkSelected');
    }


function toggle_visibility(id) {
       var e = document.getElementById(id);
       if(e.style.display == 'block')
          e.style.display = 'none';
       else
          e.style.display = 'block';
    }
    
/* show and hide Div */
function hide(id){
  document.getElementById(id).style.display ='none';
}
function show(id){
  document.getElementById(id).style.display = 'block';
}

$(document).ready(function() {
  $(".show-password, .hide-password").on('click', function() {
    var passwordId = "user_login_password";
    if ($(this).hasClass('show-password')) {
      $("#" + passwordId).attr("type", "text");
      $(this).parent().find(".show-password").hide();
      $(this).parent().find(".hide-password").show();
    } else {
      $("#" + passwordId).attr("type", "password");
      $(this).parent().find(".hide-password").hide();
      $(this).parent().find(".show-password").show();
    }
  });
});
