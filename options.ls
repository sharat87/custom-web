css-input = document.get-element-by-id \css
js-input = document.get-element-by-id \js

chrome.storage.sync.get location.host, (data) ->
  css-input.value = data[location.host].css or ''
  put-css!
  js-input.value = data[location.host].js or ''
  run-js!

document.get-element-by-id \save-btn, ->
  chrome.storage.sync.set '!default':
    css: css-input.value
    js: js-input.value
