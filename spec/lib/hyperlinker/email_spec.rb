# encoding: UTF-8
require File.dirname(__FILE__) + '/../../spec_helper'
 
# cribbed from https://github.com/tenderlove/rails_autolink/blob/master/test/test_rails_autolink.rb

describe "Hyperlinker::Email" do
  def hyperlink(text, options={})
    FederalRegisterReferenceParser.hyperlink_with_fr_defaults(text, options: options)
  end

  def h(str)
    ERB::Util.html_escape(str)
  end

  def generate_result(link_text, href = nil)
    href ||= link_text
    %{<a href="#{CGI::escapeHTML href}">#{CGI::escapeHTML link_text}</a>}.gsub(/'/, '&#x27;')
  end

  it "hyperlinks emails" do
    email_raw    = 'david@loudthinking.com'
    email_result = %{<a href="mailto:#{email_raw}" class="email">#{email_raw}</a>}
    expect(hyperlink("hello #{email_raw}")).to eql %(hello #{email_result})

    email2_raw    = '+david@loudthinking.com'
    encoded_email2 = "#{CGI.escape('+')}david@loudthinking.com"
    email2_result = %{<a href="mailto:#{encoded_email2}" class="email">#{email2_raw}</a>}
    expect(hyperlink(email2_raw)).to eql email2_result
  end

  it "hyperlinks emails with special characters" do
    email_raw    = "and/&re$la*+r-a.o'rea=l~ly@tenderlovemaking.com"
    email_sanitized = "and/&amp;re$la*+r-a.o&#39;rea=l~ly@tenderlovemaking.com"
    email_sanitized_and_escaped = "and%2F%26re%24la%2A%2Br-a.o%27rea%3Dl~ly@tenderlovemaking.com"

    expect(hyperlink(email_raw)).to eql %{<a href="mailto:#{email_sanitized_and_escaped}" class="email">#{email_sanitized}</a>}
  end
end
