function loadDomains(callback) {
    chrome.storage.sync.get(null, function (data) {
        var domains = [];
        for (var key in data)
            domains.push(key);
        $('#domain-list').html(Mustache.render($('#domain-list-tpl').text(), {
            domains: domains
        }));
        if (callback) callback();
    });
}

function applyHash() {
    currentHost = location.hash.substr(1);
    $('#domain-list').find('.active').removeClass('active').end()
        .find('a[href="#' + currentHost + '"]').addClass('active');
    chrome.storage.sync.get(currentHost, function (data) {
        if (!data[currentHost]) return;
        cssInput.val(data[currentHost].css || '');
        jsInput.val(data[currentHost].js || '');
    });
    if (currentHost == '!default')
        deleteBtn.attr({disabled: ''});
    else
        deleteBtn.removeAttr('disabled');
}

function save() {
    var data = {};
    data[currentHost] = {
        css: cssInput.val(),
        js: jsInput.val()
    };
    chrome.storage.sync.set(data);
}

function deleteCurrent() {
    chrome.storage.sync.remove(currentHost, function () {
        loadDomains(function () {
            // $('#domain-list a[href="#' + currentHost + '"]').remove();
            location.hash = '#!default';
        });
    });
}

var currentHost,
    cssInput = $('#css'),
    jsInput = $('#js'),
    deleteBtn = $('#del-btn');

deleteBtn.on('click', deleteCurrent);
$(window).on('hashchange', applyHash);
$('textarea').on({keyup: save, change: save});

loadDomains(function () {
    if (location.hash)
        applyHash();
    else
        location.hash = '!default';
});
