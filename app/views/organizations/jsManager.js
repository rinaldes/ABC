$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_organization(){
	$.ajax({
		url: '/organizations',
		type: 'post',
		data: {
			organization: {
				name: $('#organization_name').val(),
				organization_parent: $('#organization_organization_parent').val(),
				company_id: parseInt($('#organization_company_id').val())
			}
		}
	})
}

function update_organization(){
	$.ajax({
		url: '/organizations/update_organization',
		type: 'put',
		data: {
			organization: {
				name: $('#organization_name').val(),
				organization_parent: $('#organization_organization_parent').val(),
				id: parseInt($('#organization_id').val())
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

function delete_organization(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/organizations/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_organization(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/organizations/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}

//POSITION

$( document ).ready(function() {
    $('#toolbar_deff').hide();
});

function submit_position(){
	$.ajax({
		url: '/organizations/position_create',
		type: 'post',
		data: {
			position: {
				name: $('#position_name').val(),
				leave_time: $('#position_leave_time').val(),
				company_id: parseInt($('#position_company_id').val())
			}
		}
	})
}

function update_position(){
	$.ajax({
		url: '/organizations/position_update',
		type: 'put',
		data: {
			position: {
				name: $('#position_name').val(),
				leave_time: $('#position_leave_time').val(),
				id: parseInt($('#position_id').val())
			}
		}
	})
}

function cek_checkbox1(){
	if($('input:checkbox:checked').length == 0){
		$('#toolbar_deff').hide();
	}else if($('input:checkbox:checked').length == 1){
		$('#toolbar_deff').show();
		$('#button_edit').show();
	}else{
		$('#toolbar_deff').show();
		$('#button_edit').hide();
	}
}

function delete_position(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/organizations/position_destroy',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_position(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/organizations/"+ $(this).val() +"/position_edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}