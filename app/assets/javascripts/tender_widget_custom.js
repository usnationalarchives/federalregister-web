(function(){

  var articlePageRegEx = new RegExp('\/documents\/\\d{4}');
  var articlePage = function() {
    return articlePageRegEx.test(window.location.href);
  };

  var showInterstitialModal = function () {
    var interstitial_tender_modal_template = $('#interstitial-tender-modal-template');
    if ( interstitial_tender_modal_template.length > 0 ) {
      interstitial_tender_modal_template = Handlebars.compile( interstitial_tender_modal_template.html() );

      var document_feedback_text,
          document_button_enabled = '',
          formal_comment_link = $('.button.formal_comment');

      if( formal_comment_link.length > 0 && formal_comment_link.first().attr('href') != '#addresses') {
        document_feedback_text = "If you would like to submit a formal comment to the issuing agency on the document you are currently viewing, please use the 'Document Feedback' button below.";
      } else if( $('#addresses').length > 0 || $('#further-info').length > 0 ) {
        document_feedback_text = "If you would like to comment on the current document, please use the 'Document Comment' button below for instructions on contacting the issuing agency";
      } else {
        document_feedback_text = "The current document is not open for formal comment, please use other means to contact " + $('.metadata .agencies').html() + " directly.";
        document_button_enabled = 'disabled';
      }


      FR2.Modal.displayModal(
        '',
        interstitial_tender_modal_template({
          document_feedback_text: document_feedback_text,
          document_button_enabled: document_button_enabled
        }),
        {
          modalId: '#interstitial_tender_modal',
          includeTitle: false,
          modalClass: 'fr_modal wide'
        }
      );

      $('#interstitial_tender_modal').on('click', '.site_feedback .button', function(event) {
        event.preventDefault();
        show();
      });

      $('#interstitial_tender_modal').on('click', '.document_feedback .button:not(.disabled)', function(event) {
        event.preventDefault();
        $('#interstitial_tender_modal').jqmHide();

        var formal_comment_link = $('.button.formal_comment');

        if( formal_comment_link.length > 0 && formal_comment_link.first().attr('href') != '#addresses') {
          /* open in new window */
          window.open(
            formal_comment_link.attr('href'),
            '_blank'
          );
        } else if( $('#addresses').length > 0 ) {
          window.location.href = '#addresses';
        } else {
          window.location.href = '#further-info';
        }
      });
    } else {
      /* fallback to showing the tender modal */
      show();
    }
  }

  var visible = false;
  var initialized = false;

  var showWidget = function(){
    if( articlePage() ) {
      showInterstitialModal();
    } else {
      show();
    }
  };

  var show = function(){
    if (!initialized) {
      initializeZenDesk();
    } else {
      document.getElementById('tender_window').style.display = '';
      visible = true;
    }
  };

  var hide = function(){
    document.getElementById('tender_window').style.display = 'none';
    if (typeof(Tender) === "undefined" || !Tender.hideToggle) document.getElementById('tender_toggler').style.display = '';
    visible = false;
  };

  var initializeZenDesk = function () {
    new FR2.ZendeskFormHandler
  }

  if (typeof(Tender) != "undefined" && Tender.widgetToggles){
    for(var i=0; i<Tender.widgetToggles.length; i++){
      var toggle = Tender.widgetToggles[i];
      if (toggle == null) continue;
      toggle.onclick = function(event){
        showWidget();
        return false;
      };
    }
  }

})();
