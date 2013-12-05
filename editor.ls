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

setup = (box) ->
  css-input = box.query-selector \.cweb-css-input
  css-style = box.query-selector \.cweb-css-style
  js-input = box.query-selector \.cweb-js-input

  new Behave textarea: css-input, tab-size: 2
  new Behave textarea: js-input, tab-size: 2

  put-css = ->
    css-style.text-content = css-input.value

  css-input.add-event-listener \keydown, -> set-timeout put-css

  chrome.storage.sync.get [\!default, location.host], (data) ->
    console.info data
    if data[\!default]
      box.query-selector(\.cweb-css-style).text-content = data[\!default].js or ''
      run-js data[\!default].js or ''
    if data[location.host]
      css-input.value = data[location.host].css or ''
      put-css!
      js-input.value = data[location.host].js or ''
      run-js js-input.value

  box.query-selector(\.cweb-save-btn).add-event-listener \click, ->
    chrome.storage.sync.set (location.host):
      css: css-input.value or ''
      js: js-input.value or ''

  box.query-selector(\.cweb-move-btn).add-event-listener \click, ->
    box.class-list.toggle \left

  box.query-selector(\.cweb-run-btn).add-event-listener \click, -> run-js js-input.value
  box.query-selector(\.cweb-close-btn).add-event-listener \click, toggle-box

  box.query-selector(\.cweb-open-btn).set-attribute \href,
    chrome.extension.getURL \options.html

  css-input.focus!

init-ui = ->
  box := document.get-element-by-id \custom-web-box

  if box
    setup box
  else
    box := document.create-element \div
    box.set-attribute \id, \custom-web-box
    document.body.append-child box

    xhr = new XMLHttpRequest!
    xhr.open \GET, chrome.extension.getURL(\editor.html), yes
    xhr.add-event-listener \load, ->
      box.innerHTML = xhr.response-text
      setup box
    xhr.send!

toggle-box = ->
  anim.toggleClass box, \active

run-js = (code, wrap=yes) ->
  if wrap
    code = "(function ($) { var jQuery = $; #{code} }.call(__cweb_scope, __cweb_jQuery));"
  el = document.create-element \script
  el.text-content = code
  document.body.append-child el
  document.body.remove-child el

do ->
  chrome.runtime.on-message.add-listener (action) ->
    toggle-box! if action is \toggle

  $.ajax chrome.extension.getURL('vendor/jquery-2.0.3.min.js'),
    success: (data, status, xhr) ->
      run-js "#{data}; var __cweb_jQuery = jQuery.noConflict(true), __cweb_scope = {};", no
      init-ui!
