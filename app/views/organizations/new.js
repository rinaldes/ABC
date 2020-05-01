
$('#organization tbody').prepend("<%= j(render 'form', :organization => @organization) %>");
$('#button-new').hide();
