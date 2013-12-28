chrome.browserAction.onClicked.addListener(function (tab) {
    chrome.tabs.sendMessage(tab.id, 'toggle');
});

chrome.runtime.onMessage.addListener(function (message, sender) {
    if (message.open)
        chrome.tabs.create({url: message.open, index: sender.tab.index + 1});
});
