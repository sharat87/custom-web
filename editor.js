var box = null,
    domainStyle = $('<style cweb-dom>'),
    defaultStyle = $('<style cweb-def>');

var _in = setInterval(function () {
    defaultStyle.add(domainStyle).appendTo(document.documentElement);
    if (document.head && document.body)
        clearInterval(_in);
}, 200);

chrome.storage.sync.get(['!default', location.host], function (data) {
    if (data['!default'])
        defaultStyle.text(data['!default'].css || '');
    if (data[location.host])
        domainStyle.text(data[location.host].css || '');
});

function setup() {
    var textareas = box.find('textarea'),
        cssInput = box.find('.cweb-css-input'),
        jsInput = box.find('.cweb-js-input');

    cssInput.keydown(function () {
        setTimeout(function () {
            domainStyle.text(cssInput.val());
        });
    });

    textareas.on('keyup change', function () {
        var data = {};
        data[location.host] = {
            css: cssInput.val() || '',
            js: jsInput.val() || ''
        };
        return chrome.storage.sync.set(data);
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

    function adjustSize(textareas) {
        textareas.attr('rows', function () {
            return Math.max(8, this.value.split('\n').length);
        });
    }

    textareas.on('keydown', function (e) {
        setTimeout(function () {
            adjustSize($(e.target));
        });
    });

    textareas.on('change', function () {
        adjustSize($(this));
    });

    chrome.storage.sync.get(['!default', location.host], function (data) {
        if (data['!default'])
            runJs(data['!default'].js || '');
        if (data[location.host]) {
            cssInput.val(data[location.host].css || '');
            adjustSize(cssInput);
            jsInput.val(data[location.host].js || '');
            adjustSize(jsInput);
            runJs(jsInput.val());
        }
    });

    box.find('.cweb-open-btn').click(function (e) {
        chrome.runtime.sendMessage({
            open: chrome.extension.getURL('options.html#' + location.host)
        });
        e.preventDefault();
    });

    cssInput.focus();
}

function initUi () {
    box = $('<div id=custom-web-box>').appendTo(document.body).css({right: 0});
    $.get(chrome.extension.getURL('editor.html'), function (data) {
        box.html(data);
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
        box.animate(hideStyle, 200, box.hide.bind(box));
    } else {
        box.show().css(hideStyle).animate(showStyle, 200);
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
