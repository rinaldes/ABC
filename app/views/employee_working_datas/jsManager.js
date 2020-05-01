function show_button(element){
	section = element.attr("data-section")
	if (element.attr("data-position")=="parent") {
		if (element.is(':checked')) {
			position=2
		} else{
			position=0
		}
	} else{
		children = $(".child-" + section)
		selected_count = 0
    children.each(function(){ if ($(this).is(':checked')) { selected_count += 1 } })
    if (selected_count>1) {
    	position=2
    } else if(selected_count==1){
    	position=1
    } else {
    	position=0
    }
	}
  if (position==1) {
	  $('#toolbar_'+section).removeClass("hide");
	  $('#button_edit_'+section).removeClass("hide");
	  $('#button_remove_'+section).removeClass("hide");
  } else if(position==2){
	  $('#toolbar_'+section).removeClass("hide");
	  $('#button_edit_'+section).addClass("hide");
	  $('#button_remove_'+section).removeClass("hide");
  } else {
	  $('#toolbar_'+section).addClass("hide");
	  $('#button_edit_'+section).addClass("hide");
	  $('#button_remove_'+section).addClass("hide");
  }
}

function set_delete_url(url){
	$("#modal_delete_button").attr("onclick", "delete_detail('" + url + "')")
	$("#modal_cancel_button").attr("onclick", "unset_delete_url()")
}

function unset_delete_url(){
	$("#modal_delete_button").attr("onclick", "")
	$("#modal_cancel_button").attr("onclick", "")
}

function delete_detail(url){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
      check.push(parseInt($(this).val()))
    }
	});
	$.ajax({
		url: url,
		type: 'delete',
		data: {
			check: check
		}
	});
}


function submit_position_detail(){
	$.ajax({
		url: '/position_details',
		type: 'post',
		data: {
			position_detail: {
				start: $('#position_detail_start').val(),
				end: $('#position_detail_end').val(),
				position: $('#position_detail_position').val(),
				organization: $('#position_detail_organization').val(),
				reason_for_change: $('#position_detail_reason_for_change').val(),
				employee_id: parseInt($('#position_detail_employee_id').val())
			}
		}
	})
}

function update_position_detail(){
	$.ajax({
		url: '/position_details/update_position_detail',
		type: 'put',
		data: {
			position_detail: {
				start: $('#position_detail_start').val(),
				end: $('#position_detail_end').val(),
				position: $('#position_detail_position').val(),
				organization: $('#position_detail_organization').val(),
				reason_for_change: $('#position_detail_reason_for_change').val(),
				id: parseInt($('#position_detail_id').val())
			}
		}
	})
}

function delete_position_detail(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
      check.push(parseInt($(this).val()))
    }
	});
	$.ajax({
		url: '/position_details/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_position_detail(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
      data_id = ("/position_details/"+ $(this).val() +"/edit")
    }
	});
	$.ajax({
		url: (data_id)
	});
}


function submit_contract(){
	$.ajax({
		url: '/contracts',
		type: 'post',
		data: {
			contract: {
				contract_type: $('#contract_contract_type').val(),
				start: $('#contract_start').val(),
				end: $('#contract_end').val(),
				attachment: $('#contract_attachment').val(),
				employee_id: parseInt($('#contract_employee_id').val())
			}
		}
	})
}

function update_contract(){
	$.ajax({
		url: '/contracts/update_contract',
		type: 'put',
		data: {
			contract: {
				contract_type: $('#contract_contract_type').val(),
				start: $('#contract_start').val(),
				end: $('#contract_end').val(),
				attachment: $('#contract_attachment').val(),
				id: parseInt($('#contract_id').val())
			}
		}
	})
}

function delete_contract(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/contracts/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_contract(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/contracts/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_training_history(){
	$.ajax({
		url: '/training_histories',
		type: 'post',
		data: {
			training_history: {
				training_type: $('#training_history_training_type').val(),
				start: $('#training_history_start').val(),
				end: $('#training_history_end').val(),
				sponsor: $('#training_history_sponsor').val(),
				result: $('#training_history_result').val(),
				employee_id: parseInt($('#training_history_employee_id').val())
			}
		}
	})
}

function update_training_history(){
	$.ajax({
		url: '/training_histories/update_training_history',
		type: 'put',
		data: {
			training_history: {
				training_type: $('#training_history_training_type').val(),
				start: $('#training_history_start').val(),
				end: $('#training_history_end').val(),
				sponsor: $('#training_history_sponsor').val(),
				result: $('#training_history_result').val(),
				id: parseInt($('#training_history_id').val())
			}
		}
	})
}

function delete_training_history(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/training_histories/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_training_history(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/training_histories/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_language_skill(){
	$.ajax({
		url: '/language_skills',
		type: 'post',
		data: {
			language_skill: {
				language: $('#language_skill_language').val(),
				reading: $('#language_skill_reading').val(),
				writing: $('#language_skill_writing').val(),
				speaking: $('#language_skill_speaking').val(),
				employee_id: parseInt($('#language_skill_employee_id').val())
			}
		}
	})
}

function update_language_skill(){
	$.ajax({
		url: '/language_skills/update_language_skill',
		type: 'put',
		data: {
			language_skill: {
				language: $('#language_skill_language').val(),
				reading: $('#language_skill_reading').val(),
				writing: $('#language_skill_writing').val(),
				speaking: $('#language_skill_speaking').val(),
				id: parseInt($('#language_skill_id').val())
			}
		}
	})
}

function delete_language_skill(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/language_skills/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_language_skill(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/language_skills/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


function submit_skill(){
	$.ajax({
		url: '/skills',
		type: 'post',
		data: {
			skill: {
				skill_type: $('#skill_skill_type').val(),
				employee_id: parseInt($('#skill_employee_id').val())
			}
		}
	})
}

function update_skill(){
	$.ajax({
		url: '/skills/update_skill',
		type: 'put',
		data: {
			skill: {
				skill_type: $('#skill_skill_type').val(),
				id: parseInt($('#skill_id').val())
			}
		}
	})
}

function delete_skill(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/skills/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_skill(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/skills/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}

function submit_violation_detail(){
	$.ajax({
		url: '/violation_details',
		type: 'post',
		data: {
			violation_detail: {
				violation_type: $('#violation_detail_violation_type').val(),
				violation_description: $('#violation_detail_violation_description').val(),
				start: $('#violation_detail_start').val(),
				due_date: $('#violation_detail_due_date').val(),
				punishment: $('#violation_detail_punishment').val(),
				employee_id: parseInt($('#violation_detail_employee_id').val())
			}
		}
	})
}

function update_violation_detail(){
	$.ajax({
		url: '/violation_details/update_violation_detail',
		type: 'put',
		data: {
			violation_detail: {
				violation_type: $('#violation_detail_violation_type').val(),
				violation_description: $('#violation_detail_violation_description').val(),
				start: $('#violation_detail_start').val(),
				due_date: $('#violation_detail_due_date').val(),
				punishment: $('#violation_detail_punishment').val(),
				id: parseInt($('#violation_detail_id').val())
			}
		}
	})
}

function delete_violation_detail(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/violation_details/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_violation_detail(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/violation_details/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}