function changeField(){
	if($("#question").val() == "Radio Button Grid"){
		radio_button_grid();
  }else if($("#question").val() == "TextBox"){
		textbox();
  }else if($("#question").val() == "Yes/No"){
		yesno();
	}else if($("#question").val() == "CheckBox Grid"){
		checkbox_grid();
	}else if($("#question").val() == "TextBox Grid"){
		textbox_grid();
	}else if($("#question").val() == "Ranking"){
		ranking();
	}else if($("#question").val() == "Percentage Scale"){
		percentage_scale();
	}else if($("#question").val() == "Radio Button Scale"){
		radio_button_scale();
	}
}

function ranking(){
	delete_html();
	html_replace = "<div class='form-group'><label class='col-lg-2 control-label'>Option</label><div class='col-lg-6'><textarea class='form-control'></textarea></div><label class='col-lg-2 control-label'>Use 'Enter' for seperate item</label> </div><div class='form-group'><label class='col-lg-2 control-label'>Answer field</label><div class='col-lg-6'><input class='form-control'></input></div><label class='col-lg-2 control-label'>if blank, first option will be default</label> </div><div class='form-group'><label class='col-lg-2 control-label'>Ranking</label><div class='col-lg-2'><input class='form-control' type='number'></div><label class='col-lg-1 control-label'>To</label><div class='col-lg-2'><input class='form-control' type='number'></div></div></div>";
	html_replace2 = "<div id='row_origin'><div class='form-group'><div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='addRow(0);'><i class='fa fa-plus'></i></button> </span></div> </div> </div> <div id='tambah_row'></div>";
	$('#otherQuestion').html(html_replace);
	$("#question_field").html(html_replace2);
}

function percentage_scale(){
	delete_html();
	html_replace = "<div class='form-group'><div class='col-lg-2'></div><div class='col-lg-3'><input class='form-control' placeholder='Text Before'></input></div><div class='col-lg-3'><input class='form-control' placeholder='Text After'></input></div></div><div class='form-group'><label class='col-lg-2 control-label'>Answer field</label><div class='col-lg-3'><input class='form-control'></input></div><label class='col-lg-2 control-label'>0-100</label> </div><div class='form-group'><label class='col-lg-2 control-label'>Increment</label><div class='col-lg-3'><input class='form-control'></input></div><label class='col-lg-2 control-label'>Only allow even number, max 100</label> </div>";
	$('#otherQuestion').html(html_replace);
}


function radio_button_scale(){
	delete_html();
	row_scale();
	autoHeigth();
}

function radio_button_grid(){
	delete_html();
	row_column();
	autoHeigth();
}

function row_scale(){
	html_replace = "<div id='row_origin'><div class='form-group'><div class='col-lg-4'><input class='form-control' placeholder='Text Before'></input></div><div class='col-lg-4'> <input type='text' placeholder='Text After' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='tambahRowScale(0);'><i class='fa fa-plus'></i></button> </span></div> </div> </div> <div id='tambah_row'></div>";
	$("#question_field").html(html_replace);
	advance_setting = "<div class='form-group'><label class='col-lg-2 control-label'>Increment</label><div class='col-lg-4'><input type='text' id='help' class='form-control' placeholder=''></div><label class='col-lg-2 control-label'>Max 100</label></div>";
	$("#advance_setting").html(advance_setting);
	autoHeigth();
}

function yesno(){
	delete_html();
	html_replace = "<div style='position: relative;' class='iradio_minimal checked'><input type='radio' name='yesno' value='Yes'checked><label>Yes</label> <input type='radio' name='yesno' value='No'><label>No</label> </div> ";
	$("#question_field").html(html_replace);

 
	autoHeigth();

}

function textbox(){
	delete_html();
	html_replace = "<input type=\"text\" class=\"form-control\" placeholder=\"Their Answer\">";
	$("#question_field").html(html_replace);

  advance_setting = "<div class='panel box'><header class='panel-heading'><span class='tools'><a href='javascript:;' class='fa fa-minus-square'></a></span>Advanced Setting</header><div class='panel-body'><div class='form-group'>   <div class='col-lg-12 checkbox'><input type='checkbox' checked='' ><label>Data Validation</label></div></div><div class='form-group'>   <div class='col-lg-2'><select class='form-control' id='question' name='question'><option value='Select At Least'>Select At Least</option><option value='Select At Most'>Select At Most</option><option value='Select Exactly'>Select Exactly</option></select></div><div class='col-lg-2'><input type='text' class='form-control' placeholder=''></div><div class='col-lg-8'><input type='text' class='form-control' placeholder=''></div></div>";
	$("#advance_setting").html(advance_setting);

	autoHeigth();

}
function delete_html(){
	$("#otherQuestion").html("");
	$("#question_field").html("");
  $("#advance_setting").html("");
}

function checkbox_grid(){
	delete_html();
	row_column();
	advance_setting = "<div class='panel box'><header class='panel-heading'><span class='tools'><a href='javascript:;' class='fa fa-minus-square'></a></span>Advanced Setting</header><div class='panel-body'><div class='form-group'>   <div class='col-lg-12 checkbox'><input type='checkbox' checked='' ><label>Data Validation</label></div></div><div class='form-group'>   <div class='col-lg-2'><select class='form-control' id='question' name='question'><option value='Select At Least'>Select At Least</option><option value='Select At Most'>Select At Most</option><option value='Select Exactly'>Select Exactly</option></select></div><div class='col-lg-2'><input type='text' class='form-control' placeholder=''></div><div class='col-lg-8'><input type='text' class='form-control' placeholder=''></div></div></div></div>";
	$("#advance_setting").html(advance_setting);
	autoHeigth();
}

function row_column(){
	html_replace = "<div id='row_origin'><div class='form-group'> <label class='col-lg-3 control-label'>Row 1 Label</label> <div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='tambahRow(0);'><i class='fa fa-plus'></i></button> </span></div> </div> </div> <div id='tambah_row'></div> <hr> <div id='column_origin'><div class='form-group'> <label class='col-lg-3 control-label'>Column 1 Label</label> <div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='tambahColumn();'><i class='fa fa-plus'></i></button> </span></div> </div> </div></div> <div id='tambah_column'></div>";
	$("#question_field").html(html_replace);
}

function textbox_grid(){
	delete_html();
	row_column();
	advance_setting = "<div class='panel box'><header class='panel-heading'><span class='tools'><a href='javascript:;' class='fa fa-minus-square'></a></span>Advanced Setting</header><div class='panel-body'><div class='form-group'>   <div class='col-lg-12 checkbox'><input type='checkbox' checked='' ><label>Data Validation</label></div></div><div class='form-group'>   <div class='col-lg-2'><select class='form-control' id='question' name='question'><option value='Number'>Number</option><option value='Text'>Text</option></select></div><div class='col-lg-10'><input type='text' class='form-control' placeholder='Custom Error Text'></div></div></div></div>";
	$("#advance_setting").html(advance_setting);
	autoHeigth();
}

function tambahRow(a){
	var n = $('#tambah_row div').length/2+2;
	html_replace = "<div class='form-group' id='row_"+a+"'> <label class='col-lg-3 control-label'>Row "+n+" Label</label> <div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='kurangRow("+a+");'><i class='fa fa-minus'></i></button> </span></div> </div>"
	$("#tambah_row").append(html_replace);
	$('#row_origin button').attr('onclick', 'tambahRow('+(a+1)+')');
	autoHeigth();
}

function tambahRowScale(a){
	// var n = $('#tambah_row input').length/2+2;
	// html_replace = "<div class='form-group' id='row_"+a+"'><div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='kurangRow("+a+");'><i class='fa fa-minus'></i></button> </span></div> </div>"
	html_replace = "<div class='form-group' id='row_"+a+"'><div class='col-lg-4'><input class='form-control' placeholder='Text Before'></input></div><div class='col-lg-4'> <input type='text' placeholder='Text After' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='kurangRowScale("+a+");'><i class='fa fa-minus'></i></button> </span></div> </div>"
	$("#tambah_row").append(html_replace);
	$('#row_origin button').attr('onclick', 'tambahRowScale('+(a+1)+')');
	autoHeigth();
}

function addRow(a){
	var n = $('#tambah_row div').length/2+2;
	html_replace = "<div class='form-group' id='row_"+a+"'><div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='kurangRow("+a+");'><i class='fa fa-minus'></i></button> </span></div> </div>"
	$("#tambah_row").append(html_replace);
	$('#row_origin button').attr('onclick', 'addRow('+(a+1)+')');
	autoHeigth();
}

function tambahColumn(a){
	var n = $('#tambah_column div').length/2+2;
	html_replace = "<div class='form-group' id='column_"+a+"'> <label class='col-lg-3 control-label'>Column "+n+" Label</label> <div class='col-lg-8'> <input type='text' placeholder='' class='form-control'> <span class='input-group-btn add-on'> <button class='btn btn-primary' type='button' onclick='kurangColumn("+a+");'><i class='fa fa-minus'></i></button> </span></div> </div>"
	$("#tambah_column").append(html_replace);
	$('#column_origin button').attr('onclick', 'tambahColumn('+(a+1)+')');
	autoHeigth();
}

function kurangRow(id){
	$('#row_'+ id).remove();
	var n = $('#tambah_row label').length;
	for(var a = 0; a<n;a++){
		$('#tambah_row label:eq('+a+')').html('Row '+(a+2)+' Label')
	}
}

function kurangRowScale(id){
	$('#row_'+ id).remove();
}

function kurangColumn(id){
	$('#column_'+ id).remove();
	var n = $('#tambah_column label').length;
	for(var a = 0; a<n;a++){
		$('#tambah_column label:eq('+a+')').html('column '+(a+2)+' Label')
	}
}

function autoHeigth(){
	$("#form_question").parent('section').parent('div').attr('style', 'height:'+$("#wizard").height()+'px;');
	// $('.wizard .content').attr('style','min-height:40em;');
}

function submitQuestion(){
	var questionValue = {};
	var row = [], column = [];
	row.push($('#row_origin input').val());
	column.push($('#column_origin input').val());
	var tambah_row = $('#tambah_row input').length;
	var tambah_column = $('#tambah_column input').length;

	if($("#question").val() == "Percentage Scale"){
		
	}else if($("#question").val() == "Radio Button Grid"){
		
	}


	for(var a = 0;a<tambah_row; a++){
		row.push($('#tambah_row input:eq('+a+')').val());
	}
	for(var a = 0;a<tambah_column; a++){
		column.push($('#tambah_column input:eq('+a+')').val());
	}
	questionValue['row'] = row;
	questionValue['column'] = column;
	$.ajax({
		url: '<%= submit_question_surveys_path %>',
		type: 'post',
		data: {
			question: {
				title: $('#title').val(),
				help: $('#help').val(),
				type: $('#question').val(),
				nilai: questionValue
			}
		}
	})
}








