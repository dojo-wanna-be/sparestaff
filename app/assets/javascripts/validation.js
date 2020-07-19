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

function authenticate_and_submit(formId, form) {
  if (gon.user) {
    form.submit();
  } else {
    openLoginModal();
    $(formId).find('input[type="submit"]').attr('disabled', false);
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

function initializeTransactionForm() {
  var formId = '#listing_transaction';
  $(formId).validate({
    errorPlacement: function(error, element) {
      error.appendTo(element.parent());
    },
    rules: {
      "transaction[booking_attributes][0][end_time]": {greaterThan: "#transaction_booking_attributes_0_start_time"},
      "transaction[booking_attributes][1][end_time]": {greaterThan: "#transaction_booking_attributes_1_start_time"},
      "transaction[booking_attributes][2][end_time]": {greaterThan: "#transaction_booking_attributes_2_start_time"},
      "transaction[booking_attributes][3][end_time]": {greaterThan: "#transaction_booking_attributes_3_start_time"},
      "transaction[booking_attributes][4][end_time]": {greaterThan: "#transaction_booking_attributes_4_start_time"},
      "transaction[booking_attributes][5][end_time]": {greaterThan: "#transaction_booking_attributes_5_start_time"},
      "transaction[booking_attributes][6][end_time]": {greaterThan: "#transaction_booking_attributes_6_start_time"},
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
      authenticate_and_submit(formId, form);
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