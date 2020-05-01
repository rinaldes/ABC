$('#button-new').show();
$('#data_<%= @employee_working_data.id %>').html("<%= j(render 'data', :employee_working_data => @employee_working_data) %>");