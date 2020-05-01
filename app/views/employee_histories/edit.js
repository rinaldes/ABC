$('#data_<%= @employee_history.id %>').html("<%= j(render 'form', :employee_history => @employee_history, :position => @position, :organization => @organization) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});