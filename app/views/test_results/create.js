<% if @test_result.save %>
	$('#test_result tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#test_result tbody').prepend("<%= j(render 'data', :test_result => @test_result) %>");
<% else %>
	
<% end %>