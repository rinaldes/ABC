$( document ).ready(function() {
  // Generate date in a month
  var start = new Date(2016, 2, 1);
  var end = new Date(2016, 2, 29);
  var dates = [];
  while (start.getTime() < end.getTime()) {
    // dates.push(start.getDate() + '-' + (start.getMonth() + 1) + '-' + start.getFullYear());
    dates.push(start.getDate().toString());
    start.setDate(start.getDate() + 1);
  }

  // Generate value for each branch
  var branches = ['Jakarta', 'Bandung', 'Surabaya', 'Makassar'];
  var revenues = [];
  for (var i in branches) {
    revenues[i] = { name: branches[i], data: [] };
    revenues[i]['data'].push(10 + Math.floor(Math.random() * 1000));
    for (var j = 1; j < dates.length; ++j)
      revenues[i]['data'][j] = Math.floor(revenues[i]['data'][j - 1] - 100 + Math.random() * 250);
  }

  var chart = $('#updating-chart').highcharts({
    title: {
        text: '',
        x: -20
    },
    // subtitle: {
    //     text: '',
    //     x: -20
    // },
    xAxis: {
        categories: dates
    },
    yAxis: {
        title: {
            text: 'Income ($)'
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }]
    },
    tooltip: {
        valueSuffix: ' $'
    },
    legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle',
        borderWidth: 0
    },
    series: revenues
  });
});
