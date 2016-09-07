class PrintViewManager
  screen_sheets: $("head link[media=screen]")
  print_sheets: $("head link[media=print]")

  enter: ->
    @screen_sheets.attr("media", "none")
    @print_sheets.attr("media", "all")
    $("body")
      .addClass "print_view"
      .trigger 'printView.enter'

  exit: ->
    if $("body").hasClass "print_view"
      @screen_sheets.attr "media", "screen"
      @print_sheets.attr "media", "print"
      $("body")
        .removeClass "print_view"
        .trigger 'printView.exit'

print_view_manager = new PrintViewManager()

$(window).bind('hashchange', ->
  if location.hash == "#print"
    print_view_manager.enter()
  else
    print_view_manager.exit()
).trigger('hashchange')
