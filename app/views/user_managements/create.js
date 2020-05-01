<% if @user.save %>
	$('#user_management tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#user_management tbody').prepend("<%= j(render 'data', :user => @user) %>");
<% else %>
	
<% end %>