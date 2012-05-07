$ ->
  new_text = $('textarea#new_text')
  old_text = $('textarea#old_text')
  save_changes = $('input#save_changes')

  text_changed = ->
    $('#changes').html diffString old_text.val(), new_text.val()
    if new_text.val() is new_text[0].defaultValue and old_text.val() is old_text[0].defaultValue
      save_changes.attr("disabled", true)
    else
      save_changes.attr("disabled", false)
  
  $("form#entry_form").submit (event) ->
    event.preventDefault()
    new_text[0].defaultValue = new_text.val()
    old_text[0].defaultValue = old_text.val()
    save_changes.attr("disabled", true)
    $.post "/", $(this).serialize(), (results_raw) ->
      results = JSON.parse(results_raw)
      if typeof history.pushState isnt "undefined"
        pushResult = history.pushState null, null, "#{results.url}"
        $('input#share_url').val results.url
      else
        location.href = "/#{results.url}"
  
  $("#copy.btn").on "click", ->
    $("input#share_url").select()
  .zclip
    path: 'ZeroClipboard.swf'
    copy: -> $("input#share_url").val()
    afterCopy: ->
    
  $("textarea#new_text, textarea#old_text")
  .on("keyup", text_changed)
  .on("change", text_changed)
  
  text_changed()

  