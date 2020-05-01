<% if @skill.save %>
	$('#skill tbody tr:eq(0)').remove();
	$('#button-new').show();
	$('#skill tbody').prepend("<%= j(render 'data', :skill => @skill) %>");
	$(".new-rec").remove();
<% else %>
	
<% end %>

$(".child-box").each(function(){
  $(this).click(function() {
    section = $(this).attr("data-section")
    children = $(".child-" + section)
    // $(this).parent().parent().parent().toggleClass('row_selected')

    show_button($(this))
    
    selected_count = 0
    children.each(function(){ if ($(this).is(':checked')) { selected_count += 1 } })
    if (selected_count==children.length) {
      $(".parent-" + section).prop('checked', true)
    } else{
      $(".parent-" + section).prop('checked', false)
    };
  })
})