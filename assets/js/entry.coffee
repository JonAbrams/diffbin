$ ->
  new_text = $('textarea#new_text')
  old_text = $('textarea#old_text')
  save_changes = $('input#save_changes')
  share_url = $('input#share_url')

  text_changed = ->
    $('#changes').html diffString old_text.val(), new_text.val()
    if new_text.val() is new_text[0].defaultValue and old_text.val() is old_text[0].defaultValue
      save_changes.attr("disabled", true)
    else
      save_changes.attr("disabled", false)

  window.onpopstate = (event) ->
    if event.state?
      state = event.state
      old_text.val state.old_text
      new_text.val state.new_text
      share_url.val "http://#{location.host}/#{state.slug}"

  # Store the state for the loaded page, if supported
  history.replaceState? {
    old_text: old_text.val()
    new_text: new_text.val()
    slug: location.pathname.replace("/", "")
  }, null, null

  $("form#entry_form").submit (event) ->
    event.preventDefault()
    new_text[0].defaultValue = new_text.val()
    old_text[0].defaultValue = old_text.val()
    save_changes.attr("disabled", true)
    $.post "/", $(this).serialize(), (results) ->
      slug = results.slug
      if typeof history.pushState isnt "undefined"
        pushResult = history.pushState {
          old_text: old_text.val()
          new_text: new_text.val()
          slug
        }, null, slug
        share_url.val "http://#{location.host}/#{slug}"
      else
        location.href = "#{slug}"
    , "json"

  $("#copy.btn").on "click", ->
    $("input#share_url").select()
  .zclip
    path: 'ZeroClipboard.swf'
    copy: -> share_url.val()
    afterCopy: ->

  $("textarea#new_text, textarea#old_text")
  .on("keyup", text_changed)
  .on("change", text_changed)
  .on("paste", text_changed)

  text_changed()
