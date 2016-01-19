$(document).ready(function() {

  $('#disclaimer a, a.disclaimer').not('.public-inspection').bind('click',
  function (event) {
      event.preventDefault();
      FR2.Modal.displayModal(
        'Legal Status Disclaimer',
        '<p>The content posted on this site, taken from the daily Federal Register (FR2), is not an official, legal edition of the FR2; it does not replace the official print or electronic versions of the FR2. Each document posted on the site includes a link to the corresponding official FR2 PDF file.  For more information, see our <a href="/policy/legal-status">Legal Status</a> page.</p>'
      );
  });

  var pi_legal_notice_template;
  if ( $("#pi-legal-notice-template").length > 0 ) {
    pi_legal_notice_template = Handlebars.compile($("#pi-legal-notice-template").html());
  }

  $('#disclaimer a.public-inspection').bind('click',
  function (event) {
      event.preventDefault();
      FR2.Modal.display_Modal(
        'Legal Notice',
        pi_legal_notice_template()
      );
  });

  $('#policy a').bind('click',
  function (event) {
      event.preventDefault();
      FR2.Modal.displayModal(
        'Blog Policy',
        '<div class="modal_content"><p>This blog and the FederalRegister.gov Feedback link cannot be used to submit comments about rulemaking actions or to petition agencies on public policy issues. We have no authority or ability to process comments on regulations and notices or answer questions on the substance of agency documents.</p><p>We strongly urge readers to submit comments to the agency dockets on Regulations.gov or other places indentified under the “Addresses” heading in Federal Register documents. Many of the documents have a “Submit a Formal Comment” button that takes you directly to the official comment pages on Regulations.gov. The “For Further Information Contact” headings in the Federal Register direct you to agency officials who can answer specific questions. For more general questions and comments, please consult <a href="http://www.usa.gov/Contact.shtml" target="_blank">USA.gov</a> for a directory of federal and state contacts and frequently asked questions.</p><p>You are encouraged to share your comments, ideas, and concerns with us and other FederalRegister.gov readers. Please be aware that contributions to the <em>FR2 Blog</em> are moderated, and that we adhere to the following policies:</p><ul><li>FederalRegister.gov will delete comments that contain abusive, vulgar, offensive, threatening or harassing language, personal attacks of any kind, or offensive terms that target specific individuals or groups.</li></ul><ul><li>We will delete comments that are clearly off-topic, that promote commercial services or products, or that promote or oppose any political party, person campaigning for elected office, or any ballot proposition. Links to unrelated sites may be viewed as spam resulting in the comment being removed.</li></ul><ul><li>Communications made to this blog page will in no way constitute a legal or official notice or comment to any official or employee of the Office of the Federal Register, the National Archives, the Government Printing Office, or other Federal agency.</li></ul><ul><li>The content of posted comments are in the public domain, so do not submit anything you do not wish to be broadcast to the general public. Never submit personally identifiable information such as social security numbers, addresses and telephone numbers.</li></ul><p>The Office of the Federal Register does not discriminate against any views, but reserves the right to reject comments that do not adhere to these standards.</p></div>'
      );
  });
});
