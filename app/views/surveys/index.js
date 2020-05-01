$("#list").html("<%= j(render partial: 'list', locals: {surveys: @surveys, per_page: @per_page, surveys_count: @surveys_count}) %>");
$("#paging").html("<%= j(render partial: 'shared/paging', locals: {records: @surveys, per_page: @per_page, count: @surveys_count, page: @page}) %>");
