$('#button-new').show();
$('#data_<%= @holiday_type.id %>').html("<%= j(render 'data', :holiday_type => @holiday_type) %>");