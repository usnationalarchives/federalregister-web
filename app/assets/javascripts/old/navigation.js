// New Mobile Navbar Handling
//=====================================================================
document.addEventListener('DOMContentLoaded', function() {

  // Handle toggling of subnav
  var toggleableList = document.querySelectorAll('#non-essential-nav > li.dropdown');
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

});
//=====================================================================
