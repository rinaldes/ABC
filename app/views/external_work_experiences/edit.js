$('#data_<%= @external_work_experience.id %>').html("<%= j(render 'form', :external_work_experience => @external_work_experience, :position => @position ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});