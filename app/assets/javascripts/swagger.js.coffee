#= require swagger-ui/swagger-ui-bundle.js
#= require swagger-ui/swagger-ui-standalone-preset.js

$(document).ready ->

  window.ui = SwaggerUIBundle(
    url: "/developers/documentation.json",
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      # NOTE: The SwaggerUIStandalonePreset had to be commented out to work around encoding errors (ECFR includes this)
      # SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ]
  )
