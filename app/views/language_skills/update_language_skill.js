$('#button-new').show();
$('#data_<%= @language_skill.id %>').html("<%= j(render 'data', :language_skill => @language_skill) %>");
 $('#toolbar_language_skill').addClass("hide");
	  $('#button_edit_language_skill').addClass("hide");
	  $('#button_remove_language_skill').addClass("hide");
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