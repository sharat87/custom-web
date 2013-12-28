function loadDomains(callback) {
    chrome.storage.sync.get(null, function (data) {
        $('#domain-list').html(Mustache.render($('#domain-list-tpl').text(), {
            domains: Object.keys(data)
        }));
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
        hashHandlers[boxName]();
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
    chrome.storage.sync.remove(currentHost, function () {
        loadDomains(function () {
            location.hash = '#!default';
        });
    });
}

var hashHandlers = {
    settings: function () { }
};

$.fn.CodeMirror = function (mode) {
    return CodeMirror(this[0], {
        mode: mode,
        lineNumbers: true,
        showCursorWhenSelecting: true,
        styleActiveLine: true,
        matchBrackets: true,
        autoCloseBrackets: '(){}[]\'\'""'
    });
};

var currentHost,
    deleteBtn = $('#del-btn'),
    cssInput = $('#css-input').CodeMirror('css'),
    jsInput = $('#js-input').CodeMirror('javascript');

deleteBtn.on('click', deleteCurrent);
$(window).on('hashchange', applyHash);
cssInput.on('change', save);
jsInput.on('change', save);

loadDomains(function () {
    if (location.hash)
        applyHash();
    else
        location.hash = '#!settings';
});
