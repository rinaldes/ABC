<% if @employee_working_data.save %>
	$('#employee_working_data tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#employee_working_data tbody').prepend("<%= j(render 'data', :employee_working_data => @employee_working_data) %>");
<% else %>
	
<% end %>