$('#family tbody').prepend("<%= j(render 'form', :family => @family, :status => @status) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});