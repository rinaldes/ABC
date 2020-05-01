$('#data_<%= @employee_working_data.id %>').html("<%= j(render 'form', :employee_working_data => @employee_working_data, :Position => @Position, :Organization => @Organization) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});