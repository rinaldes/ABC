$('#language_skill tbody').prepend("<%= j( render 'form', :language_skill => @language_skill) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});