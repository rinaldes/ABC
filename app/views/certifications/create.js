<% if @certification.save %>
	$('#certification tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#certification tbody').prepend("<%= j(render 'data', :certification => @certification) %>");
<% else %>
	
<% end %>