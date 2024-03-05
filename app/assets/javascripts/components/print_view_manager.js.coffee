class @FR2.PrintViewManager
  setup: ->
    printLink = document.querySelector('a[href="#print"]')
    if printLink
      printLink.addEventListener 'click', (event) ->
        window.print()
