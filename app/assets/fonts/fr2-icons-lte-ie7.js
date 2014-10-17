/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */
var fr_icons = {
  'icon-fr2-Directions': '&#xe630;',
  'icon-fr2-add': '&#xe62e;',
  'icon-fr2-movie': '&#xe62b;',
  'icon-fr2-Search': '&#xe625;',
  'icon-fr2-twitter': '&#xe60e;',
  'icon-fr2-Eye': '&#xe60d;',
  'icon-fr2-quotes': '&#xe60b;',
  'icon-fr2-Network-alt': '&#xe60a;',
  'icon-fr2-Chat': '&#xe609;',
  'icon-fr2-Refresh-7': '&#xe608;',
  'icon-fr2-Molecular': '&#xe607;',
  'icon-fr2-Temperature': '&#xe606;',
  'icon-fr2-Medicine': '&#xe605;',
  'icon-fr2-Lab': '&#xe604;',
  'icon-fr2-Factory': '&#xe603;',
  'icon-fr2-Globe': '&#xe602;',
  'icon-fr2-Eco': '&#xe601;',
  'icon-fr2-Coins-dollaralt': '&#xe600;',
  'icon-fr2-flag': '&#xe000;',
  'icon-fr2-folder': '&#xe001;',
  'icon-fr2-download': '&#xe002;',
  'icon-fr2-open_folder': '&#xe005;',
  'icon-fr2-correction': '&#xe007;',
  'icon-fr2-notice': '&#xe008;',
  'icon-fr2-presidential_document': '&#xe009;',
  'icon-fr2-proposed_rule': '&#xe00a;',
  'icon-fr2-rule': '&#xe00b;',
  'icon-fr2-uncategorized': '&#xe00c;',
  'icon-fr2-menu_arrow': '&#xe00d;',
  'icon-fr2-trash_can': '&#xe006;',
  'icon-fr2-badge_check_mark': '&#xe00f;',
  'icon-fr2-badge_forward_arrow': '&#xe010;',
  'icon-fr2-badge_plus': '&#xe011;',
  'icon-fr2-badge_x': '&#xe012;',
  'icon-fr2-alert': '&#xe013;',
  'icon-fr2-alert_alt': '&#xe014;',
  'icon-fr2-pi_subscription': '&#xe003;',
  'icon-fr2-message_open': '&#xe004;',
  'icon-fr2-message': '&#xe015;',
  'icon-fr2-rss': '&#xe017;',
  'icon-fr2-pc': '&#xe019;',
  'icon-fr2-document_open': '&#xe018;',
  'icon-fr2-globe': '&#xe62f;',
  'icon-fr2-delete': '&#xe62d;',
  'icon-fr2-tools': '&#xe62a;',
  'icon-fr2-lightbulb-active': '&#xe62c;',
  'icon-fr2-info_circle': '&#xe629;',
  'icon-fr2-help': '&#xe628;',
  'icon-fr2-quote': '&#xe627;',
  'icon-fr2-clipboard': '&#xe60c;',
  'icon-fr2-calendar-alt': '&#xe626;',
  'icon-fr2-stop-hand': '&#xe624;',
  'icon-fr2-facebook': '&#xe623;',
  'icon-fr2-link': '&#xe622;',
  'icon-fr2-NARA1985Seal': '&#xe613;',
  'icon-fr2-pen': '&#xe61a;',
  'icon-fr2-molecular': '&#xe61d;',
  'icon-fr2-megaphone': '&#xe61e;',
  'icon-fr2-legal': '&#xe61f;',
  'icon-fr2-books': '&#xe620;',
  'icon-fr2-map-alt': '&#xe621;',
  'icon-fr2-book': '&#xe61c;',
  'icon-fr2-book-alt-2': '&#xe61b;',
  'icon-fr2-stars': '&#xe619;',
  'icon-fr2-doc-xml': '&#xe618;',
  'icon-fr2-doc-pi-pdf': '&#xe617;',
  'icon-fr2-doc-pdf': '&#xe616;',
  'icon-fr2-sharing': '&#xe60f;',
  'icon-fr2-conversation-alt': '&#xe610;',
  'icon-fr2-print': '&#xe611;',
  'icon-fr2-map': '&#xe612;',
  'icon-fr2-bulleted-list': '&#xe614;',
  'icon-fr2-bookmark': '&#xe615;',
  'icon-fr2-nav_male_female_user': '&#xe00e;',
  'icon-fr2-document_subscription': '&#xe016;',
  '0': 0
}

function get_entity(class_name) {
  var c = class_name.match(/icon-fr2-[^\s'"]+/);
  return fr_icons[c[0]];
}

function addIconViaJS(el, class_name) {
  /* using add icon results in errors as the innerHTML is undefined */
  $(el).prepend('<span style="font-family: \'fr2_icons\'">' + get_entity(class_name) + '</span>');
}

function addIcon(el, entity) {
  var html = el.innerHTML;
  el.innerHTML = '<span style="font-family: \'fr2_icons\'">' + entity + '</span>' + html;
}

function scan_for_icons_and_add() {
  var els = document.getElementsByTagName('*'),
      i, attr, html, c, class_name, el;
  for (i = 0; ; i += 1) {
    el = els[i];
    if(!el) {
      break;
    }
    attr = el.getAttribute('data-icon');
    if (attr) {
      addIcon(el, attr);
    }
    class_name = el.className;
    c = class_name.match(/icon-fr2-[^\s'"]+/);
    if (c && fr_icons[c[0]]) {
      var entity = get_entity(class_name);
      addIcon(el, entity);
    }
  }
}

window.onload = function() {
  $('body').addClass('fonts_ie7_lte');
  scan_for_icons_and_add();
};

