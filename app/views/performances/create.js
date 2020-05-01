<% if @performance.save %>
	$('#performance tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#performance tbody').prepend("<%= j(render 'data', :performance => @performance) %>"); 
<% else %>
setTimeout(function(){$('input[type=radio].star').rating()}, 1000);
<% end %>