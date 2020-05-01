<% params[:check].each do |x| %>
	$("#data_<%= x %>").remove();
<% end %>
$("#toolbar_def").hide();