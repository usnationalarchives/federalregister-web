class @FR2.NonPersistentStorage
  constructor: ->
    @_storage = {}

  set: (key, value)->
    @_storage[key] = value

  get: (key)->
    @_storage[key]
