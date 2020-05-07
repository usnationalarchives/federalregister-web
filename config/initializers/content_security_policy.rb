# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy_report_only = Settings.csp.report_only

Rails.application.config.content_security_policy_nonce_generator = -> request { Settings.csp.esi_unifying_nonce }
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

Rails.application.config.content_security_policy do |policy|
  policy.default_src :none

  script_srcs = [
    :self,
    :unsafe_inline,
    :unsafe_eval,
    :https,
    :report_sample,
    :strict_dynamic,
    'https://use.typekit.net',
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
    'https://www.google-analytics.com',

    'https://eps.images.fr2.criticaljuncture.org',
    'https://private.images.fr2.criticaljuncture.org',
    'https://images.fr2.criticaljuncture.org',
    'https://lede-photos.fr2.criticaljuncture.org',
    'https://agency-logos.fr2.criticaljuncture.org',
    'https://public-inspection.fr2.criticaljuncture.org',

    'https://eps.images.federalregister.gov',
    'https://private.images.federalregister.gov',
    'https://images.federalregister.gov',
    'https://lede-photos.federalregister.gov',
    'https://agency-logos.federalregister.gov',
    'https://public-inspection.federalregister.gov',
  ]
  policy.img_src *img_srcs

  policy.form_action :self, :report_sample, "#{Settings.services.fr_profile_base_url}"

  policy.object_src :none

  connect_srcs = [
    :self,
    'https://api.honeybadger.io',

    # zendesk
    'https://ekr.zdassets.com',
    'https://ofr.zendesk.com',
  ]

  policy.connect_src *connect_srcs
  policy.frame_ancestors :none
  policy.base_uri :none

  if ['production', 'staging'].include?(Rails.env)
    policy.report_uri -> {
      "https://report-uri.honeybadger.io/v1/browser/csp?api_key=#{Rails.application.secrets.honeybadger_csp_api_key}&env=#{Rails.env}&#{{context: try(:honeybadger_context) || {} }.to_query}"
    }
  end
end



