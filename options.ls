css-input = document.get-element-by-id \css
js-input = document.get-element-by-id \js

new Behave textarea: css-input, tab-size: 2
new Behave textarea: js-input, tab-size: 2

chrome.storage.sync.get \!default, (data) ->
  if data[\!default]
    css-input.value = data[\!default].css or ''
    js-input.value = data[\!default].js or ''

document.get-element-by-id(\save-btn).add-event-listener \click, ->
  chrome.storage.sync.set '!default':
    css: css-input.value
    js: js-input.value
