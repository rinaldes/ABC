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

function submit_overtime_request(){
	$.ajax({
		url: '/overtime_requests',
		type: 'post',
		data: {
			overtime_request: {
				name: $('#overtime_request_name').val(),
				date: $('#overtime_request_date').val(),
				start_time: $('#overtime_request_start_time').val(),
				end_time: $('#overtime_request_end_time').val(),
				reason: $('#overtime_request_reason').val(),
				status: $('#overtime_request_status').val()
			}
		}
	})
}

function update_overtime_request(){
	$.ajax({
		url: '/overtime_requests/update',
		type: 'put',
		data: {
			overtime_request: {
				name: $('#overtime_request_name').val(),
				date: $('#overtime_request_date').val(),
				start_time: $('#overtime_request_start_time').val(),
				end_time: $('#overtime_request_end_time').val(),
				reason: $('#overtime_request_reason').val(),
				status: $('#overtime_request_status').val(),
				id: parseInt($('#overtime_request_id').val())
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

function delete_overtime_request(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/overtime_requests/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_overtime_request(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/overtime_requests/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
