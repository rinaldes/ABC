$('#row_<%= @approval_level.id %> td:eq(1)').html("<%= @approval_level.approval_level_approvers.map{|x| [x.employee.name]}.join(', ') rescue ' ' %>");
$('#formmodal').modal('toggle');