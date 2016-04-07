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
    // set the height of the nav wrapper after we've loaded web fonts
    // otherwise the height won't be correct
    $('body').on('typekit-active', function() {
      var frBox = $('.doc-nav-wrapper').siblings('.fr-box').first()

      $('.doc-document ul.doc-nav').sticky({
        context: '.doc-content.with-utility-bar'
      });
      
      // ideally we don't want a timeout here but semantic-ui sticky
      // makes the wrapper bigger than it should be - so we wait for it
      // to finish before fixing.
      setTimeout(function(){
        $('.doc-nav-wrapper').outerHeight(frBox.height() + 'px');
      }, 1000);
    });


  }

});
