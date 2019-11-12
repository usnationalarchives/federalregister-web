#= require swagger-ui/swagger-ui-bundle.js
#= require swagger-ui/swagger-ui-standalone-preset.js


$(document).ready ->
  window.ui = SwaggerUIBundle(
    url: "/api/v1/documentation.json",
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ]
  )
