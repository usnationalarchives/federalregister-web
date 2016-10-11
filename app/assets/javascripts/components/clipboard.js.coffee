class FR2.Clipboard
  success: false

  copyToClipboard: (text)->
    if window.clipboardData
      @_IECopy(text)
    else
      @_standardCopy(text)

    return @success

  _IECopy: (text)->
    @success = window.clipboardData.setData("Text", text)

  _FFCopy: (text)->
    window.prompt("Your browser does not support automated copy. Please copy the text below and close this window when you are done.", text)
    @success = false

  _standardCopy: (text)->
    # create a temporary element off screen.
    tempEl = $('<div>')

    tempEl.css({
      position: "absolute",
      left:     "-1000px",
      top:      "-1000px",
    })

    # add the text to the temp element.
    tempEl.text(text)

    $("body").append(tempEl)

    # select temp element.
    range = document.createRange()
    range.selectNodeContents tempEl.get(0)

    selection = window.getSelection()
    selection.removeAllRanges()
    selection.addRange(range)

    # copy to clipboard
    try
      @success = document.execCommand("copy", false, null)
    catch error
      # some versions FF require permissions
      @_FFCopy(text)
    finally
      tempEl.remove()
