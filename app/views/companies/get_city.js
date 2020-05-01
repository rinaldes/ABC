<% if @cities.present? %>
	$("#company_city_id").html('');
	$("#company_city_id").removeAttr("disabled");
	$("#company_city_id").append("<option value=''>--select--</option>");
	<% @cities.each do |x| %>
		$("#company_city_id").append("<option value=<%= x[1]%>><%= x[0]%></option>");
	<% end %>
<% else %>
	alert('select another option !')
<% end %>