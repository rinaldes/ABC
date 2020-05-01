$('#data_<%= @skill.id %>').replaceWith("<%= j(render 'form', :skill => @skill) %>");

$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});