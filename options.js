function loadDomains(callback) {
    chrome.storage.sync.get(null, function (data) {
        var ul = $('#domain-list').empty(), keys = Object.keys(data);
        for (var i = keys.length; i-- > 0;)
            ul.prepend('<li><a href="#' + keys[i] + '">' + keys[i] + '</a></li>');
        if (callback) callback();
    });
}

function applyHash() {
    currentHost = location.hash.substr(1);
    $('aside').find('.active').removeClass('active').end()
        .find('a[href="#' + currentHost + '"]').addClass('active');

    var boxName;
    if (currentHost[0] == '!' && currentHost != '!default') {
        boxName = currentHost.substr(1);
    } else {
        boxName = 'editor';
        chrome.storage.sync.get(currentHost, function (data) {
            if (data[currentHost]) {
                cssInput.setValue(data[currentHost].css || '');
                jsInput.setValue(data[currentHost].js || '');
                cssInput.focus();
            } else {
                alert('Unknown host/route. Calling for a trampoline!');
                location.hash = '#!default';
            }
        });
    }

    $('#' + boxName + '-box').show().siblings('.box').hide();

    if (currentHost == '!default')
        deleteBtn.attr({disabled: ''});
    else
        deleteBtn.removeAttr('disabled');
}

function save() {
    var data = {};
    data[currentHost] = {css: cssInput.getValue(), js: jsInput.getValue()};
    chrome.storage.sync.set(data);
}

function deleteCurrent() {
    var host = currentHost;
    chrome.storage.sync.get(host, function (backup) {
        chrome.storage.sync.remove(host, function () {
            loadDomains(function () {
                location.hash = '#!default';
            });
            showUndoOsd('deleting ' + host, function () {
                chrome.storage.sync.set(backup);
                loadDomains(function () {
                    location.hash = '#' + host;
                });
            });
        });
    });
}

function newDomain() {
    var host = prompt('Enter the host name. Eg., `google.com` or `finance.yahoo.com`.', 'finance.yahoo.com'),
        data = {};
    data[host] = {css: '', js: ''};
    chrome.storage.sync.set(data, function () {
        loadDomains(function () {
            location.hash = '#' + host;
        });
    });
}

function showUndoOsd(host, callback) {
    var duration = 4000;
    $('#undo-osd')
        .off('click.undo')
        .on('click.undo', function () {
            $(this).removeClass('active has-data');
            if (callback) callback();
        })
        .clearQueue()
        .addClass('active has-data')
        .delay(duration)
        .queue(function () {
            $(this).removeClass('active');
        })
        .find('.host')
        .text(host);
}

function copyExport() {
    chrome.storage.sync.get(null, function (data) {
        var el = $('<input>').val(JSON.stringify(data)).appendTo(document.body).select();
        document.execCommand('Copy', false, null);
        el.remove();
        alert('Your export data has been copied to your clipboard.');
    });
}

function downloadExport() {
    chrome.storage.sync.get(null, function (data) {
        // FIXME: Doesn't work, as this is executed out of the download button
        // event handler's line of execution.
        $('<a>', {
            href: URL.createObjectURL(new Blob([JSON.stringify(data)])),
            download: 'custom-web-export.json'
        }).appendTo(document.body).click();
    });
}

function importData() {
    var host = currentHost;
    chrome.storage.sync.get(null, function (backup) {
        var data = JSON.parse($('#import-data').val());
        if (Object.keys(data).length === 0) {
            alert('Nothing to import yo!');
            return;
        }
        chrome.storage.sync.set(data, function () {
            loadDomains(function () {
                location.hash = '#' + Object.keys(data)[0];
            });
            showUndoOsd('Import', function () {
                chrome.storage.sync.clear(function () {
                    chrome.storage.sync.set(backup);
                    loadDomains(function () {
                        location.hash = '#!ie';
                    });
                });
            });
        });
    });
}

$.fn.CodeMirror = function (mode) {
    return CodeMirror(this[0], {
        mode: mode,
        value: ' ', // Fix 0-height editor opening when no value is set initially
        lineNumbers: true,
        showCursorWhenSelecting: true,
        styleActiveLine: true,
        matchBrackets: true,
        autoCloseBrackets: '(){}[]\'\'""',
        theme: 'solarized'
    });
};

var currentHost,
    deleteBtn = $('#del-btn'),
    cssInput = $('#css-input').CodeMirror('css'),
    jsInput = $('#js-input').CodeMirror('javascript');

$('.version').text(chrome.app.getDetails().version);

$('[clicked]').click(function (e) {
    return window[this.getAttribute('clicked')].call(this, e);
});

$('button[href]').click(function (e) {
    window.location = e.target.getAttribute('href');
});

$(window).on('hashchange', applyHash);
cssInput.on('change', save);
jsInput.on('change', save);

loadDomains(function () {
    if (location.hash)
        applyHash();
    else
        location.hash = '#!settings';
});
