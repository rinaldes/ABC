<% if @internal_work_experience.save %>
	$('#internal_work_experience tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#internal_work_experience tbody').prepend("<%= j(render 'data', :internal_work_experience => @internal_work_experience) %>");
<% else %>
	
<% end %>