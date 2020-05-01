$('#employee_working_data tbody').prepend("<%= j(render 'form', :employee_working_data => @employee_working_data, :position => @position, :organization => @organization )%>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});