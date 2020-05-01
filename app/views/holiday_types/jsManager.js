$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_holiday_type(){
	$.ajax({
		url: '/holiday_types',
		type: 'post',
		data: {
			holiday_type: {
				code: $('#holiday_type_code').val(),
				name: $('#holiday_type_name').val(),
				as_leave: $('#checkbox8').val()
			}
		}
	})
}

function update_holiday_type(){
	$.ajax({
		url: '/holiday_types/update_holiday_type',
		type: 'put',
		data: {
			holiday_type: {
				code: $('#holiday_type_code').val(),
				name: $('#holiday_type_name').val(),
				as_leave: $('#holiday_type_as_leave').val(),
				id: parseInt($('#holiday_type_id').val())
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

function delete_holiday_type(){
	var check = [];
	

	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});

	
	
	$.ajax({
		url: '/holiday_types/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_holiday_type(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/holiday_types/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}


