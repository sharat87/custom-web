# Custom Web

Custom Web is a chrome extension that allows users to write their own JS and CSS
to be added to any and all websites. The javascript executed has jQuery
available in scope (as `$`).

You can define CSS that is added to all websites in the `!default` entry in the
options page and CSS specific to each domain, in the corresponding CSS editor
for that domain.

Similarly, you can define JavaScript that will be run on jQuery's `ready` event
with the variable `$` in scope that provides access to jQuery version
$jq-version.  This jQuery instance is independent of the jQuery used by the host
page, if any.  The JavaScript code added to the `!default` entry will be
executed on every website, following which, the code added to the domain
specific entry in the options page will be run. The `this` object in both the
`!default` and domain specific code is shared, so any common functions can be
defined in the default script under the `this` object and be accessed in the
domain specific scripts.

## Your code is *not* synced

To sync your scripts and styles, the `chrome.storage.sync` store could be
utilized, but its [size
limitations](http://developer.chrome.com/extensions/storage.html#property-sync)
make it fairly easy to hit the limits.  However using `chrome.storage.local`
with the `unlimitedStorage` permission, resolves this, but loses syncing. You
are advised to regularly export your data and keep a backup handy.

## Migrate from dotjs

I used to use the dotjs extension before creating this. I have written a small
python script that will export all your dotjs scripts (from `~/.js`) and styles
(from `~/.css`) to a format that this extension can import.

You can get the `dotjs-export.py` script from the [project page on
github](https://raw2.github.com/sharat87/custom-web/master/dotjs-export.py).

## About

I am Shrikant Sharat Kandula, from India. Find me on [the web](http://sharats.me),
[twitter](https://twitter.com/sharat87) and [github](gh).

## License

Custom Web is released with the [MIT License](http://mitl.sharats.me). You can
access the source on the [github project
page](https://github.com/sharat87/custom-web).

## Credits

This project wouldn't been possible without these fantastic projects by awesome
folks. Thanks!

- jQuery (John Resig)
- CodeMirror (Marijn Haverbeke)
- Solarized (Ethan Schoonover)

If you don't like Custom Web, there are a few alternatives, some of which have
provided inspiration to this project.

- dotjs (I used to use this prior to creating Custom Web)
- rweb
- StyleBot (only CSS, no JavaScript)
- JScript Tricks
- Stylish (only CSS, has sharing features, integrates with userstyles.org)
- TamperMonkey (only JS, integrates with userscripts.org)

[gh]: https://github.com/sharat87
