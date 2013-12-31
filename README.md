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

## License

Custom Web is released with the [MIT License](http://mitl.sharats.me).

## Credits

This project wouldn't been possible without these fantastic projects by awesome
folks.

- jQuery (John Resig)
- Solarized (Ethan Schoonover)

If you don't like Custom Web, there are a few alternatives, some of which have
provided inspiration to this project.

- dotjs (I used to use this prior to creating Custom Web)
- rweb
- StyleBot (only CSS, no JavaScript)
- JScript Tricks
- Stylish (only CSS, has sharing features, integrates with userstyles.org)
- TamperMonkey (only JS, integrates with userscripts.org)
