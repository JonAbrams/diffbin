text_changed = ->
  new_text = $('textarea#new_text')
  $('#changes').html diffString $('textarea#original_text').html(), new_text.val()
  if new_text.val() is new_text[0].defaultValue
    $('input#save_changes').attr("disabled", true)
  else
    $('input#save_changes').attr("disabled", false)

$ ->
  $('textarea#new_text')
  .on('keyup', text_changed)
  .on('change', text_changed)
  
  text_changed()
