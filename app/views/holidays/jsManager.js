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

function submit_holiday(){
	$.ajax({
		url: '/holidays',
		type: 'post',
		data: {
			holiday: {
				name: $('#holiday_name').val(),
				start: $('#holiday_start').val(),
				end: $('#holiday_end').val(),
				mandays: $('#holiday_mandays').val(),
				employee_id: parseInt($('#holiday_employee_id').val())
			},
			annual_leave: $('#holiday_annual_leave').is(':checked'),
		}
	})
}

function update_holiday(){
	$.ajax({
		url: '/holidays/update_holiday',
		type: 'put',
		data: {
			holiday: {
				name: $('#holiday_name').val(),
				start: $('#holiday_start').val(),
				end: $('#holiday_end').val(),
				annual_leave: $('#holiday_annual_leave').is(':checked'),
				mandays: $('#holiday_mandays').val(),
				id: parseInt($('#holiday_id').val())
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

function delete_holiday(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/holidays/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_holiday(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/holidays/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
