chrome.browser-action.on-clicked.add-listener (tab) ->
  chrome.tabs.send-message tab.id, \open
