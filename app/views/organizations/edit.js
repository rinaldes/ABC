$('#data_<%= @organization.id %>').html("<%= j(render 'form', :organization => @organization) %>");
$('#button-new').hide();
// setTimeout(function(){$('input[type=radio].star').rating()}, 1000);
