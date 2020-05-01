$('#button-new').show();
$('#data_<%= @leave_request.id %>').html("<%= j(render 'data', :leave_request => @leave_request) %>");