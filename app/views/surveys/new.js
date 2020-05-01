function add_row(id, index, section){
	$.ajax({
    type:'GET',
    url: "<%= add_row_surveys_path %>",
    data: {index: index, id: id, section: section},
    success:function(data){
    	data
    }
  });
}

function remove_row(id, index, section){
	// textbox_text, radio_button
	if (section=="radio_button_other" || section=="checkbox_other") {
		$("#"+section+"_group").remove()
		$("#"+section+"_button_0").show()
		total_button = $("."+section+"_button").length

	} else{
		$("#"+section+"_group_"+index).remove()
		total_button = $("."+section+"_button").length
		$("."+section+"_button").hide()
		$($("."+section+"_button")[total_button-1]).show()
	}

	if (section=="radio_button" || section=="checkbox") {
		if(total_button==1){
			$($("#"+section+"_other_button_0").children("span")[0]).show()
		} else {
			$($("#"+section+"_other_button_0").children("span")[0]).hide()
		}
	}

}

function get_logical_question(id, position, index){
	$.ajax({
    type:'GET',
    url: "<%= question_detail_surveys_path %>",
    data: {id: id, position: position, index: index},
    success:function(data){
    	data
    }
  });
}

function updateLogic(){
	$.ajax({
    type:'GET',
    url: "<%= reload_surveys_path %>",
    success:function(data){
    	data
    }
  });
}

function question_detail(trigger, position, index){
	if (trigger.value!=""){
		$.ajax({
	    type:'GET',
	    url: "<%= question_detail_surveys_path %>",
	    data: {id: trigger.value, position: position, index: index},
	    success:function(data){
	    	data
	    }
	  });
	} else {
		$("#logical_content_wrapper").html("")
	}
}

function question_page(trigger, index){
	if (trigger.value!=""){
		$.ajax({
	    type:'GET',
	    url: "<%= question_page_surveys_path %>",
	    data: {id: trigger.value, index: index},
	    success:function(data){
	    	data
	    }
	  });
	} else {
		$("#logical_question").html("")
	}
}

function get_question_lists(){
	$.ajax({
    type:'GET',
    url: "<%= question_list_surveys_path %>",
    success:function(data){
    	data
    }
  });
}

function changeField(trigger){
	if (trigger.value == "header_text") {
		$("#question_head").html("")
	} else {
		if($("#question_head").html().length == 0){
			$("#question_head").html("<%= j(render '/wizards/head_question') %>")
		}
	}

	if (trigger.value == ""){
		$("#question_content").html("")
	} else {
		get_view(trigger.value)
	}
}

function get_view_logic(value){
	if (value == "date") {
		set_format("dd/mm/yyyy", ".dpdyear1", ".dpdyear2")
		set_format("dd/mm", ".dpddefault1", ".dpddefault2")
		$(".form_datetime").datetimepicker({format: 'dd/mm hh:ii'});
		$(".form_datetimeyear").datetimepicker({format: 'dd/mm/yyyy hh:ii'});
		set_visibility()

	} else if(value == "time"){
		$('.time1').timepicker({
	  autoclose: true,
	  minuteStep: 1
		});
		$('.time2').timepicker({
	    autoclose: true,
	    minuteStep: 1,
	    showSeconds: true
		});
		set_duration()

	} else if(value == "upload"){
		$("#question_varians_type").change(function(){
			$(".question_upload_section").hide()
			$("#question_"+$(this).val()).show()
			switch_select(false)
			$("#question_varians_size").val("")
			$("#question_varians_file_size").val("")
		})

		$("#question_varians_size").change(function(){
			$("#question_varians_file_size").val("")
		})
	}
}

function switch_select(option){
	$(".checkbox-format").prop("checked", option)
}

function get_view(value){
	$.ajax({
    type:'POST',
    url: "<%= get_view_surveys_path %>",
    data:{view: value},
    success:function(data){
    	$("#question_content").html(data)
    	set_hide_button()
    	get_view_logic(value)
    }
  });
}

function set_hide_button(){
	$('.advance.panel .tools .fa').click(function () {
	  var el = $(this).parent('.tools').parent('.advance-heading').parent('.advance.panel').children(".advance-body")
	  if ($(this).hasClass("fa-minus-square")) {
	    $(this).removeClass("fa-minus-square").addClass("fa-plus-square");
	    el.slideUp(200);
	  } else {
	    $(this).removeClass("fa-plus-square").addClass("fa-minus-square");
	    el.slideDown(200);
	  }
	});
}

function show_dialog(trigger, target){
	$("#question_varians_" + target).click()
	document.getElementById("question_varians_"+target).onchange = function () {
		if (this.value == "") {
	  	document.getElementById(trigger.id).innerHTML = "attach "+target
		} else{
			if (this.value.length > 20) {
				filepath = "..."+this.value.substr(this.value.length - 20)
			} else {
				filepath = this.value
			}
	  	document.getElementById(trigger.id).innerHTML = "attach "+target+"("+filepath+")"
		};
	};
}

function set_format(format_date, target1, target2){
  var nowTemp = new Date();
  var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);

  var checkin = $(target1).datepicker({
  	format: format_date,
    onRender: function(date) {
      return date.valueOf() < now.valueOf() ? 'disabled' : '';
    }
  }).on('changeDate', function(ev) {
    if (ev.date.valueOf() > checkout.date.valueOf()) {
      var newDate = new Date(ev.date)
      newDate.setDate(newDate.getDate() + 1);
      checkout.setValue(newDate);
    }
    checkin.hide();
    $(target2)[0].focus();
  }).data('datepicker');

  var checkout = $(target2).datepicker({
  	format: format_date,
    startDate: new Date() + 1,
    onRender: function(date) {
      return date.valueOf() <= checkin.date.valueOf() ? 'disabled' : '';
    }
  }).on('changeDate', function(ev) {
    checkout.hide();
  }).data('datepicker');
}

function set_visibility(){
	$(".range-date").hide()
	$(".range-date-control").attr("name", "")
	$(".range-date-control").attr("id", "")
	$(".range-date-control").val("")

	if($("#question_varians_include_time").prop('checked') == true && $("#question_varians_include_year").prop('checked') == true){
		$(".form_datetimeyear1").attr("name", "question[varians][date_start]")
		$(".form_datetimeyear1").attr("id", "question_varians_date_start")

		$(".form_datetimeyear2").attr("name", "question[varians][date_end]")
		$(".form_datetimeyear2").attr("id", "question_varians_date_end")
		
		$("#range_date_time_year").show()

	} else if($("#question_varians_include_time").prop('checked') == false && $("#question_varians_include_year").prop('checked') == true){
		$(".dpdyear1").attr("name", "question[varians][date_start]")
		$(".dpdyear1").attr("id", "question_varians_date_start")

		$(".dpdyear2").attr("name", "question[varians][date_end]")
		$(".dpdyear2").attr("id", "question_varians_date_end")

		$("#range_date_year").show()
			
	} else if($("#question_varians_include_time").prop('checked') == true && $("#question_varians_include_year").prop('checked') == false){
		$(".form_datetime1").attr("name", "question[varians][date_start]")
		$(".form_datetime1").attr("id", "question_varians_date_start")

		$(".form_datetime2").attr("name", "question[varians][date_end]")
		$(".form_datetime2").attr("id", "question_varians_date_end")
		
		$("#range_date_time").show()
	
	} else {
		$(".dpddefault1").attr("name", "question[varians][date_start]")
		$(".dpddefault1").attr("id", "question_varians_date_start")

		$(".dpddefault2").attr("name", "question[varians][date_end]")
		$(".dpddefault2").attr("id", "question_varians_date_end")
		
		$("#range_date_default").show()
	}
}

function set_duration(){
	$(".time-pick").hide()
	$(".time-pick-control").attr("name", "")
	$(".time-pick-control").attr("id", "")
	$(".time-pick-control").val("")

	if($("#question_varians_include_duration").prop('checked') == true){
		$(".time2").attr("name", "question[answer]")
		$(".time2").attr("id", "question_answer")
		
		$("#time_duration").show()
	
	} else {
		$(".time1").attr("name", "question[answer]")
		$(".time1").attr("id", "question_answer")
		
		$("#time_default").show()
	}
}