$(document).ready ()->
  if $('#fulltext_content_area').length
    # enable paragraph citations
    new FR2.ParagraphCitation $('#fulltext_content_area')

    # identify targets as appropriate
    target = window.location.hash
    targetsToSkip = ["#open-comment", "#addresses", "#page-"]

    # add link icon and tooltip to paragraph targets
    if target && !targetsToSkip.some((t) -> target.startsWith(t))
      paragraphTarget = $(target)

      # visually identify the cited paragraph
      tooltipText = "The url for this page contains a paragraph citation. This is the paragraph that is cited."
      linkIcon = $('<span>')
        .addClass('icon-fr2 icon-fr2-link')
        .data('tooltip', tooltipText)
      paragraphTarget.append linkIcon
      CJ.Tooltip.addFancyTooltip linkIcon,
        { className: 'dynamic-citation-tooltip'},
        {
          horizontalOffset: -5
          position: 'centerTop'
          verticalOffset: -12
        }

    # add highlight to print page targets
    if target && target.startsWith("#page-")
      tooltipText = "The url for this page contains a page citation. This is the page that is cited."
      printPageElements = new FR2.PrintPageElements
      printPageElements.highlightPageTargets(target, tooltipText)
