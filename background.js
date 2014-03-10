chrome.browserAction.onClicked.addListener(openEditor);

chrome.runtime.onMessage.addListener(function (message, sender) {
    if (message.open)
        chrome.tabs.create({url: message.open, index: sender.tab.index + 1});
});

var menus = {
    ':menu-open-here': {
        title: 'Toggle Editor',
        onclick: function (info, tab) {
            openEditor(tab);
        }
    }
};

var menuKeys = Object.keys(menus);
chrome.storage.local.get(menuKeys, function (data) {
    for (var key in data)
        if (data[key])
            chrome.contextMenus.create({
                id: key,
                title: menu[key].title,
                onclick: menu[key].onclick
            });

    chrome.storage.onChanged.addListener(function (changes) {
        for (var key in menus)
            if (key in changes)
                if (changes[key].newValue)
                    chrome.contextMenus.create({
                        id: key,
                        title: menu[key].title,
                        onclick: menu[key].onclick
                    });
                else
                    chrome.contextMenus.remove(key);
    });
});

function openEditor(tab) {
    chrome.tabs.sendMessage(tab.id, 'toggle', function () {
        if (chrome.runtime.lastError)
            alert('This tab has been loaded before Custom Web was installed/updated.' +
                  ' Please refresh to run Custom Web in this tab.');
    });
}
