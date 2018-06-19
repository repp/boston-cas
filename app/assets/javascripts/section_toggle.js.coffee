# Provides a means for showing and hiding sections based on a radio button
#= require namespace
class App.SectionToggle
  constructor: (@element) ->
    @trigger = $(@element).find('input')
    @target = $('.' + $(@element).data('target'))
    @_register_listener()
    $(@trigger).trigger 'change'
  
  _register_listener: ->
    $(@trigger).on 'change', (evt) =>
      visible = $('.' + $(@element).find('input:checked').val())
      $(@target).hide()
      visible.show()

$('.jSectionToggle').each (_i, element) ->
  new App.SectionToggle element


class App.CheckboxSectionToggle
  constructor: (@element) ->
    @trigger = $(@element).find('input')
    @target = $('.' + $(@element).data('target'))
    @_register_listener()

  _register_listener: ->
    $(@trigger).on 'change', (evt) =>
      show_section = $(@trigger).is(':checked')
      if show_section
        $(@target).show()
      else
        $(@target).hide()


$('.cSectionToggle').each (_i, element) ->
  new App.CheckboxSectionToggle element