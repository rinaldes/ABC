$('#position_detail tbody').prepend("<%= j( render 'form', :position_detail => @position_detail, :position => @position, :organization => @organization) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});