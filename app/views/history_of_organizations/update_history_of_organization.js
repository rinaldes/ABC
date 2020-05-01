$('#button-new').show();
$('#data_<%= @history_of_organization.id %>').html("<%= j(render 'data', :history_of_organization => @history_of_organization) %>");