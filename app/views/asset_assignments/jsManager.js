function setModalID(id){
	$('#id_return').val(id);
}

function setReturn(){
	$.ajax({
        url: '<%= return_asset_assignments_path %>',
        type: 'post',
        data: {
          return_id: $('#id_return').val()
        }
    })
}