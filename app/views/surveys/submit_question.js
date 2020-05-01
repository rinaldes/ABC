var html_replace = "<div class='panel box'><header class='panel-heading'>tess<span class='tools pull-right'><a href='#' onclick='editPriview();' class='fa fa-pencil'></a><a href='#' onclick='copyPreview()' class='fa fa-copy'></a><a href='#' onclick='deletePreview();' class='fa fa-trash-o'></a></span></header><div class='panel-body'>";
html_replace += "<p class='surveyQuestion'><%= params[:question][:title]%></h3><br><p class='surveyHelp'><%= params[:question][:help] %></p><br>";
<% if params[:question][:type] == "CheckBox Grid" %>
	html_replace += "<table class='table table-striped table-hover table-bordered' id='editable-sample'><thead><tr><th></th><% params[:question][:nilai][:column].each do |x| %><th class='text-center'><%= x %></th><% end %></tr></thead>";
	html_replace += "<tbody><% params[:question][:nilai][:row].each do |x| %><tr><td><%= x %></td class='text-center'><% params[:question][:nilai][:column].each do |y| %><td class='text-center'><input type='checkbox'></td><% end %></tr><% end %></tbody></table>";
<% elsif params[:question][:type] == "Radio Button Grid" %>
	html_replace += "<table class='table table-striped table-hover table-bordered' id='editable-sample'><thead><tr><th></th><% params[:question][:nilai][:column].each do |x| %><th class='text-center'><%= x %></th><% end %></tr></thead>";
	html_replace += "<tbody><% params[:question][:nilai][:row].each do |x| %><tr><td><%= x %></td class='text-center'><% params[:question][:nilai][:column].each do |y| %><td class='text-center minimal-green'><input tabindex='3' type='radio'  name='demo-radio'></td><% end %></tr><% end %></tbody></table>";
<% elsif params[:question][:type] == "TextBox Grid" %>
	html_replace += "<table class='table table-striped table-hover table-bordered' id='editable-sample'><thead><tr><th></th><% params[:question][:nilai][:column].each do |x| %><th class='text-center'><%= x %></th><% end %></tr></thead>";
	html_replace += "<tbody><% params[:question][:nilai][:row].each do |x| %><tr><td><%= x %></td class='text-center'><% params[:question][:nilai][:column].each do |y| %><td><input type='text' placeholder='' class='form-control'></td><% end %></tr><% end %></tbody></table>";
<% elsif params[:question][:type] == "Percentage Scale" %>
	html_replace += "<input id='range_5' type='text' name='range_5' value='' />";
<% end %>

html_replace += "</div></div>";
$('#preview').append(html_replace);
$('#title').html('');
$('#help').html('');
delete_html();
autoHeigth();

<% if params[:question][:type] == "Percentage Scale" %>
	$("#range_5").ionRangeSlider({
    min: 0,
    max: 10,
    type: 'single',
    step: 0.1,
    postfix: " mm",
    prettify: false,
    hasGrid: true
  });
<% end %>