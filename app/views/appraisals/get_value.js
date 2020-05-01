$('#appraisal_employee_id').val("<%= j @employee.id.to_s %>")
$('#organization').val("<%= j @employee.organization.name.to_s %>")