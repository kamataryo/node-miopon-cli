expect = require('chai').expect
_      = require 'underscore'
fs     = require 'fs'
mio    = require '../library'

alsoTestWebCases = true
describeWebCases = if alsoTestWebCases then describe else describe.skip

describe 'Interfaces: ', ->
    methods = [
        ['init']
        ['update','auth']
        ['token']
        ['version','v','ver']
        ['on']
        ['off']
    ]
    _.each _.flatten(methods), (method) ->
        it "method `#{method}` exists.", ->
            expect(mio[method]).to.be.a 'function'

    _.each methods, (synonyms) ->
        _.each synonyms, (method1) ->
            _.each synonyms, (method2) ->
                unless method1 is method2
                    it "#{method1} is synonym of #{method2}", ->
                        expect(mio[method1]).to.equal mio[method2]




describe 'Behaviors: ', ->


    describe '`init` ', ->

        it 'generate cofig file', (done) ->
            options =
                path: __dirname + '/.node-miopon'
                mioID: 'testID'
                mioPass: 'testPass'
                client_id: 'test dev id'
                redirect_uri: 'test_redirect'
            mio.init options

            data = ''
            fs.createReadStream options.path
                .on 'error', (err) ->
                    if err.code is 'ENOENT'
                        expect(false).to.be.true
                        done()
                .on 'data', (chunk) ->
                    data += chunk
                .on 'end', () ->
                    result = JSON.parse data
                    expect(result.mioID).to.eql options.mioID
                    expect(result.mioPass).to.eql options.mioPass
                    expect(result.client_id).to.eql options.client_id
                    expect(result.redirect_uri).to.eql options.redirect_uri
                    fs.unlink options.path, (err) ->
                        if err
                            expect(false).to.be.true
                        done()


    describeWebCases '`update` ', ->
        it 'works well'
        return


    describe '`token` ', ->
        it 'returns some message: expired', (done) ->
            mio.token {
                path: __dirname + '/.node-miopon-dummy-old'
                success: (expired) ->
                    expect(expired).to.be.true
                    done()
            }

        it 'returns some message: not expired', (done) ->
            mio.token {
                path: __dirname + '/.node-miopon-dummy-new'
                success: (expired) ->
                    expect(expired).to.be.false
                    done()
            }

    describe '`version` ', ->

        it 'exports some message.', ->
            expect(mio['version'].apply()).not.to.equal ''
