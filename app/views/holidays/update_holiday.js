$('#button-new').show();
$('#data_<%= @holiday.id %>').html("<%= j(render 'data', :holiday => @holiday) %>");