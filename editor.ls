var box

setup = ->
  css-input = box.find \.cweb-css-input
  css-style = box.find \.cweb-css-style
  js-input = box.find \.cweb-js-input

  new Behave textarea: css-input[0], tab-size: 2
  new Behave textarea: js-input[0], tab-size: 2

  put-css = ->
    css-style.text css-input.val!

  css-input.keydown -> set-timeout put-css

  chrome.storage.sync.get [\!default, location.host], (data) ->
    if data[\!default]
      box.find(\.cweb-def-style).text data[\!default].js || ''
      run-js data[\!default].js || ''
    if data[location.host]
      css-input.val data[location.host].css || ''
      put-css!
      js-input.val data[location.host].js || ''
      run-js js-input.val!

  box.find(\.cweb-save-btn).click ->
    chrome.storage.sync.set (location.host):
      css: css-input.val() or ''
      js: js-input.val() or ''

  box.find(\.cweb-move-btn).click ->
    box.stop!.animate do
      right: if box.css(\right) isnt \0px then 0
          else document.body.client-width - box.inner-width!
      200

  box.find(\.cweb-run-btn).click -> run-js js-input.val!
  box.find(\.cweb-close-btn).click toggle-box
  box.find(\.cweb-open-btn).attr \href, chrome.extension.getURL \options.html

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
