$('#button-new').show();
$('#data_<%= @performance.id %>').html("<%= j(render 'data', :performance => @performance) %>");