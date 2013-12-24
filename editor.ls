var box

domain-style = $ '<style cweb-dom>'
default-style = $ '<style cweb-def>'

# Make sure the style elements are the last in the document, for precedence
# purposes, and that is always present on the page, somewhere.
_in = set-interval ->
  default-style.add domain-style .append-to document.document-element
  clear-interval _in if document.head and document.body
, 200

chrome.storage.sync.get [\!default, location.host], (data) ->
  if data[\!default]
    default-style.text data[\!default].css || ''
  if data[location.host]
    domain-style.text data[location.host].css || ''

setup = ->
  textareas = box.find \textarea
  css-input = box.find \.cweb-css-input
  js-input = box.find \.cweb-js-input

  new Behave textarea: css-input[0], tab-size: 2
  new Behave textarea: js-input[0], tab-size: 2

  css-input.keydown -> set-timeout ->
    domain-style.text css-input.val!

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
      Math.max 8 this.value.split('\n').length

  textareas.on \keydown, (e) -> set-timeout -> adjust-size $(e.target)
  textareas.on \change, -> adjust-size $(this)

  chrome.storage.sync.get [\!default, location.host], (data) ->
    if data[\!default]
      run-js data[\!default].js || ''
    if data[location.host]
      css-input.val data[location.host].css || ''
      adjust-size css-input
      js-input.val data[location.host].js || ''
      adjust-size js-input
      run-js js-input.val!

  css-input.focus!

init-ui = ->
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
  el = $ '<script>', text: code
  el.append-to document.body || document.document-element
  el.remove!

chrome.runtime.on-message.add-listener (action) ->
  toggle-box! if action is \toggle

$.get chrome.extension.getURL('vendor/jquery-2.0.3.min.js'), (data) ->
  run-js "#{data}; var __cweb_jQuery = jQuery.noConflict(true), __cweb_scope = {};", no
  $ init-ui
