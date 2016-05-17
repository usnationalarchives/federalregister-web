# encoding: utf-8

# cribbed from https://github.com/tenderlove/rails_autolink/blob/master/lib/rails_autolink/helpers.rb

module Hyperlinker::Url
  extend ActionView::Helpers::TagHelper

  AUTO_LINK_RE = %r{
              ((?: ((?:http|https):)// | www\d?\. )
              [^\s<\u00A0"]*)
              (?:
                (\s*<PRTPAGE\s+P="\d+"/>\s*)
                ([^\s<\u00A0"]+)
              )?
            }ix
  AUTO_LINK_CRE = [/<[^>]+$/, /^[^>]*>/, /<a\b.*?>/i, /<\/a>/i]
  WORD_PATTERN = '\p{Word}'
  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }

  # Turns all urls into clickable links.  If a block is given, each url
  # is yielded and the result is used as the link text.
  def self.perform(text, html_options = {})
    return "" unless text.present?
    link_attributes = html_options.stringify_keys
    coder = HTMLEntities.new(:expanded)

    Hyperlinker.replace_text(text, AUTO_LINK_RE) do |match|
      initial_href, scheme, page_break, final_fragment = match.captures
      punctuation = []

      initial_href = coder.decode(initial_href)
      final_fragment = coder.decode(final_fragment)

      if final_fragment.present?
        href = initial_href + final_fragment
      else
        href = initial_href
      end

      if %w(http:// https://).include?(initial_href) && final_fragment.blank?
        match.to_s
      else
        # don't include trailing punctuation character as part of the URL
        while href.sub!(/[^#{WORD_PATTERN}\/-=&]$/, '')
          punctuation.push $&
          if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
            href << punctuation.pop
            break
          end
        end

        href = 'http://' + href unless scheme
        trailing_punctuation = punctuation.reverse.join

        if final_fragment.present?
          final_fragment.sub!(/#{Regexp.escape(trailing_punctuation)}\z/, '')

          content_tag(:a, add_line_break_indicators(initial_href), link_attributes.merge('href' => href)) +
            page_break.html_safe +
            content_tag(:a,
              add_line_break_indicators(final_fragment),
              link_attributes.merge('href' => href)
            ) +
            add_line_break_indicators(trailing_punctuation)
        else
          content_tag(:a, add_line_break_indicators(initial_href), link_attributes.merge('href' => href)) +
            add_line_break_indicators(trailing_punctuation)
        end
      end
    end
  end

  # Detects already linked context or position in the middle of a tag
  def self.auto_linked?(left, right)
    (left =~ AUTO_LINK_CRE[0] and right =~ AUTO_LINK_CRE[1]) or
      (left.rindex(AUTO_LINK_CRE[2]) and $' !~ AUTO_LINK_CRE[3])
  end

  def self.add_line_break_indicators(url_fragment)
    fragment = url_fragment.gsub(/(?<!:)(?<!\/)([_;&\/\?=\+])/,"\\1\u200B")

    HTMLEntities.new.encode(fragment, :named, :decimal).html_safe
  end
end
