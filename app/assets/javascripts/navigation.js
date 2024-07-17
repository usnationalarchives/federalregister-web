document.addEventListener('DOMContentLoaded', function() {

  function handleDesktopNavigationTabbing () {
    // NOTE: The intention is for this logic not to be executed in mobile viewports
    var dropdowns = document.querySelectorAll('#navigation li.dropdown');

    function showSubnav() {
      if (window.innerWidth > 501) {
        this.querySelector('.subnav').style.display = 'block';
      }
    }

    function hideSubnav() {
      if (window.innerWidth > 501) {
        var dropdown = this;
        // Set a timeout to delay the hiding to check if the new focused element is within the dropdown
        setTimeout(function() {
          if (!dropdown.contains(document.activeElement)) {
            dropdown.querySelector('.subnav').style.display = 'none';
          }
        }, 10);
      }
    }

    dropdowns.forEach(function(dropdown) {
      dropdown.addEventListener('focusin', showSubnav);
      dropdown.addEventListener('focusout', hideSubnav);
    });
  }
  handleDesktopNavigationTabbing()


  // New Mobile Navbar Handling:
  // ===========================================================================
  // Handle toggling of subnav
  var toggleableList = document.querySelectorAll('#non-essential-nav li.dropdown');
  toggleableList.forEach(function(item) {
    item.addEventListener('click', function(event) {
        var el = event.target.closest('li');
        if (el === item) { // ie make sure we're only handling clicks to the subnav item (eg 'Browse', 'Sections', etc)
          event.preventDefault();
          if (el.classList.contains('active')) {
            el.classList.remove('active');
            event.target.classList.remove('active');
          } else {
            // Close any open subnav item
            $('#navigation > ul').find('*').removeClass('active');
            // Open the selectived subnav item
            el.classList.add('active');
            event.target.classList.add('active');
          }
        }
      // }
    });
  });

  // Handle clicks on hamburger icon
  var hamburgerIcon = document.querySelector('#nav-hamburger');
  if (hamburgerIcon) {
    hamburgerIcon.addEventListener('click', function (e) {
      e.preventDefault();
      // Apply slide down animation
      var $slideDown = $('#non-essential-nav');
      if ($slideDown.hasClass('show')) {
        $slideDown.removeClass('show');
        document.getElementById('navigation').classList.toggle('hamburger-expanded');
      } else {
        $slideDown.removeClass('hide').addClass('show');
        document.getElementById('navigation').classList.toggle('hamburger-expanded');
      }
    });
  }
  // ===========================================================================

});
