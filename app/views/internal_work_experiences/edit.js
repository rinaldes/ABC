$('#data_<%= @internal_work_experience.id %>').html("<%= j(render 'form', :internal_work_experience => @internal_work_experience, :position => @position, :organization => @organization ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});