$('#data_<%= @history_of_organization.id %>').html("<%= j(render 'form', :history_of_organization => @history_of_organization, :position => @position ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});