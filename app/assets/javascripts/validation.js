$.validator.addMethod('lessThan', function(value, element, param) {
  return this.optional(element) || value < $(param).val();
}, "The value {0} must be less than {1}");

$.validator.addMethod('greaterThan', function(value, element, param) {
  return this.optional(element) || value > $(param).val();
}, "The value {0} must be less than {1}");

$.validator.addMethod("dateGreaterThan", function(value, element, params) {
  if (!/Invalid|NaN/.test(new Date(value))) {
    return new Date(value) > new Date($(params).val());
  }
  return isNaN(value) && isNaN($(params).val()) || (Number(value) > Number($(params).val()));
},'Must be greater than {0}');

$.validator.addMethod("dateLessThan", function(value, element, params) {
  if (!/Invalid|NaN/.test(new Date(value))) {
    return new Date(value) < new Date($(params).val());
  }
  return isNaN(value) && isNaN($(params).val()) || (Number(value) < Number($(params).val()));
},'Must be less than {0}');

function isSundayStartDatePresent() {
  return $('#transaction_booking_attributes_0_start_time').val() != "";
}
function isMondayStartDatePresent() {
  return $('#transaction_booking_attributes_1_start_time').val() != "";
}
function isTuesdayStartDatePresent() {
  return $('#transaction_booking_attributes_2_start_time').val() != "";
}
function isWednesdayStartDatePresent() {
  return $('#transaction_booking_attributes_3_start_time').val() != "";
}
function isThursdayStartDatePresent() {
  return $('#transaction_booking_attributes_4_start_time').val() != "";
}
function isFridayStartDatePresent() {
  return $('#transaction_booking_attributes_5_start_time').val() != "";
}
function isSaturdayStartDatePresent() {
  return $('#transaction_booking_attributes_6_start_time').val() != "";
}

function authenticate_and_submit(formId, form, minimumWorkingHours) {
  var timeSelected = isSundayStartDatePresent() || isMondayStartDatePresent() ||
                     isTuesdayStartDatePresent() || isWednesdayStartDatePresent() ||
                     isThursdayStartDatePresent() || isFridayStartDatePresent() || isSaturdayStartDatePresent();

  var totalSelectedHours = sundayHour + mondayHour + tuesdayHour + wednesdayHour + thursdayHour + fridayHour + saturdayHour;
  if (timeSelected) {
    if (minimumWorkingHours > totalSelectedHours){
      $("#total_hour_error").show();
      return false;
    }else {
      $("#timing_error").hide();
      $("#total_hour_error").hide();
      if (gon.user) {
        form.submit();
      } else {
        openLoginModal();
        $(formId).find('input[type="submit"]').attr('disabled', false);
        return false;
      }
    }
  } else {
    $("#timing_error").show();
    return false;
  }
}

function openLoginModal() {
  $("#signupModal").modal('hide');
  $("#loginModal").modal('show');
}

function closeLoginModal() {
  $("#loginModal").modal('hide');
}

function login_with_ajax(formId) {
  var form = $(formId);
  var url = form.attr('action');
  $.ajax({
    type: "POST",
    url: url,
    data: form.serialize(),
  });
}

function initializeTransactionForm(minimumWorkingHours) {
  var formId = '#listing_transaction';
  $(formId).validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "transaction[booking_attributes][0][end_time]": {required: isSundayStartDatePresent, greaterThan: "#transaction_booking_attributes_0_start_time"},
      "transaction[booking_attributes][1][end_time]": {required: isMondayStartDatePresent, greaterThan: "#transaction_booking_attributes_1_start_time"},
      "transaction[booking_attributes][2][end_time]": {required: isTuesdayStartDatePresent, greaterThan: "#transaction_booking_attributes_2_start_time"},
      "transaction[booking_attributes][3][end_time]": {required: isWednesdayStartDatePresent, greaterThan: "#transaction_booking_attributes_3_start_time"},
      "transaction[booking_attributes][4][end_time]": {required: isThursdayStartDatePresent, greaterThan: "#transaction_booking_attributes_4_start_time"},
      "transaction[booking_attributes][5][end_time]": {required: isFridayStartDatePresent, greaterThan: "#transaction_booking_attributes_5_start_time"},
      "transaction[booking_attributes][6][end_time]": {required: isSaturdayStartDatePresent, greaterThan: "#transaction_booking_attributes_6_start_time"},
      "transaction[start_date]": {required: true},
      "transaction[end_date]": {required: true, dateGreaterThan: "#transaction_start_date"},
    },
    messages: {
      "transaction[booking_attributes][0][end_time]": {greaterThan: "Must be greater than Sunday Start Time"},
      "transaction[booking_attributes][1][end_time]": {greaterThan: "Must be greater than Monday Start Time"},
      "transaction[booking_attributes][2][end_time]": {greaterThan: "Must be greater than Tuesday Start Time"},
      "transaction[booking_attributes][3][end_time]": {greaterThan: "Must be greater than Wednesday Start Time"},
      "transaction[booking_attributes][4][end_time]": {greaterThan: "Must be greater than Thursday Start Time"},
      "transaction[booking_attributes][5][end_time]": {greaterThan: "Must be greater than Friday Start Time"},
      "transaction[booking_attributes][6][end_time]": {greaterThan: "Must be greater than Saturday Start Time"},
      "transaction[end_date]": {dateGreaterThan: "Must be greater than Start Date"},
    },
    submitHandler: function(form) {
      authenticate_and_submit(formId, form, minimumWorkingHours);
    }
  });
}

function initializeLoginForm() {
  var formId = '#user_login_form';
  $(formId).validate({
    rules: {
      "user[email]": {required: true, email: true, remote: "/home/email_availability?form=login" },
      "user[password]": {required: true},
    },
    messages: {
      "user[email]": {required: "Please enter your email",remote: "Email doesn't exist"},
      "user[password]": {required: "Please enter Password"},
    },
    submitHandler: function(form) {
      login_with_ajax(formId);
    }
  });
}

function initFeedbackForm() {
  var formId = '#deactivation_feedback_form'
  $(formId).validate({
    rules: {
      "employee_listing[deactivation_feedback]": {required: true},
    },
    messages: {
      "employee_listing[deactivation_feedback]": {required: "Please give feedback"},
    }
  });
}

function initDeactivationReason() {
  $("#deactivation_reason_form").validate({
    errorPlacement: function(error, element) {
       error.appendTo(element.parent());
    },
    rules: {
      "employee_listing[deactivation_reason]": {required: true},
    },
    messages: {
      "employee_listing[deactivation_reason]": {required: "Please select a reason"},
    }
  });
}

function validateAvailabilityForm() {
  $("#listing_availability").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "start_time[]monday": {required: true},
      "start_time[]tuesday": {required: true},
      "start_time[]wednesday": {required: true},
      "start_time[]thursday": {required: true},
      "start_time[]friday": {required: true},
      "start_time[]saturday": {required: true},
      "start_time[]sunday": {required: true},
      "end_time[]monday": {required: true, greaterThan: "#start_time_monday"},
      "end_time[]tuesday": {required: true, greaterThan: "#start_time_tuesday"},
      "end_time[]wednesday": {required: true, greaterThan: "#start_time_wednesday"},
      "end_time[]thursday": {required: true, greaterThan: "#start_time_thursday"},
      "end_time[]friday": {required: true, greaterThan: "#start_time_friday"},
      "end_time[]saturday": {required: true, greaterThan: "#start_time_saturday"},
      "end_time[]sunday": {required: true, greaterThan: "#start_time_sunday"},
      "slot_ids[]": {required: true},
    },
    messages: {
      "end_time[]monday": {greaterThan: "Must be greater than Monday Start Time"},
      "end_time[]tuesday": {greaterThan: "Must be greater than Tuesday Start Time"},
      "end_time[]wednesday": {greaterThan: "Must be greater than Wednesday Start Time"},
      "end_time[]thursday": {greaterThan: "Must be greater than Thursday Start Time"},
      "end_time[]friday": {greaterThan: "Must be greater than Friday Start Time"},
      "end_time[]saturday": {greaterThan: "Must be greater than Saturday Start Time"},
      "end_time[]sunday": {greaterThan: "Must be greater than Sunday Start Time"},
    }
  });
}

function initEmployeeSkillsForm() {
  $("#employee_skills").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "parent_classification": {required: true},
      "employee_listing[skill_description]": {required: true},
    }
  });
}

function initListingDetailsForm() {
  $("#listing_details").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "employee_listing[title]": {required: true},
      "employee_listing[first_name]": {required: true},
      "employee_listing[last_name]": {required: true},
      "employee_listing[city]": {required: true},
      "employee_listing[post_code]": {required: true},
    },
  });
}

function initCouponForm() {
  $("#coupon_form").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "coupon_code": {required: true},
      "discount": {required: true},
      "expiry_date": {required: true},
    }
  });
}

function initListingStatus() {
  $("#listing_status").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "employee_listing[start_publish_date]": {required: true},
      "employee_listing[end_publish_date]": {required: true, dateGreaterThan: "#current_date", dateGreaterThan: "#str_pub"},
    },
    messages: {
      "employee_listing[end_publish_date]": {dateGreaterThan: "Must be greater than Current Date and Start Date"},
    }
  });
}

$(function() {
  $("#listing_pricing").validate({
    rules: {
      "employee_listing[other_weekday_price]": {min: 1},
      "employee_listing[other_weekend_price]": {min: 1},
      "employee_listing[other_holiday_price]": {min: 1},
    }
  });

  $("#company_details").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "company[name]": {required: true},
      "company[acn]": {required: true},
      "user_role": {required: true},
      "company[address_1]": {required: true},
      "company[city]": {required: true},
      "company[state]": {required: true},
      "company[post_code]": {required: true},
      "company[country]": {required: true},
      "company[contact_no]": {required: true},
    },
  });

  $("#emp_listing_det").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "employee_listing[title]": {required: true},
      "employee_listing[first_name]": {required: true},
      "employee_listing[last_name]": {required: true},
      "employee_listing[city]": {required: true},
      "employee_listing[post_code]": {required: true},
    },
  });

  $("#str_tme_id").validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "start_time[]monday": {required: true},
      "start_time[]tuesday": {required: true},
      "start_time[]wednesday": {required: true},
      "start_time[]thursday": {required: true},
      "start_time[]friday": {required: true},
      "start_time[]saturday": {required: true},
      "start_time[]sunday": {required: true},
      "end_time[]monday": {required: true, greaterThan: "#start_time_monday"},
      "end_time[]tuesday": {required: true, greaterThan: "#start_time_tuesday"},
      "end_time[]wednesday": {required: true, greaterThan: "#start_time_wednesday"},
      "end_time[]thursday": {required: true, greaterThan: "#start_time_thursday"},
      "end_time[]friday": {required: true, greaterThan: "#start_time_friday"},
      "end_time[]saturday": {required: true, greaterThan: "#start_time_saturday"},
      "end_time[]sunday": {required: true, greaterThan: "#start_time_sunday"},
      "slot_ids[]": {required: true},
      "employee_listing[other_weekday_price]": {min: 1},
      "employee_listing[other_weekend_price]": {min: 1},
      "employee_listing[other_holiday_price]": {min: 1},
      "employee_listing[start_publish_date]": {required: true},
      "employee_listing[end_publish_date]": {required: true, dateGreaterThan: "#current_date", dateGreaterThan: "#str_pub"},
    },
    messages: {
      "end_time[]monday": {greaterThan: "Must be greater than Monday Start Time"},
      "end_time[]tuesday": {greaterThan: "Must be greater than Tuesday Start Time"},
      "end_time[]wednesday": {greaterThan: "Must be greater than Wednesday Start Time"},
      "end_time[]thursday": {greaterThan: "Must be greater than Thursday Start Time"},
      "end_time[]friday": {greaterThan: "Must be greater than Friday Start Time"},
      "end_time[]saturday": {greaterThan: "Must be greater than Saturday Start Time"},
      "end_time[]sunday": {greaterThan: "Must be greater than Sunday Start Time"},
      "employee_listing[end_publish_date]": {dateGreaterThan: "Must be greater than Current Date and Start Date"},
    }
  });
})
