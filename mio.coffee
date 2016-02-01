# CLI toolのエントリポイント
# mio method arg1 arg2 arg3..

# parse arguments
method = if process.argv[2] then method = process.argv[2].toString() else method = ''
args = process.argv.slice 3
lib = require __dirname + '/library'


if typeof lib[method] is 'function'
    lib[method].apply args
else
    pkg = require __dirname + '/package.json'
    console.log  "#{pkg.name}: #{method}: command not found"

return
