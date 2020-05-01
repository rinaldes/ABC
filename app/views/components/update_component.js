$('#button-new').show();
$('#data_<%= @component.id %>').html("<%= j(render 'data', :component => @component) %>");