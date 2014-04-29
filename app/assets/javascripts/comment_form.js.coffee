#=require app
class @FR2.CommentForm
  constructor: ()->
    @comment_form = $('#new_comment')
    @not_sent_field_ids = [
      '#comment_confirmation_text',
      '#comment_confirm_submission_input'
    ]


  parse_fields: ->
    fields = []
    $els = @comment_form.find('.inputs > ol > li')

    $els = @remove_not_sent_fields($els)

    _.each $els, (el)=>
      $list_item = $(el)
      key = $list_item.find('label').text().replace('*','')
      field = {'label': key}

      if $list_item.hasClass('combo')
        $input = $list_item.find('select').first()
        if $input.length > 0
          field.values = Array @get_option_value($input)
        else
          field.values = Array @get_item_value($list_item, 'input')

      else if $list_item.hasClass('stringish')
        field.values = Array @get_item_value($list_item, 'input')
      else if $list_item.hasClass('text')
        field.values = Array @get_item_value($list_item, 'textarea')
      else if $list_item.hasClass('select')
        $input = $list_item.find('select').first()
        field.values = Array @get_option_value($input)
      else if $list_item.hasClass('file')
        $attachments = $list_item.find('.attachments tr')

        attachment_names = _.map $attachments, (el)->
          $(el).data('name')

        if attachment_names.length
          field.values =  attachment_names
        else
          Array 'None attached'

      fields.push field

    fields

  remove_not_sent_fields: ($els)->
    _.each @not_sent_field_ids, (id)->
      $els = $els.filter("li:not(#{id})")

    $els

  get_option_value: ($input)->
    $input.find('option[value="' + $input.val() + '"]').first().text()

  get_item_value: ($item, type)->
    $item.find(type).val()
