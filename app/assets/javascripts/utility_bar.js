function el_top_out_of_viewport($el) {
  var $window = $(window),
      docViewTop = $window.scrollTop(),
      docViewBottom = docViewTop + $window.height(),
      elemTop = $el.offset().top,
      elemBottom = elemTop + $el.height();

  //console.log(docViewTop, elemTop);
  return (docViewTop >= elemTop);
}

function el_bottom_in_viewport($el) {
  var $window = $(window),
      docViewTop = $window.scrollTop(),
      docViewBottom = docViewTop + $window.height(),
      elemTop = $el.offset().top,
      elemBottom = elemTop + $el.height();

  //console.log(docViewTop, elemTop);
  return (docViewBottom >= elemBottom);
}

function el_bottom_out_of_viewport($el) {
  var $window = $(window),
      docViewTop = $window.scrollTop(),
      docViewBottom = docViewTop + $window.height(),
      elemTop = $el.offset().top,
      elemBottom = elemTop + $el.height();

  //console.log(docViewTop, elemTop);
  return (docViewBottom <= elemBottom);
}


function bottom_offset($el) {
  return $el.offset().top + $el.outerHeight();
}

function scroll_direction(previous_scroll) {
  var current_scroll = $(window).scrollTop();
  if (current_scroll > previous_scroll){
    return 'down';
  } else {
    return 'up';
  }
}

$(document).ready(function() {
  $('ul.doc-nav li').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });

  var previous_scroll = $(window).scrollTop();
      original_nav_offset = $('.doc-nav').offset().top,
      animating = false;

  _.throttle($(window).on("scroll", function(event) {
    var $nav_wrapper = $('.doc-nav-wrapper'),
        $nav = $nav_wrapper.find('.doc-nav'),
        message = '',
        direction = scroll_direction(previous_scroll);

    if( direction === 'up' && $(window).scrollTop() <= original_nav_offset && !$nav.hasClass('fixed') ){
      return;
    }

    if( direction === 'down' ) {
      if( el_top_out_of_viewport($nav_wrapper) ) {
        $nav.addClass('fixed');
        $nav.css('top', '25px');
        message = 'out of top';

        if( bottom_offset($nav) >= bottom_offset($nav_wrapper) ) {
          message = 'at bottom';
          $nav.removeClass('fixed');
          $nav.css('top', bottom_offset($nav_wrapper) - $nav.outerHeight() - original_nav_offset);
        }
      }
    } else if( direction === 'up' ) {
      if( el_bottom_out_of_viewport($nav_wrapper) ) {
        message = 'out of bottom';
        if( !$nav.hasClass('fixed') && !animating ) {
          animating = true;

          var top = $(window).scrollTop() - $nav.outerHeight()/2 + 25;
          $nav.animate({
            top: top
          }, 100, function() {
            animating = false;
            $nav.addClass('fixed');
            $nav.css('top', '25px');
          });
        }

        if( $nav.offset().top <= original_nav_offset ) {
          message = 'at top';
          $nav.removeClass('fixed');
          $nav.css('top', 'inherit');
        }
      }
    }

    previous_scroll = $(window).scrollTop();
  }), 500);
});
