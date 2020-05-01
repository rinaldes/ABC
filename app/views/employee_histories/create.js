<% if @employee_history.save %>
	$('#employee_history tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#employee_history tbody').prepend("<%= j(render 'data', :employee_history => @employee_history) %>");
<% else %>
	
<% end %>