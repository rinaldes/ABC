$('#data_<%= @contract.id %>').replaceWith("<%= j(render 'form', :contract => @contract) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});