$('#data_<%= @performance.id %>').html("<%= j(render 'form', :performance => @performance) %>");
$('#button-new').hide();
$('.input-append.date').datepicker({
  autoclose: true,
  todayHighlight: true
});
setTimeout(function(){$('input[type=radio].star').rating()}, 1000);
