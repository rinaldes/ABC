$('#data_<%= @salary.id %>').html("<%= j(render 'form', :salary => @salary) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});