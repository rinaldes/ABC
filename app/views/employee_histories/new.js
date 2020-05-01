$('#employee_history tbody').prepend("<%= j(render 'form', :employee_history => @employee_history), :Position => @Position, :Organization => @Organization %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});