
$('table tbody').html("<%= j(render 'table_form', employees: @employees ) %>")