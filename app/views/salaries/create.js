<% if @salary.save %>
	$('#salary tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#salary tbody').prepend("<%= j(render 'data', :salary => @salary) %>");
<% else %>
	
<% end %>