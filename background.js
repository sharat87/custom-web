chrome.browserAction.onClicked.addListener(function (tab) {
    chrome.tabs.sendMessage(tab.id, 'toggle', function () {
        if (chrome.runtime.lastError)
            alert('This tab has been loaded before Custom Web was installed/updated.' +
                  ' Please refresh to run Custom Web in this tab.');
    });
});

chrome.runtime.onMessage.addListener(function (message, sender) {
    if (message.open)
        chrome.tabs.create({url: message.open, index: sender.tab.index + 1});
});
