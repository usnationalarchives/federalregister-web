# encoding: utf-8

# cribbed from https://github.com/tenderlove/rails_autolink/blob/master/lib/rails_autolink/helpers.rb

module Hyperlinker::Email
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper

  AUTO_EMAIL_LOCAL_RE = /[\w.!#\$%&'*\/=?^`{|}~+-]/
  AUTO_EMAIL_RE = /[\w.!#\$%+-]\.?#{AUTO_EMAIL_LOCAL_RE}*@[\w-]+(?:\.[\w-]+)+/

  def self.perform(text, html_options)
    Hyperlinker.replace_text(text, AUTO_EMAIL_RE) do |match|
      text = match.to_s

      mail_to text, text, html_options
    end
  end
end
