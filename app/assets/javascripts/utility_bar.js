var FollowElement = (function() {
  var FollowElement = function() {
    this.default_options = {
      top_offset: 0, /* where the $el starts offset from $el_wrapper */
      bottom_offset: 0, /* where to consider the bottom of $el to be */
      throttle_value: 500, /* how often to check whether we need to modify $el */
      debug: false /* logs messages to console for debugging */
    };

    this.animating = false;
  };

  FollowElement.prototype = {
    init: function($el, $el_wrapper, options) {
      this.$el = $el;
      this.$el_wrapper = $el_wrapper;
      this.$window = $(window);
      this.previous_scroll = $(window).scrollTop();
      this.original_offset = $el.offset().top;

      if(typeof options === 'object') {
        this.options = $.extend(this.default_options, options);
      } else {
        this.options = this.default_options;
      }

      this.update_on_scroll();
    },

    /* updates properties as the page scrolls, triggers action as appropriate */
    update_on_scroll: function() {
      var Scroller = this;

      _.throttle(Scroller.$window.on("scroll", function(event) {
        var direction = Scroller.scroll_direction(Scroller.previous_scroll),
            message = '';

        if( direction === 'up' && Scroller.$window.scrollTop() <= Scroller.original_offset && !Scroller.$el.hasClass('fixed') ){
          message = 'no follow';
          return;
        }

        if( direction === 'down' ) {
          if( Scroller.el_top_out_of_viewport(Scroller.$el_wrapper) ) {
            Scroller.$el.addClass('fixed');
            Scroller.$el.css('top', Scroller.options.top_offset);
            message = 'out of top';

            if( Scroller.bottom_offset(Scroller.$el) >= Scroller.bottom_offset(Scroller.$el_wrapper) ) {
              Scroller.$el.removeClass('fixed');
              Scroller.$el.css('top', Scroller.bottom_offset(Scroller.$el_wrapper) - Scroller.$el.outerHeight() - Scroller.original_offset - Scroller.options.bottom_offset);
              message = 'at bottom';
            }
          }
        } else if( direction === 'up' ) {
          if( Scroller.el_bottom_out_of_viewport(Scroller.$el_wrapper) ) {
            if( !Scroller.$el.hasClass('fixed') && !Scroller.animating ) {
              Scroller.animating = true;

              var top = Scroller.$el.position().top + Scroller.options.top_offset - 200;
              Scroller.$el.animate({
                top: top
              }, 100, function() {
                Scroller.animating = false;
                Scroller.$el.addClass('fixed');
                Scroller.$el.css('top', Scroller.options.top_offset);
              });
            }
            message = 'out of bottom';

            if( Scroller.$el.offset().top <= Scroller.original_offset ) {
              Scroller.$el.removeClass('fixed');
              Scroller.$el.css('top', 'inherit');
              message = 'at top';
            }
          }
        }

        Scroller.previous_scroll = Scroller.$window.scrollTop();

        if( Scroller.options.debug ) { console.log(direction, message); }
      }), this.options.throttle_value);
    },

    /* returns the bottom of an element based on its offset and height */
    bottom_offset: function($el) {
      var Scroller = this,
          offset = $el.offset().top + $el.outerHeight();

      if( $el == Scroller.$el ) {
        offset += Scroller.options.bottom_offset;
      }

      return offset;
    },

    /* returns whether the page is being scrolled up or down */
    scroll_direction: function(previous_scroll) {
      var current_scroll = $(window).scrollTop();
      if (current_scroll > previous_scroll){
        return 'down';
      } else {
        return 'up';
      }
    },

    el_top_out_of_viewport: function($el) {
      var Scroller = this,
          docViewTop = Scroller.$window.scrollTop(),
          elemTop = $el.offset().top;

      return (docViewTop >= elemTop);
    },

    el_bottom_in_viewport: function($el) {
      var Scroller = this,
          docViewTop = Scroller.$window.scrollTop(),
          docViewBottom = docViewTop + Scroller.$window.height();

      return (docViewBottom >= Scroller.bottom_offset($el));
    },

    el_bottom_out_of_viewport: function($el) {
      var Scroller = this,
          docViewTop = Scroller.$window.scrollTop(),
          docViewBottom = docViewTop + Scroller.$window.height();

      return (docViewBottom <= Scroller.bottom_offset($el));
    }

  };

  return FollowElement;
})();

$(document).ready(function() {
  $('ul.doc-nav li').hover(function() {
    $(this).find('.dropdown-menu').stop(true, true).show();
    $(this).addClass('open');
  }, function() {
    $(this).find('.dropdown-menu').stop(true, true).hide();
    $(this).removeClass('open');
  });

  if( $('.doc-official .doc-nav').length > 0 ) {
    var nav_scroller = new FollowElement();
    nav_scroller.init($('.doc-nav'),
                      $('.doc-nav-wrapper'),
                      {
                        top_offset: 15,
                        bottom_offset: 225,
                        debug: false
                      }
                     );
  }

  if( $('.doc-nav-wrapper').length > 0 ) {
    $('.doc-nav-wrapper').outerHeight( $('.doc-nav-wrapper').siblings('.fr-box').first().height() + 'px' );
  }
});
