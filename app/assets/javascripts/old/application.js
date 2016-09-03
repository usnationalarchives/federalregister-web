function closeOnEscape(hash) {
  $(window).one('keyup', function(event) {
    if( event.keyCode === '27' ){
      hash.w.jqmHide();
    }
  });
}

/*global modalOpen:true */
var modalOpen = function(hash) {
  closeOnEscape(hash);
  hash.w.show();
};

var jqmHandlers = {
    href: "",
    timer: "",
    show: function (hash) {
        hash.w.show();
        this.timer = setTimeout(function () {
            window.location = $('#exit_modal').attr('data-href');
        },
        10000);
        closeOnEscape(hash);
    },
    hide: function (hash) {
        hash.w.hide();
        hash.o.remove();
        clearTimeout(this.timer);
    },
    setHref: function (link) {
        $('#exit_modal').attr('data-href', link);
    }
};


function generate_exit_dialog() {
    if ($("#exit_modal").size() === 0) {

      if ( $("#flickr-exit-modal-template").length > 0 ) {
        var flickr_exit_modal_template = Handlebars.compile(
          $("#flickr-exit-modal-template").html()
        );

        $('body').append(
          flickr_exit_modal_template({})
        );

        $('#exit_modal').jqm({
            modal: true,
            toTop: true,
            onShow: jqmHandlers.show,
            onHide: jqmHandlers.hide
        });
      }

    }
}


function generate_print_disclaimer(){
  if ( $("#print-disclaimer-template").length > 0 ) {
    var print_disclaimer_template = Handlebars.compile(
      $("#print-disclaimer-template").html()
    );

    $('#print-disclaimer .fr-box .content-block').append(
      print_disclaimer_template({})
    );
  }
}


// http://www.quirksmode.org/js/cookies.html
function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for(var i=0;i < ca.length;i++) {
    var c = ca[i];
    while (c.charAt(0) ===' ') {c = c.substring(1,c.length);}
    if (c.indexOf(nameEQ) === 0) {return c.substring(nameEQ.length,c.length);}
  }
  return null;
}


$(document).ready(function () {
    // let the server know the user has JS enabled
    document.cookie = "javascript_enabled=1; path=/";

    $("input[placeholder]").textPlaceholder();

    generate_print_disclaimer();

    $(".jqmClose").live('click', function (event) {
      $(this).parent().jqmHide();
    });

    var requires_captcha_without_message = $("#email_pane").attr('data-requires-captcha-without-message') === 'true';
    var requires_captcha_with_message = $("#email_pane").attr('data-requires-captcha-with-message') === 'true';
    if( requires_captcha_without_message || requires_captcha_with_message) {
      $("#entry_email_message").bind('blur', function(event) {
        if( requires_captcha_without_message || ( requires_captcha_with_message && $("#entry_email_message").val() !== '' )) {
          $("#recaptcha_widget_div").show();
        }
        else {
          $("#recaptcha_widget_div").hide();
        }
      });
      $("#entry_email_message").blur();

      $("#entry_email_message").bind('focus', function(event) {
        if( requires_captcha_with_message ) {
          $("#recaptcha_widget_div").show();
        }
      });
    }


    $("a[href^='http://www.flickr.com']").bind('click',
    function (event) {
        var timer;
        event.preventDefault();
        generate_exit_dialog();
        $("#exit_modal .flickr_link").attr("href", $(this).attr("href")).text($(this).attr("href"));
        jqmHandlers.setHref($(this).attr("href"));
        $("#exit_modal").jqmShow().centerScreen();
    });

    if( $(".collapse").length > 0 ) {
      $(".collapse").collapse();
    }
});
