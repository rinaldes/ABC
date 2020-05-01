function generateCity(){
	var prov = $('#company_province_id').val();
	$.ajax({
		url: '<%= get_city_companies_path %>',
		type: 'get',
		data: {
			prov_id: prov
		}
	})
}