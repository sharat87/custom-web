var container = null,
    box = null,
    domainStyle = $('<style cweb-dom>'),
    defaultStyle = $('<style cweb-def>');

var _in = setInterval(function () {
    defaultStyle.add(domainStyle).appendTo(document.documentElement);
    if (document.head && document.body)
        clearInterval(_in);
}, 200);

chrome.storage.local.get(['!default', location.host], function (data) {
    if (data['!default'])
        defaultStyle.text(data['!default'].css || '');
    if (data[location.host])
        domainStyle.text(data[location.host].css || '');
});

function setup() {
    var textareas = box.find('textarea'),
        cssInput = box.find('.cweb-css-input'),
        jsInput = box.find('.cweb-js-input');

    textareas.on('keydown change', function () {
        setTimeout(function () {
            domainStyle.text(cssInput.val());
            var data = {};
            data[location.host] = {
                css: cssInput.val() || '',
                js: jsInput.val() || ''
            };
            chrome.storage.local.set(data);
        });
    });

    chrome.storage.onChanged.addListener(function (changes) {
        if (location.host in changes) {
            jsInput.val(changes[location.host].newValue.js);
            cssInput.val(changes[location.host].newValue.css);
            domainStyle.text(cssInput.val());
        }
        if ('!default' in changes)
            defaultStyle.text(changes['!default'].newValue.css);
    });

    box.find('.cweb-move-btn').click(function () {
        box.stop().animate({
            right: box.css('right') !== '0px' ? 0 :
                document.body.clientWidth - box.innerWidth()
        }, 200);
    });

    box.find('.cweb-run-btn').click(function () {
        runJs(jsInput.val());
    });

    chrome.storage.local.get(['!default', location.host], function (data) {
        if (data['!default'])
            runJs(data['!default'].js || '');
        if (data[location.host]) {
            cssInput.val(data[location.host].css || '');
            jsInput.val(data[location.host].js || '');
            runJs(jsInput.val());
        }
    });

    box.find('.cweb-open-btn').click(function (e) {
        chrome.runtime.sendMessage({
            open: chrome.extension.getURL('options.html#' + location.host)
        });
        toggleBox();
        e.preventDefault();
    });

    textareas.on('keydown keypress keyup', function (e) {
        e.stopPropagation();
    });
}

function initUi () {
    container = $('<div custom-web>');
    var shadow = container[0].webkitCreateShadowRoot();
    $.get(chrome.extension.getURL('editor.html'), function (data) {
        shadow.innerHTML = data;
        box = $(shadow.querySelector('#custom-web-box'));
        setup();
    });
}

function toggleBox() {
    var hideStyle = {
            right: -box.innerWidth() / 2,
            opacity: 0
        },
        showStyle = {
            right: 0,
            opacity: 1
        };
    if (box.is(':visible')) {
        box.animate(hideStyle, 200, function () {
            container.detach();
        });
    } else {
        container.appendTo(document.body);
        box.css(hideStyle).animate(showStyle, 200, function () {
            box.find('textarea:first').focus();
        });
    }
}

function runJs(code, wrap) {
    if (wrap !== false)
        code = "(function ($) { var jQuery = $; " + code + " }.call(__cweb_scope, __cweb_jQuery));";
    var el = $('<script>', {text: code});
    el.appendTo(document.body || document.documentElement);
    el.remove();
}

chrome.runtime.onMessage.addListener(function (action) {
    if (action === 'toggle')
        toggleBox();
});

$.get(chrome.extension.getURL('vendor/jquery-2.0.3.min.js'), function (data) {
    runJs(data + "; var __cweb_jQuery = jQuery.noConflict(true), __cweb_scope = {};", false);
    $(initUi);
});
