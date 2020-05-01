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

function submit_component(){
	$.ajax({
		url: '/components',
		type: 'post',
		data: {
			component: {
				name: $('#component_component').val(),
				date: $('#component_indicators').val()
			}
		}
	})
}

function update_component(){
	$.ajax({
		url: '/components/update',
		type: 'put',
		data: {
			component: {
				name: $('#component_component').val(),
				date: $('#component_indicators').val(),
				id: parseInt($('#component_id').val())
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

function delete_component(){
	var check = [];
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            check.push(parseInt($(this).val()))
        }
	});
	$.ajax({
		url: '/components/delete',
		type: 'delete',
		data: {
			check: check
		}
	});
}

function edit_component(){
	var data_id;
	$('input[type=checkbox]').each(function(){
		if ($(this).is(":checked")) {
            data_id = ("/components/"+ $(this).val() +"/edit")
        }
	});
	$.ajax({
		url: (data_id)
	});
}
