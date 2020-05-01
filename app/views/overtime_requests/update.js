$('#button-new').show();
$('#data_<%= @overtime_request.id %>').html("<%= j(render 'data', :overtime_request => @overtime_request) %>");