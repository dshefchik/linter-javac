module.exports =
  config:
    classPath:
      type: 'string'
      default: '.'
    classPathFile:
      type: 'string'
      default: '.classpath'

  activate: ->
    console.log 'activate linter-javac'
