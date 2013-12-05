var box

anim =
  add-class: (el, cls) ->
    el.class-list.add "#{cls}-add"
    set-timeout ->
      el.class-list.add cls, "#{cls}-added"
      set-timeout ->
        el.class-list.remove "#{cls}-add", "#{cls}-added"
      , anim.transition-duration(el)
    , 10

  remove-class: (el, cls) ->
    el.class-list.add "#{cls}-rem"
    set-timeout ->
      el.class-list.remove cls
      el.class-list.add "#{cls}-remed"
      set-timeout ->
        el.class-list.remove "#{cls}-rem", "#{cls}-remed"
      , anim.transition-duration(el)
    , 10

  toggle-class: (el, cls) ->
    if el.classList.contains cls
      @removeClass el, cls
    else
      @addClass el, cls

  transition-duration: (el) ->
    window.get-computed-style(el).get-property-value(\transition-duration).slice(0, -1) * 1000

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

  box.find(\.cweb-move-btn).click -> box.toggle-class \left
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
    $.get chrome.extension.getURL(\editor.html), (data) ->
      box.html data
      setup!

toggle-box = ->
  box.toggle!

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
