# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy_report_only = Settings.app.csp.report_only

Rails.application.config.content_security_policy_nonce_generator = -> request {
  SecureRandom.base64(16)
}
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  internal_srcs = ["*.federalregister.gov", "*.ecfr.gov"]
  internal_srcs << "*.criticaljuncture.org" unless Rails.env.production?

  script_srcs = [
    # Explicit exemptions for older versions of Safari (eg 12.1.2, 15.1) since the 'strict_dynamic' directive may not be fully implemented in these browsers and granting permissions allowing for googletagmanager to be loaded dynamically from already explicitly-allowed scripts (eg those with a valid nonce).  Some other clients also seem to need an explicit allowance.
    "www.google-analytics.com",
    "www.googletagmanager.com",
    "dap.digitalgov.gov",
    "fonts.googleapis.com",
    # ==========================================================================
    :strict_dynamic, # For scripts that have a valid nonce, trust other scripts it loads
    :self, # Fallback to self for scripts without a valid nonce
    :report_sample, # Provide a snippet of violation to report URL
    :unsafe_eval, # Needed by rack-mini-profiler and possibly jQuery
  ]

  policy.script_src *script_srcs

  style_srcs = [
    :self,
    :unsafe_inline,
    :report_sample,
  ]
  policy.style_src *style_srcs

  img_srcs = [
    :self,
    :data,
    :report_sample,
    'https://s3.amazonaws.com', # FR stores images on s3 but not ideal to be open to all of s3
    "https://www.google-analytics.com",
    "https://region1.google-analytics.com",
    "https://www.googletagmanager.com/",
    "https://p.typekit.net",
    "https://translate.google.com/",
    *internal_srcs
  ]
  policy.img_src *img_srcs

  policy.form_action :self, :report_sample, "#{Settings.services.ofr.profile.base_url}"

  policy.object_src :none

  connect_srcs = [
    :self,
    'https://www.ecfr.gov',
    'https://api.honeybadger.io',
    "https://www.google-analytics.com",
    "https://region1.google-analytics.com",

    # zendesk
    'https://ekr.zdassets.com',
    'https://ofr.zendesk.com',

    # Regulations.gov
    'https://api.regulations.gov',
    'https://uploads-regulations-gov.s3.amazonaws.com',
    ((Rails.env.development? || Rails.env.staging?) ? 'https://api-staging.regulations.gov' : nil),
    ((Rails.env.development? || Rails.env.staging?) ? 'https://staging-uploads-regulations-gov.s3.amazonaws.com' : nil),
  ].compact

  policy.connect_src *connect_srcs
  policy.frame_src :self
  policy.frame_ancestors :none
  policy.base_uri :self

  if ['production', 'staging'].include?(Rails.env)
    # Increment version on each change to this file
    csp_version = 7

    policy.report_uri -> {
      if defined?(request)
        user_agent = request.env['HTTP_USER_AGENT']
        if /(PhantomJS|bot)/i.match?(user_agent)
          return
        end
      end

      api_key = Rails.application.credentials.dig(:honeybadger, :csp_api_key)
      context = {context: try(:honeybadger_context) || {}}
      context[:context][:csp_version] = csp_version
      context_args = context.to_query
      "https://api.honeybadger.io/v1/browser/csp?api_key=#{api_key}&env=#{Rails.env}&report_only=#{Settings.app.csp.report_only}&#{context_args}"
    }
  end
end
