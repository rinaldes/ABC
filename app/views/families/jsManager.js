$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_family(){
	$.ajax({
		url: '/families',
		type: 'post',
		data: {
			family: {
				status: $('#family_status').val(),
				name: $('#family_name').val(),
				address: $('#family_address').val(),
				education: $('#family_education').val(),
				work: $('#family_work').val(),
				birthday: $('#family_birthday').val(),
				employee_id: parseInt($('#family_employee_id').val())
			}
		}
	})
}

function update_family(){
	$.ajax({
		url: '/families/update_family',
		type: 'put',
		data: {
			family: {
				status: $('#family_status').val(),
				name: $('#family_name').val(),
				address: $('#family_address').val(),
				education: $('#family_education').val(),
				work: $('#family_work').val(),
				birthday: $('#family_birthday').val(),
				id: parseInt($('#family_id').val())
			}
		}
	})
}

function cek_checkbox(){
	if($('input:checkbox:checked').length == 0){
		$('#toolbar_def').hide();
	}else if($('input:checkbox:checked').length == 1){
		$('#toolbar_def').show();
		$('#button_edit').show();
	}else{
		$('#toolbar_def').show();
		$('#button_edit').hide();
	}
}

function delete_family(){
	var check = [];
	

	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});

	
	
	$.ajax({
		url: '/families/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_family(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/families/"+ $(this).val() +"/edit")
        }
	});
	alert(data_id)
	$.ajax({
		url: (data_id)
	});
}
