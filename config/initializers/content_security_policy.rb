# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy_report_only = Settings.app.csp.report_only

Rails.application.config.content_security_policy_nonce_generator = -> request {
  Rails.application.credentials.dig(:app, :csp, :esi_unifying_nonce)
}
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  internal_srcs = ["*.federalregister.gov", "*.ecfr.gov"]
  internal_srcs << "*.criticaljuncture.org" unless Rails.env.production?

  script_srcs = [
    :self,
    :unsafe_inline,
    :unsafe_eval,
    :https,
    :report_sample,
    :strict_dynamic
  ]

  if Settings.rack_mini_profiler
    script_srcs << :unsafe_eval
  end

  # if Rails.env.test? # poltergeist seems to require this
  #   script_srcs << :unsafe_eval
  # end

  policy.script_src *script_srcs

  style_srcs = [
    :self,
    :unsafe_inline,
    :report_sample,
  ]
  policy.style_src *style_srcs

  policy.font_src :self

  img_srcs = [
    :self,
    :data,
    :report_sample,
    'https://s3.amazonaws.com', # FR stores images on s3 but not ideal to be open to all of s3
    "https://www.google-analytics.com",
    "https://region1.google-analytics.com",
    "https://www.googletagmanager.com/",
    *internal_srcs
  ]
  policy.img_src *img_srcs

  policy.form_action :self, :report_sample, "#{Settings.services.ofr.profile.base_url}"

  policy.object_src :none

  connect_srcs = [
    :self,
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
  policy.frame_ancestors :none
  policy.base_uri :none

  if ['production', 'staging'].include?(Rails.env)
    policy.report_uri -> {
      "https://api.honeybadger.io/v1/browser/csp?api_key=#{Rails.application.credentials.dig(:honeybadger, :csp_api_key)}&env=#{Rails.env}&#{{context: try(:honeybadger_context) || {} }.to_query}"
    }
  end
end
