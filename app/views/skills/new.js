$('#skill tbody').prepend("<%= j( render 'form', :skill => @skill) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});