/* Use this script if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'fr2_document_type_icons\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-fr2-presidential_document' : '&#xe000;',
			'icon-fr2-uncategorized' : '&#xe001;',
			'icon-fr2-rule' : '&#xe002;',
			'icon-fr2-proposed_rule' : '&#xe003;',
			'icon-fr2-notice' : '&#xe004;',
			'icon-fr2-correction' : '&#xe005;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-fr2-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};