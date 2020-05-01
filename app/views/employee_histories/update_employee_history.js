$('#button-new').show();
$('#data_<%= @employee_history.id %>').html("<%= j(render 'data', :employee_history => @employee_history) %>");