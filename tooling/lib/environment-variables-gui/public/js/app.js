function add_new_envar_input() {
  var name_textbox, value_textbox, input_count, envars_form;
  envars_form = document.getElementById('envars_form')
  input_count = envars_form.getElementsByTagName('input').length
  name_textbox = document.createElement('input')
  name_textbox.type = 'text'
  name_textbox.name = 'envars[' + input_count + '][name]'
  value_textbox = document.createElement('textarea')
  value_textbox.name = 'envars[' + input_count + '][value]'
  value_textbox.cols = '100'
  value_textbox.rows = '3'
  envars_form.appendChild(name_textbox);
  envars_form.appendChild(value_textbox)
  envars_form.innerHTML += '</br></br>'
}

function delete_envar_input(i) {
  var name_textbox, value_textbox;
  name_textbox = document.getElementsByName('envars[' + i + '][name]')[0]
  value_textbox = document.getElementsByName('envars[' + i + '][value]')[0]
  name_textbox.value=""
  value_textbox.value=""
}
