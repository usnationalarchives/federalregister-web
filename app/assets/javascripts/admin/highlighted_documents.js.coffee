@FR2 or= {}
class @FR2.HighlightedDocuments
  constructor: (photoContent, documentContent)->
    @photoContent = photoContent
    @documentContent = documentContent

    @minimumWidth = 800
    @minimumHeight = 452

    @page = 0

    @addPhotoSearch()
    @addCharacterCounts()
    @updateSubmitButton()

  addCharacterCounts: ->
    @addTitleCount()
    @addAbstractCount()

  addTitleCount: ->
    titleField = @documentContent.find('#entry_curated_title')
    formHandler = this

    titleField.on 'keyup', (e)->
      currentCount = titleField.val().length

      titleField
        .siblings 'p.inline-hints'
        .find '.current-count'
        .html "Current count: #{currentCount}"

      if currentCount >= 110
        titleField.closest('li').addClass('error')
        formHandler.updateSubmitButton()
      else
        titleField.closest('li').removeClass('error')
        formHandler.updateSubmitButton()

    titleField.trigger('keyup')

  addAbstractCount: ->
    abstractField = @documentContent.find('#entry_curated_abstract')
    formHandler = this

    abstractField.on 'keyup', (e)->
      currentCount = abstractField.val().length

      abstractField
        .siblings 'p.inline-hints'
        .find '.current-count'
        .html "Current count: #{currentCount}"

      if currentCount >= 215
        abstractField.closest('li').addClass('error')
        formHandler.updateSubmitButton()
      else
        abstractField.closest('li').removeClass('error')
        formHandler.updateSubmitButton()

    abstractField.trigger('keyup')

  updateSubmitButton: ->
    submitButton = $('#entry_submit')

    abstractWrapper = @documentContent.find('#entry_curated_abstract').closest('li')
    titleWrapper = @documentContent.find('#entry_curated_title').closest('li')

    if abstractWrapper.hasClass('error') || titleWrapper.hasClass('error')
      submitButton.prop('disabled', true)
    else
      submitButton.prop('disabled', false)

  addPhotoSearch: ->
    @photoForm = @photoContent.find('form.photo-search')

    @watchSearchButton()

    @photoForm.on 'submit', (event)=>
      event.preventDefault()
      event.stopPropagation()

      @page = 0

      @displayPhotosLoading()
      @removePhotoGrid()

      $.ajax({
        url: "/admin/photo_candidates/#{@photoForm.find('input[type=text]').val()}",
        data: {
          search_scope: @photoForm.find('input[name=search_scope]:checked').val() || true
        }
      }).done (photos)=>
        @photos = photos
        @removePhotosLoading()
        @displayPhotoGrid()

  watchSearchButton: ->
    submitButton = @photoForm.find('input[type=submit]')
    searchInput = @photoForm.find('#custom_tag')

    searchInput.on 'input keyup', (e)->
      if searchInput.val() == ""
        submitButton.prop('disabled', true)
      else
        submitButton.prop('disabled', false)

    searchInput.trigger('keyup')

  displayPhotosLoading: ->
    submitButton = @photoForm.find('input[type=submit]')
    searchInput = @photoForm.find('#custom_tag')

    searchInput.after $('<span>').addClass('loading')

    submitButton
      .prop('disabled', true)

  removePhotosLoading: ->
    submitButton = @photoForm.find('input[type=submit]')
    searchInput = @photoForm.find('#custom_tag')

    searchInput.siblings $('span.loading').remove()

    submitButton
      .prop('disabled', false)

  removePhotoGrid: ->
    @photoContent.find('.photo-grid-wrapper').remove()

  displayPhotoGrid: ->
    @removePhotoGrid()

    if @photos.length > 0
      @photoContent.prepend(
        Handlebars.compile(
          $('#admin-photo-grid-template').html()
        )({
          currentPage: @page + 1
          pages: Math.ceil(@photos.length / 24)
          photos: @paginatePhotos()
        })
      )
    else
      @photoContent.prepend(
        $('<div>').addClass('photo-grid-wrapper').html(
          $('<p>').addClass('error').html('No photos found.')
        )
      )

    @addPhotoPageChangeHandler()
    @addPhotoClickHandler()

  paginatePhotos: ->
    start = @page * 24
    end = (@page + 1) * 24

    @page = @page + 1

    @photos.slice(start, end)

  addPhotoPageChangeHandler: ->
    @photoContent.find('.photo-grid-pagination').on 'click', (e)=>
      e.preventDefault()

      @page = $(e.target).data('page') - 1 #zero based
      @displayPhotoGrid()

  addPhotoClickHandler: ->
    cropHandler = this

    _.each @photoContent.find('.photo-grid img'), (img)->
      $(img).on 'click', (e)->
        FR2.Modal.displayModal(
          'Crop Image for Display',
          Handlebars.compile($('#admin-image-cropper-template').html())(
            {
              imageUrl: $(this).data('url-lg'),
              imageId: $(this).data('photo-id')
            }
          ),
          {modalClass: 'fr-modal admin-crop-modal'}
        )

        cropHandler.disablePhotoCropButton()
        cropHandler.lookupPhotoInfo $(img).data('photo-id')

        cropHandler.croppedImage = $('.fr-modal.admin-crop-modal img').cropper({
          aspectRatio: 1.77
          preview: '.img-preview'
          crop: (e)->
            cropHandler.handleCrop(e)
          built: (e)->
            $('.fr-modal.admin-crop-modal .image-wrapper .loader').hide()
        })

        $('.fr-modal.admin-crop-modal #crop-button').on 'click', (e)->
          cropHandler.saveCrop()

        $('.fr-modal.admin-crop-modal #cancel-button').on 'click', (e)->
          $('#fr_modal').jqmHide()

  lookupPhotoInfo: (photoId) ->
    $.ajax({
      url: "/admin/photo_candidates/#{photoId}/info"
    }).done (info)=>
      @addPhotoInfo(info)

  addPhotoInfo: (info)->
    infoContent = $('.fr-modal.admin-crop-modal .photo-info')
    infoContent.removeClass('loading-data')

    html = Handlebars.compile($('#admin-image-cropper-photo-info-template').html())(
      {person: info}
    )

    infoContent.html(html)
    @enablePhotoCropButton()

  handleCrop: (e)->
    cropDetails = $('.admin-crop-modal .crop-details')

    widthDisplay = cropDetails.find('#width')
    @setDisplayValue widthDisplay, e.width

    if e.width < @minimumWidth
      @addCropError widthDisplay
    else
      @removeCropError widthDisplay

    heightDisplay = cropDetails.find('#height')
    @setDisplayValue heightDisplay, e.height

    if e.height < @minimumHeight
      @addCropError heightDisplay
    else
      @removeCropError heightDisplay

    @ensureMinimumRequirementsMet(e)

  setDisplayValue: (el, value)->
    el.find('.value').text "#{Math.round(value)}px"

  addCropError: (el)->
    el.addClass('error')
    el.find('.warning').show()

  removeCropError: (el)->
    el.removeClass('error')
    el.find('.warning').hide()

  enablePhotoCropButton: ->
    unless $('.fr-modal.admin-crop-modal .photo-info').hasClass('loading-data')
      $('#crop-button').removeClass('btn-disabled')

  disablePhotoCropButton: ->
    $('#crop-button').addClass('btn-disabled')

  ensureMinimumRequirementsMet: (e)->
    sizeError = e.width < @minimumWidth || e.height < @minimumHeight
    boundingError = e.x < 0 || e.y < 0 ||
      (e.x + e.width > e.currentTarget.width) ||
      (e.y + e.height > e.currentTarget.height)

    if sizeError || boundingError
      @disablePhotoCropButton()
    else
      @enablePhotoCropButton()

    if boundingError
      $('.preview-wrapper').addClass('bounding-error')
    else
      $('.preview-wrapper').removeClass('bounding-error')

  imageLoadFallback: (el)->
    if $('img.image-original').attr('src').match('_o.jpg')
      @croppedImage.cropper(
        'replace',
        $(el).attr('src').replace('_o.jpg', '_b.jpg')
      )
    else
      @imageLoadError()

  imageLoadError: ->
    $('.image-wrapper').prepend(
      $('<div>')
        .addClass 'error'
        .html 'Image failed to load. A file large enough for cropping may not exist. Please choose another or try again.'
    )

  saveCrop: ->
    cropButton = $('.fr-modal.admin-crop-modal #crop-button')

    unless cropButton.hasClass('btn-disabled')
      data = @croppedImage.cropper('getData')
      image = $('.fr-modal.admin-crop-modal .image-original')
      personData = $('.fr-modal.admin-crop-modal .photo-info')

      ledePhotoForm = $('#document-content form')

      ledePhotoForm.find("#entry_lede_photo_attributes_crop_x").val(data.x)
      ledePhotoForm.find("#entry_lede_photo_attributes_crop_y").val(data.y)
      ledePhotoForm.find("#entry_lede_photo_attributes_crop_width").val(data.width)
      ledePhotoForm.find("#entry_lede_photo_attributes_crop_height").val(data.height)

      ledePhotoForm.find("#entry_lede_photo_attributes_url").val(
        image.attr('src')
      )

      ledePhotoForm.find("#entry_lede_photo_attributes_flickr_photo_id").val(
        cropButton.data('imageId')
      )

      ledePhotoForm.find("#entry_lede_photo_attributes_credit").val(
        if personData.find('.realname').data('value')
          personData.find('.realname').data('value')
        else
          personData.find('.username').data('value')
      )

      ledePhotoForm.find("#entry_lede_photo_attributes_credit_url").val(
        personData.find('.lightbox_url').data('value')
      )

      @removePhotoGrid()
      $('#fr_modal').jqmHide()
