$('#button-new').show();
$('#data_<%= @external_work_experience.id %>').html("<%= j(render 'data', :external_work_experience => @external_work_experience) %>");