class @FR2.FormUtils
  @enforceCharactersRemaining: (el)->
    input = $(el).find 'input'
    @updateCharacterCount input
    @visuallyNotifyUser input

  @charactersRemaining: (input)->
    $input = $(input)
    li = $input.closest 'li'
    maxChars = li.data 'max-size'
    usedChars = 0

    if $input.val()? && $input.val() != ""
      usedChars = $input.val().length

    maxChars - usedChars

  @addCharCountError: (input)->
    $input = $(input)
    li = $input.closest 'li'
    warnThreshold = li.data 'size-warn-at'

    if li.hasClass('string') && warnThreshold?
      @charactersRemaining(input) <= warnThreshold
    else
      false

  @updateCharacterCount: (input)->
    $input = $(input)
    errorField = $input
      .siblings 'p.inline-errors'
      .first()
    remaining = @charactersRemaining $input

    text = @remaining_string remaining

    if @addCharCountError $input
      if errorField.length == 0
        $input
          .after(
            $('<p>').addClass 'inline-errors'
          )
        errorField = $input
          .siblings 'p.inline-errors'
          .first()

      errorField.text text
    else
      if errorField.length != 0
        errorField
          .text('')
          .remove()

  @remaining_string: (count)->
    if count == 1
      text = ' character left'
    else if count > 1 || count == 0
      text = ' characters left'
    else if count == -1
      text = ' character over limit'
    else if count < -1
      text = ' characters over limit'

    Math.abs(count) + text

  @visuallyNotifyUser: (input)->
    $input = $(input)
    li = $input.closest('li')
    remaining = @charactersRemaining $input
    errorField = $input
      .siblings 'p.inline-errors'
      .first()

    if remaining < 0
      li.addClass 'error'
    else
      li.removeClass 'error'

    if remaining >= 0
      errorField.addClass 'warning'
    else
      errorField.removeClass 'warning'

  @validateField: (el)->
    $el = $(el)
    input = $el.find 'input'

    if input? && input.val()?
      if !@addCharCountError(input) && input.val().length > 0
        $el
          .removeClass 'error'
          .find 'p.inline-errors'
          .text ''
