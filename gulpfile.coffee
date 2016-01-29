gulp    = require 'gulp'
plumber = require 'gulp-plumber'
coffee  = require 'gulp-coffee'
header  = require 'gulp-header'
chmod   = require 'gulp-chmod'
mocha   = require 'gulp-mocha'

gulp.task 'coffee', ->
    gulp.src [
        './mio.coffee',
        './library.coffee'
    ]
        .pipe plumber()
        .pipe coffee {
            bare: false
        }
        .pipe gulp.dest './'

gulp.task 'executify',['coffee'], ->
    gulp.src './mio.js'
        .pipe header '#!/usr/bin/env node\n'
        .pipe chmod 755
        .pipe gulp.dest './'

gulp.task 'mocha',['build'], ->
    gulp.src [
        './test/library.mocha.coffee'
    ]
        .pipe mocha {
            compilers: 'coffee-script'
            reporter: 'nyan'
        }

# wrapper or synonym
gulp.task 'build', ['coffee', 'executify']
gulp.task 'test', ['build','mocha']



gulp.task 'watch', ->
    gulp.watch [
        './mio.coffee'
        './library.coffee'
        './test/library.mocha.coffee'
    ]
    , ['build','test']

gulp.task 'default', ['build','test','watch']
