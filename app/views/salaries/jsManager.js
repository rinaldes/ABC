$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_salary(){
	$.ajax({
		url: '/salaries',
		type: 'post',
		data: {
			salary: {
				reason_of_adjustment: $('#salary_reason_of_adjustment').val(),
				basic: $('#salary_basic').val(),
				transport: $('#salary_transport').val(),
				date_of_performance: $('#salary_date_of_performance').val(),
				from: $('#salary_from').val(),
				to: $('#salary_to').val(),
				employee_id: parseInt($('#salary_employee_id').val())
			}
		}
	})
}

function update_salary(){
	$.ajax({
		url: '/salaries/update_salary',
		type: 'put',
		data: {
			salary: {
				reason_of_adjustment: $('#salary_reason_of_adjustment').val(),
				basic: $('#salary_basic').val(),
				transport: $('#salary_transport').val(),
				date_of_performance: $('#salary_date_of_performance').val(),
				from: $('#salary_from').val(),
				to: $('#salary_to').val(),
				id: parseInt($('#salary_id').val())
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

function delete_salary(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/salaries/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_salary(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/salaries/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
