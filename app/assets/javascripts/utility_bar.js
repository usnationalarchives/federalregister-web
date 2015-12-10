$(document).ready(function() {
  $('ul.doc-nav > li').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });

  $('ul.doc-nav > li').click(function(e) {
    // this shouldn't be neccessary but is for some reason...
    if( e.toElement.tagName !== 'A' ) {
      e.preventDefault();
    }
    e.stopPropagation();
  });

  if( $('.doc-nav-wrapper').length > 0 ) {
    $('.doc-nav-wrapper').outerHeight( $('.doc-nav-wrapper').siblings('.fr-box').first().height() + 'px' );
  }

  var utilityNavScroller;
  utilityNavScroller = new FR2.ElementScroller(
    $('.doc-document ul.doc-nav'),
    {
      offsets: { bottom: 192 },
      container: {
        el: $('.doc-nav-wrapper')
      }
    }
  );

});
