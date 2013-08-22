/* Load this script using conditional IE comments if you need to support IE 7 and IE 6. */
var fr_icons = {
			'icon-fr2-flag' : '&#xe000;',
			'icon-fr2-folder' : '&#xe001;',
			'icon-fr2-download' : '&#xe002;',
			'icon-fr2-open_folder' : '&#xe005;',
			'icon-fr2-correction' : '&#xe007;',
			'icon-fr2-notice' : '&#xe008;',
			'icon-fr2-presidential_document' : '&#xe009;',
			'icon-fr2-proposed_rule' : '&#xe00a;',
			'icon-fr2-rule' : '&#xe00b;',
			'icon-fr2-uncategorized' : '&#xe00c;',
			'icon-fr2-menu_arrow' : '&#xe00d;',
			'icon-fr2-trash_can' : '&#xe006;',
			'icon-fr2-nav_male_female_user' : '&#xe00e;',
			'icon-fr2-badge_check_mark' : '&#xe00f;',
			'icon-fr2-badge_forward_arrow' : '&#xe010;',
			'icon-fr2-badge_plus' : '&#xe011;',
			'icon-fr2-badge_x' : '&#xe012;',
			'icon-fr2-alert' : '&#xe013;',
			'icon-fr2-alert_alt' : '&#xe014;',
			'icon-fr2-document_subscription' : '&#xe016;',
			'icon-fr2-pi_subscription' : '&#xe003;',
			'icon-fr2-message_open' : '&#xe004;',
			'icon-fr2-message' : '&#xe015;',
			'icon-fr2-rss' : '&#xe017;',
			'icon-fr2-pc' : '&#xe019;',
			'icon-fr2-document_open' : '&#xe018;'
		};

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

