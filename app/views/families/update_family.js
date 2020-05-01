$('#button-new').show();
$('#data_<%= @family.id %>').html("<%= j(render 'data', :family => @family) %>");