$( document ).ready(function() {
    $('#toolbar_def').hide();
});

function submit_performance(){
	$.ajax({
		url: '/performances',
		type: 'post',
		data: {
			performance: {
				date_of_performance: $('#performance_date_of_performance').val(),
				rating: $('input[type=radio]:checked').val(),
				area_of_strength: $('#performance_area_of_strength').val(),
				area_of_development: $('#performance_area_of_development').val(),
				rater: $('#performance_rater').val(),
				position_rater: $('#performance_position_rater').val(),
				employee_id: parseInt($('#performance_employee_id').val())
			}
		}
	})
}

function update_performance(){
	$.ajax({
		url: '/performances/update_performance',
		type: 'put',
		data: {
			performance: {
				date_of_performance: $('#performance_date_of_performance').val(),
				rating: $('input[type=radio]:checked').val(),
				area_of_strength: $('#performance_area_of_strength').val(),
				area_of_development: $('#performance_area_of_development').val(),
				rater: $('#performance_rater').val(),
				position_rater: $('#performance_position_rater').val(),
				id: parseInt($('#performance_id').val())
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

function delete_performance(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/performances/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_performance(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/performances/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
