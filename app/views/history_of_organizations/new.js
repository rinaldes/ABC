$('#history_of_organization tbody').prepend("<%= j( render 'form', :history_of_organization => @history_of_organization, :position => @position) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});