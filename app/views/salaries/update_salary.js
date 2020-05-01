$('#button-new').show();
$('#data_<%= @salary.id %>').html("<%= j(render 'data', :salary => @salary) %>");