<% if @education_detail.save %>
	$('#education_detail tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#education_detail tbody').prepend("<%= j(render 'data', :education_detail => @education_detail) %>");
<% else %>
	
<% end %>