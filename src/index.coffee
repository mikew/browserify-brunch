anymatch = require 'anymatch'
{BrowserifyInstance} = require './browserify-instance'
{clone} = require './util'
{AutoReloadServer} = require './auto-reload-server'
path = require 'path'

DEFAULTS = {
  extensions: """
  js json
  coffee ts jsx
  hbs jade
  """
  transforms: []

  bundles:
    'app.js':
      entry: 'app/init.js'
      matcher: /^app/
      onBrowserifyLoad: undefined
      onBeforeBundle: undefined
      onAfterBundle: undefined
      instanceOptions: undefined
}

module.exports = class BrowserifyBrunch
  brunchPlugin: yes
  type: 'javascript'
  extension: 'coffee'
  throttle: 250

  constructor: (@brunchConfig) ->
    @production = 'production' in @brunchConfig.env
    @publicPath = @brunchConfig.paths.public
    @watching = 'watch' in process.argv

    @__initConfig()
    @__initExtensions()
    @__initInstances()
    @__initAutoReload()

  __initConfig: ->
    @config = clone @brunchConfig.plugins?.browserify || {}
    @config[k] ?= v for k, v of DEFAULTS
    null

  __initExtensions: ->
    @extensionList = @config.extensions.trim().split /\s+/
    @pattern = ///\.(#{@extensionList.join '|'})$///

  __initInstances: ->
    @__instances = {}
    for compiledPath, data of @config.bundles
      data.instanceOptions ?= {}
      data.main = this
      data.instanceOptions.extensions ?= (".#{ext}" for ext in @extensionList)
      data.compiledPath = compiledPath
      data.transforms = @config.transforms

      instance = new BrowserifyInstance data
      instance.matcher = anymatch data.matcher

      @__instances[compiledPath] = instance

    null

  __initAutoReload: ->
    return if not @watching
    @__autoReloadServer = new AutoReloadServer @config

  include: ->
    return [] if not @__autoReloadServer?
    [path.join __dirname, '..', 'vendor', 'auto-reload-browserify.js']

  compile: (fileContents, filePath, callback) ->
    if @__autoReloadServer? and path.basename(filePath) is 'auto-reload-browserify.js'
      return callback null, fileContents.replace(9812, @__autoReloadServer.port), filePath

    if @watching
      return callback null, fileContents, filePath

    __triggered = false

    for compiledPath, instance of @__instances
      continue if not instance.matcher filePath
      continue if instance.running

      __triggered = true
      instance.handleUpdate arguments...

    callback(null, fileContents, filePath) if not __triggered
    null

  teardown: ->
    @__autoReloadServer?.teardown()
