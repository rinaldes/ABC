$('#data_<%= @certification.id %>').html("<%= j(render 'form', :certification => @certification ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});