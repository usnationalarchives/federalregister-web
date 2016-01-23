$(document).ready ->
  CJ.Tooltip.addFancyTooltip(
    $('.toc-document-metadata .cj-fancy-tooltip'),
    {
      className: "issue-doc-title-tooltip"
      delay: 0.3
      fade: true
      gravity: 's'
      opacity: 1
    },
    {
      position: 'centerTop'
      verticalOffset: -14
    }
  )
