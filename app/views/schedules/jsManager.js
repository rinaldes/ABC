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

function getEmployee(){
	if($('#schedule_organization_id').val() != ""){
		$.ajax({
		    type:'GET',
		    url: "<%= get_employee_schedules_path %>",
		    data: {
		    	organization_id: $('#schedule_organization_id').val()
		    }
		});
	}else{
		$('table tbody').html("")
	}
	
}

function check_ceck(){
	$('table tbody tr:eq(0) td:eq(1) input:checkbox').is(":checked")
	$('table tbody tr:eq(0) td:eq(1) input:checkbox').val()
	var array_check = [];
	var loop = $('table tbody tr').length;
	for(var a = 0; a < loop; a++){
		if($('table tbody tr:eq('+ a +') td:eq(1) input:checkbox').is(":checked")){
			array_check.push($('table tbody tr:eq('+ a +') td:eq(1) input:checkbox').val())
		}
	}
	$('#many_employee').val(JSON.stringify(array_check));
	$('form').submit();
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

function delete_schedule(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/schedules/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}