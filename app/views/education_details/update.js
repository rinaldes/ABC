$('#button-new').show();
$('#data_<%= @education_detail.id %>').html("<%= j(render 'data', :education_detail => @education_detail) %>");