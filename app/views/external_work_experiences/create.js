<% if @external_work_experience.save %>
	$('#external_work_experience tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#external_work_experience tbody').prepend("<%= j(render 'data', :external_work_experience => @external_work_experience) %>");
<% else %>
	
<% end %>