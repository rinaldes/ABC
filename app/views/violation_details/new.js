$('#violation_detail tbody').prepend("<%= j( render 'form', :violation_detail => @violation_detail ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});