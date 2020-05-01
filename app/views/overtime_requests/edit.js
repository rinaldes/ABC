$('#data_<%= @overtime_request.id %>').html("<%= j(render 'form', :overtime_request => @overtime_request) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});
$('.clockpicker').clockpicker();