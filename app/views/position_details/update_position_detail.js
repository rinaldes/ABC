$('#button-new').show();
$('#data_<%= @position_detail.id %>').html("<%= j(render 'data', :position_detail => @position_detail) %>");
 $('#toolbar_position').addClass("hide");
	  $('#button_edit_position').addClass("hide");
	  $('#button_remove_position').addClass("hide");
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