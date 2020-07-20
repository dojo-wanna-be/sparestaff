$(function() {
  // Need to write common JS here
  $(".sort_paginate_ajax th a, .sort_paginate_ajax .pagination a").on("click", function(){
    $.getScript(this.href);
    return false;
  });

  $('#employee_listing_residency_status').on('keyup keypress change', function (){
    var listingTitle = $("#employee_listing_residency_status").val();
    if (listingTitle == "Other Visas"){
      $("#other_res_sta").show();
      $("#other_res_sta").attr("required", true);
    }else{
      $("#other_res_sta").hide();
      $("#other_res_sta").removeAttr("required");
    }
  });

  $("#employee_listing_available_in_holidays_false").change(function(){
    if ($(this).is(":checked")){
      $("#employee_listing_holiday_price").attr("disabled", "disabled");
      $("#employee_listing_other_holiday_price").attr("disabled", "disabled");
    }
  });

  $("#employee_listing_available_in_holidays_true").change(function(){
    if ($(this).is(":checked")){
      $("#employee_listing_holiday_price").removeAttr("disabled");
      $("#employee_listing_other_holiday_price").removeAttr("disabled");
    }
  });

  $(".unavailable_day_check").on('change', function () {
    if ($(this).is(":checked")) {
      var parent = $(this).parent().parent().parent();
      parent.find("select").removeClass("error");
      parent.find("select").attr("disabled", "disabled");
      parent.find("select").val("");
      parent.find("label.error").hide();
    } else {
      var parent = $(this).parent().parent().parent();
      parent.find("select").removeAttr("disabled");
    }
  });

  $('#parent_classification').on('change', function(){
    var parent_val = $('#parent_classification :selected').val();
    $.ajax({
      url: "/employee/sub_category_lists",
      type: "GET",
      data : {
        id: parent_val,
      },
      dataType: "script",
    });
  });

  $('.cont_step').click(function(e) {
    var FormValid = true;
    var empLang = $('.checkbox-inline').is(':checked');
    if (empLang){
      $('#lan_emp_id').hide();
    }
    else{
      $('#lan_emp_id').show();
      FormValid = false;
    }
    return FormValid;
  });

  $('.checkbox-inline').on('keyup keypress change', function () {
   var empLang = $('.checkbox-inline').is(':checked');
    if (empLang) {
      $("#lan_emp_id").hide();
    }
    else{
      $("#lan_emp_id").show();
    }
  });

  $('#skill_tags').tagsInput({
    'defaultText':'Add skill',
    'height':'50px',
    'width':'430px',
    'delimiter': [',']
  });

  $('.chosen_select').chosen({
    placeholder: "Select a User",
    width: "100%"
  });


  $('.assign_user').click(function(){
    model_id = $(this).attr('model_id');
    users = $(this).attr('users_ids')
    $(model_id).chosen("destroy");
    $(model_id).val(users.split(' '))
    $(model_id).chosen({
      placeholder: "Select a User",
      width: "100%"
    });
  });


});
