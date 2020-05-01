<% if @detail.returned %>
	$('#data_<%= @detail.id %> td:eq(4)').html("<span class='badge badge-success'> Returned </span>");
	$('#formmodal').modal('toggle');
<% end %>