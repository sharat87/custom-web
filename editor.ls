var box

domain-style = $ '<style>' .append-to document.body
default-style = $ '<style>' .append-to document.body

setup = ->
  textareas = box.find \textarea
  css-input = box.find \.cweb-css-input
  js-input = box.find \.cweb-js-input

  new Behave textarea: css-input[0], tab-size: 2
  new Behave textarea: js-input[0], tab-size: 2

  put-css = ->
    domain-style.text css-input.val!

  css-input.keydown -> set-timeout put-css

  chrome.storage.sync.get [\!default, location.host], (data) ->
    if data[\!default]
      default-style.text data[\!default].js || ''
      run-js data[\!default].js || ''
    if data[location.host]
      css-input.val data[location.host].css || ''
      adjust-size css-input
      put-css!
      js-input.val data[location.host].js || ''
      adjust-size js-input
      run-js js-input.val!

  textareas.on 'keyup change', ->
    chrome.storage.sync.set (location.host):
      css: css-input.val() or ''
      js: js-input.val() or ''

  box.find(\.cweb-move-btn).click ->
    box.stop!.animate do
      right: if box.css(\right) isnt \0px then 0
          else document.body.client-width - box.inner-width!
      200

  box.find(\.cweb-run-btn).click -> run-js js-input.val!

  adjust-size = (textareas) ->
    textareas.attr \rows, ->
      Math.max 1 this.value.split('\n').length

  textareas.on \keydown, (e) -> set-timeout -> adjust-size $(e.target)
  textareas.on \change, -> adjust-size $(this)

  css-input.focus!

init-ui = ->
  box := $ \#custom-web-box
  if box.length
    setup!
  else
    box := $ '<div id=custom-web-box>' .append-to document.body
    box.css right: 0
    $.get chrome.extension.getURL(\editor.html), (data) ->
      box.html data
      setup!

toggle-box = ->
  hide-style = right: -box.inner-width!/2 opacity: 0
  show-style = right: 0 opacity: 1
  if box.is \:visible
    box.animate hide-style, 200, -> box.hide!
  else
    box.show!.css hide-style .animate show-style, 200

run-js = (code, wrap=yes) ->
  if wrap
    code = "(function ($) { var jQuery = $; #{code} }.call(__cweb_scope, __cweb_jQuery));"
  el = $ '<script>'
  el.text code
  el.append-to document.body
  el.remove!

do ->
  chrome.runtime.on-message.add-listener (action) ->
    toggle-box! if action is \toggle

  $.ajax chrome.extension.getURL('vendor/jquery-2.0.3.min.js'),
    success: (data) ->
      run-js "#{data}; var __cweb_jQuery = jQuery.noConflict(true), __cweb_scope = {};", no
      init-ui!
