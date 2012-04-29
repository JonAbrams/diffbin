$ ->
  $("textarea.entry_text").on 'focus', (e) ->
    if this.value is this.defaultValue
      $(this).val ""
