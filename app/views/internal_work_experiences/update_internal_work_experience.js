$('#button-new').show();
$('#data_<%= @internal_work_experience.id %>').html("<%= j(render 'data', :internal_work_experience => @internal_work_experience) %>");