$('#data_<%= @violation_detail.id %>').replaceWith("<%= j(render 'form', :violation_detail => @violation_detail ) %>");

$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});