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


function submit_education_detail(){
	$.ajax({
		url: '/education_details',
		type: 'post',
		data: {
			education_detail: {
				grade: $('#education_detail_grade').val(),
				institution: $('#education_detail_institution').val(),
				start: $('#education_detail_start').val(),
				end: $('#education_detail_end').val(),
				major: $('#education_detail_major').val(),
				final_score: $('#education_detail_final_score').val(),
				employee_id: parseInt($('#position_detail_employee_id').val())
			}
		}
	})
}

function update_education_detail(){
	$.ajax({
		url: '/education_details/update_education_detail',
		type: 'put',
		data: {
			education_detail: {
				grade: $('#education_detail_grade').val(),
				institution: $('#education_detail_institution').val(),
				start: $('#education_detail_start').val(),
				end: $('#education_detail_end').val(),
				major: $('#education_detail_major').val(),
				final_score: $('#education_detail_final_score').val(),
				id: parseInt($('#education_detail_id').val())
			}
		}
	})
}

function delete_education_detail(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
      check.push(parseInt($(this).val()))
    }
	});
	$.ajax({
		url: '/education_details/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_education_detail(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
      data_id = ("/education_details/"+ $(this).val() +"/edit")
    }
	});
	$.ajax({
		url: (data_id)
	});
}


function submit_external_work_experince(){
	$.ajax({
		url: '/external_work_experinces',
		type: 'post',
		data: {
			contract: {
				name_of_company: $('#external_work_experince_name_of_company').val(),
				job_desc: $('#external_work_experince_job_desc').val(),
				position: $('#external_work_experince_position').val(),
				start: $('#external_work_experince_start').val(),
				end: $('#external_work_experince_end').val(),
				achievement: $('#external_work_experince_achievement').val(),
				employee_id: parseInt($('#external_work_experince_employee_id').val())
			}
		}
	})
}

function update_external_work_experince(){
	$.ajax({
		url: '/external_work_experinces/update_external_work_experince',
		type: 'put',
		data: {
			external_work_experince: {
				name_of_company: $('#external_work_experince_name_of_company').val(),
				job_desc: $('#external_work_experince_job_desc').val(),
				position: $('#external_work_experince_position').val(),
				start: $('#external_work_experince_start').val(),
				end: $('#external_work_experince_end').val(),
				achievement: $('#external_work_experince_achievement').val(),
				id: parseInt($('#external_work_experince_id').val())
			}
		}
	})
}

function delete_external_work_experince(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/external_work_experinces/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_external_work_experince(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/external_work_experinces/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_internal_work_experince(){
	$.ajax({
		url: '/internal_work_experinces',
		type: 'post',
		data: {
			internal_work_experince: {
				name_of_company: $('#internal_work_experince_name_of_company').val(),
				job_desc: $('#internal_work_experince_job_desc').val(),
				position: $('#internal_work_experince_position').val(),
				organization: $('#internal_work_experince_organization').val(),
				start: $('#internal_work_experince_start').val(),
				end: $('#internal_work_experince_end').val(),
				achievement: $('#internal_work_experince_achievement').val(),
				employee_id: parseInt($('#training_history_employee_id').val())
			}
		}
	})
}

function update_internal_work_experince(){
	$.ajax({
		url: '/internal_work_experinces/update_internal_work_experince',
		type: 'put',
		data: {
			training_history: {
				name_of_company: $('#internal_work_experince_name_of_company').val(),
				job_desc: $('#internal_work_experince_job_desc').val(),
				position: $('#internal_work_experince_position').val(),
				organization: $('#internal_work_experince_organization').val(),
				start: $('#internal_work_experince_start').val(),
				end: $('#internal_work_experince_end').val(),
				achievement: $('#internal_work_experince_achievement').val(),
				id: parseInt($('#internal_work_experince_id').val())
			}
		}
	})
}

function delete_internal_work_experince(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/internal_work_experinces/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_internal_work_experince(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/internal_work_experinces/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_history_of_organization(){
	$.ajax({
		url: '/history_of_organizations',
		type: 'post',
		data: {
			history_of_organization: {
				name: $('#history_of_organization_name').val(),
				phone_number: $('#history_of_organization_phone_number').val(),
				position: $('#history_of_organization_position').val(),
				statue: $('#history_of_organization_statue').val(),
				start: $('#history_of_organization_start').val(),
				end: $('#history_of_organization_end').val(),
				employee_id: parseInt($('#history_of_organization_employee_id').val())
			}
		}
	})
}

function update_history_of_organization(){
	$.ajax({
		url: '/history_of_organizations/update_history_of_organization',
		type: 'put',
		data: {
			history_of_organization: {
				name: $('#history_of_organization_name').val(),
				phone_number: $('#history_of_organization_phone_number').val(),
				position: $('#history_of_organization_position').val(),
				statue: $('#history_of_organization_statue').val(),
				start: $('#history_of_organization_start').val(),
				end: $('#history_of_organization_end').val(),
				id: parseInt($('#history_of_organization_id').val())
			}
		}
	})
}

function delete_history_of_organization(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/history_of_organizations/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_history_of_organization(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/history_of_organizations/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


function submit_certification(){
	$.ajax({
		url: '/skills',
		type: 'post',
		data: {
			certification: {
				institution: $('#certification_institution').val(),
				certification_number: $('#certification_certification_number').val(),
				name_of_certification: $('#certification_name_of_certification').val(),
				date_of_certificationn: $('#certification_date_of_certification').val(),
				description: $('#certification_description').val(),
				attachment: $('#certification_attachment').val(),
				employee_id: parseInt($('#certification_employee_id').val())
			}
		}
	})
}

function update_certification(){
	$.ajax({
		url: '/certifications/update_certification',
		type: 'put',
		data: {
			certification: {
				institution: $('#certification_institution').val(),
				certification_number: $('#certification_certification_number').val(),
				name_of_certification: $('#certification_name_of_certification').val(),
				date_of_certificationn: $('#certification_date_of_certification').val(),
				description: $('#certification_description').val(),
				attachment: $('#certification_attachment').val(),
				id: parseInt($('#certification_id').val())
			}
		}
	})
}

function delete_certification(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/certifications/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_certification(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/certifications/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}