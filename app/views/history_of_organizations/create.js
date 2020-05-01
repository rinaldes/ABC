<% if @history_of_organization.save %>
	$('#history_of_organization tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#history_of_organization tbody').prepend("<%= j(render 'data', :history_of_organization => @history_of_organization) %>");
<% else %>
	
<% end %>