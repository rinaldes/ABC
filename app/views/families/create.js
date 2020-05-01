<% if @family.save %>
	$('#family tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#family tbody').prepend("<%= j(render 'data', :family => @family) %>");
<% else %>
	
<% end %>