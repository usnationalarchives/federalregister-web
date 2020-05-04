module JavascriptHelper
  # be sure to update the Varnish vcl_hash method to hash based on the presence
  # of this cookie for whatever pages you're adding this to
  def js_known_to_be_enabled?
    request.cookies["javascript_enabled"] == "1"
  end

  def add_javascript(options={})
    content_for :javascripts do
      if options[:src]
        javascript_include_tag(options.delete(:src), options.merge(nonce: content_security_policy_nonce))
      elsif options[:partial]
        render options.delete(:partial)
      else
        content = yield
        if content !~ /^\s*<script\b/
          javascript_tag(content, nonce: content_security_policy_nonce)
        else
          content
        end
      end
    end
  end
end

