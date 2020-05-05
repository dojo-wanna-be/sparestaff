// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery3
//= require popper
//= require bootstrap-sprockets

//= require rails-ujs
//= require toastr_rails
//= require allow_numeric
//= require jquery.tagsinput
//= require activestorage
//= require bootstrap-datepicker
//= require turbolinks
//= require jquery.validate
//= require jquery.raty
//= require select2.js
//= require cocoon
//= require_tree .

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

$("#listing_transaction").validate({
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
  }
});
