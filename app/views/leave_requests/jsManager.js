$( document ).ready(function() {
    $('#toolbar_def').hide();
});

$(document).ready(function () {

    (function ($) {

        $('#filter').keyup(function () {

            var rex = new RegExp($(this).val(), 'i');
            $('.searchable tr').hide();
            $('.searchable tr').filter(function () {
                return rex.test($(this).text());
            }).show();

        })

    }(jQuery));

});

function submit_leave_request(){
	$.ajax({
		url: '/leave_requests',
		type: 'post',
		data: {
			leave_request: {
				name: $('#leave_request_name').val(),
				start_date: $('#leave_request_start_date').val(),
				end_date: $('#leave_request_end_date').val(),
				reason: $('#leave_request_reason').val(),
				description: $('#leave_request_description').val(),
				status: $('#leave_request_status').val(),
				employee_id: parseInt($('#leave_request_employee_id').val())
			}
		}
	})
}

function update_leave_request(){
	$.ajax({
		url: '/leave_requests/update_leave_request',
		type: 'put',
		data: {
			leave_request: {
				name: $('#leave_request_name').val(),
				start_date: $('#leave_request_start_date').val(),
				end_date: $('#leave_request_end_date').val(),
				reason: $('#leave_request_reason').val(),
				description: $('#leave_request_description').val(),
				status: $('#leave_request_status').val(),
				id: parseInt($('#leave_request_id').val())
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

function delete_leave_request(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/leave_requests/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_leave_request(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/leave_requests/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
