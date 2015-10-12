browserify-brunch
=================

Brunch + Browserify

If this seems a little weird, that's because it is. Brunch already wraps
modules in CommonJS / AMD / whatever you like. But being able to use NPM
modules in the browser is pretty great too.

Configuration
-------------

Example `brunch-config.coffee`

```coffee
exports.config =
  # Note that the usual app.js is commented out.
  # This isn't needed when using Browserify.
  files:
    javascripts:
      joinTo:
        #'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^(vendor|bower_components)/
        'test/javascripts/test.js': /^test\/(?!vendor)/
        'test/javascripts/test-vendor.js': /^test\/(?=vendor)/

  # Again, browserify provides these.
  modules:
    wrapper: false
    definition: false

  plugins:
    browserify:
      # A string of extensions that will be used in Brunch and for browserify.
      # Default: js json coffee ts jsx hbs jade.
      extensions: """
      js coffee
      """

      bundles:
        'javascripts/app.js':
          # Passed to browserify.
          entry: 'app/bootstrap.coffee'

          # Anymatch, as used in Brunch.
          matcher: /^app/

          # Direct access to the browserify bundler to do anything you need.
          onBrowserifyLoad: (bundler) -> console.log 'onWatchifyLoad'

          # Any files watched by browserify won't be in brunch's regular
          # pipeline. If you do anything before your javascripts are compiled,
          # now's the time.
          onBeforeBundle: (bundler) -> console.log 'onBeforeBundle'

          # Any files watched by browserify won't be in brunch's regular
          # pipeline. If you do anything after your javascripts are compiled,
          # now's the time.
          onAfterBundle: (error, bundleContents) -> console.log 'onAfterBundle'

          # Any options to pass to `browserify`.
          # `debug` will be set to `!production` if not already defined.
          # `extensions` will be set to a proper list of
          # `plugins.browserify.extensions`
          instanceOptions: {}
```
