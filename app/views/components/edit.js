$('#data_<%= @component.id %>').html("<%= j(render 'form', :component => @component) %>");
$('#button-new').hide();