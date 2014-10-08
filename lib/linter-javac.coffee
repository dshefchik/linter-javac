{exec, child} = require 'child_process'
fs = require 'fs'
xml2js = require 'xml2js'
_ = require 'lodash'
linterPath = atom.packages.getLoadedPackage('linter').path + '/lib/linter'
Linter = require '' + linterPath

getCommand = () ->
  path = getClassPath()
  console.log('path: ' + path)
  return 'javac -classpath \"' + path + '\" -Xlint:all'

getClassPath = () ->
  projectPath = atom.project.path + '/'
  classPath = atom.config.get('linter-javac.classPath') or projectPath
  classPathFile = atom.config.get('linter-javac.classpathFile') or '.classpath'
  console.log 'classpath:' + classPath
  console.log 'classPathFile:' + classPathFile

  classPathFile = projectPath + classPathFile
  console.log 'projectPath:' + projectPath
  console.log 'classPathFile:' + classPathFile
  # Parse eclipse classpath
  parser = new xml2js.Parser()
  contents = fs.readFileSync classPathFile
  parser.parseString contents, (err, result) ->
    result.classpath.classpathentry = [] if err
    _.each result.classpath.classpathentry, (entry) ->
      finalPath = entry.$.path
      (finalPath = projectPath + finalPath) if entry.$.path.charAt(0) isnt "/"
      # console.log 'char at 0 :' + entry.$.path.charAt(0)
      console.log 'adding path: ' + finalPath
      classPath = classPath + ':' + finalPath
    
  console.log 'Final classPath:' + classPath
  atom.config.set('linter-javac.classPath', classPath)
  return classPath

class LinterJavac extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  # TODO: research if there are other java resources must be added
  @syntax: 'source.java'

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  # cmd: 'javac -classpath \"' + getClassPath + '\" -Xlint:all'
  cmd : getCommand()
  linterName: 'javac'

  # A regex pattern used to extract information from the executable's output.
  regex: 'java:(?<line>\\d+): ((?<error>error)|(?<warning>warning)): (?<message>.+)\\n'

  constructor: (editor) ->
    super(editor)
    atom.config.observe 'linter-javac.javaExecutablePath', =>
      @executablePath = atom.config.get 'linter-javac.javaExecutablePath'

  destroy: ->
    atom.config.unobserve 'linter-javac.javaExecutablePath'

  errorStream: 'stderr'




module.exports = LinterJavac
