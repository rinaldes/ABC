$('#data_<%= @education_detail.id %>').html("<%= j(render 'form', :education_detail => @education_detail, :grade => @grade ) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});