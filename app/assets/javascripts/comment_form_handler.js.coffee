#=require app

class @FR2.CommentFormHandler
  constructor: ($form_wrapper, comment_form)->
    @form_wrapper = $form_wrapper
    @comment_form = comment_form

    @remove_events_from_form_wrapper()
    @add_events()

  remove_events_from_form_wrapper: ->
    @form_wrapper.unbind()

  add_events: ->
    @add_comment_preview()

  add_comment_preview: ->
    @form_wrapper.on 'click', '.comment_preview', (e)=>
      e.preventDefault()

      fields = @comment_form.parse_fields
      html = @render_comment_summary fields

      Handlebars.registerPartial 'comment_summary', $('#comment-summary-template').html()
      source = $('#comment-summary-template').html()
      template = Handlebars.compile source

      modal = $( template({"fields": fields}) )
      $('body').append modal
      modal.find(".jqmClose").on 'click', (e)->
        modal.remove()

      modal.addClass('jqmWindow alternative-comment-modal')
      modal.jqm({
        modal: true,
        toTop: true
      })
      modal.jqmShow().centerScreen()


  render_comment_summary: (fields)->
    source = $('#comment-summary-template').html()
    template = Handlebars.compile source
    template fields

