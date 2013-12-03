setup = (box) ->
  css-input = box.query-selector \.cweb-css-input
  css-style = box.query-selector \.cweb-css-style
  js-input = box.query-selector \.cweb-js-input

  new Behave textarea: css-input, tab-size: 2
  new Behave textarea: js-input, tab-size: 2

  put-css = ->
    css-style.text-content = css-input.value

  run-js = (code=js-input.value) ->
    el = document.create-element \script
    el.text-content = code
    document.body.append-child el
    document.body.remove-child el

  css-input.add-event-listener \keydown, -> set-timeout put-css

  chrome.storage.sync.get [\!default, location.host], (data) ->
    if data[\!default]
      run-js data[\!default].css or ''
      box.query-selector(\.cweb-css-style).text-content = data[\!default].js or ''
    if data[location.host]
      css-input.value = data[location.host].css or ''
      put-css!
      js-input.value = data[location.host].js or ''
      run-js!

  box.query-selector(\.cweb-save-btn).add-event-listener \click, ->
    chrome.storage.sync.set (location.host):
      css: css-input.value or ''
      js: js-input.value or ''

  box.query-selector(\.cweb-move-btn).add-event-listener \click, ->
    box.class-list.toggle \left

  box.query-selector(\.cweb-run-btn).add-event-listener \click, run-js
  box.query-selector(\.cweb-close-btn).add-event-listener \click, toggle-box

toggle-box = ->
  box.classList.toggle \active

box = document.get-element-by-id \custom-web-box

if box
  setup box
else
  box = document.create-element \div
  box.set-attribute \id, \custom-web-box
  document.body.append-child box

  xhr = new XMLHttpRequest!
  xhr.open \GET, chrome.extension.getURL(\editor.html), yes
  xhr.add-event-listener \load, ->
    box.innerHTML = xhr.response-text
    setup box
  xhr.send!

chrome.runtime.on-message.add-listener (action) ->
  toggle-box! if action is \open
