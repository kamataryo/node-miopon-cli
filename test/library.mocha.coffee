expect = require('chai').expect
_      = require 'underscore'
fs     = require 'fs'
mio    = require '../library'

alsoTestWebCases = true
describeWebCases = if alsoTestWebCases then describe else describe.skip

describe 'Interfaces: ', ->
    methods = [
        ['init']
        ['info', 'i']
        ['update','auth']
        ['delete', 'd', 'del']
        ['version','v', 'ver']
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
            path = __dirname + '/.node-miopon-to-init'
            mioID = 'testID'
            mioPass = 'testPass'
            client_id = 'test dev id'
            redirect_uri = 'test_redirect'
            mio.init {
                path, mioID, mioPass, client_id, redirect_uri
                success: ->
                    data = ''
                    fs.createReadStream path
                        .on 'error', (err) ->
                            if err.code is 'ENOENT'
                                expect(false).to.be.true
                                done()
                        .on 'data', (chunk) ->
                            data += chunk
                        .on 'end', () ->
                            result = ''
                            try
                                result = JSON.parse data
                            catch error
                                # たまに、おかしくなる。空のJSONが生成されている
                                console.log 'invalid json spawned..'
                                expect(false).to.be.true
                                done()
                            expect(result.mioID).to.eql mioID
                            expect(result.mioPass).to.eql mioPass
                            expect(result.client_id).to.eql client_id
                            expect(result.redirect_uri).to.eql redirect_uri
                            fs.unlink path, (err) ->
                                if err
                                    expect(false).to.be.true
                                done()
            }



    describe '`info` ', ->
        it 'check token is out of date', (done) ->
            mio.info {
                path: __dirname + '/.node-miopon-dummy-old'
                quiet: true
                success: ({expired}) ->
                    expect(expired).to.be.true
                    done()
            }

        it 'check token is out of date', (done) ->
            mio.info {
                path: __dirname + '/.node-miopon-dummy-new'
                quiet: true
                success: ({expired}) ->
                    expect(expired).to.be.false
                    done()
            }

        it 'failes with unknown path', (done) ->
            mio.info {
                path: 'this/is/a/nonsense/path'
                quiet: true
                success: ->
                    expect(false).to.be.true
                    done()
                failure: ->
                    done()
            }


    describeWebCases '`update` ', ->
        it 'works well'
        return


    describe '`delete` ', ->

        it 'delete the config file.', (done) ->
            path = __dirname + '/.node-miopon.to.delete'
            mio.init {
                path
                mioID: 'testID'
                mioPass: 'testPass'
                client_id: 'test dev id'
                redirect_uri: 'test_redirect'
                success: ->
                    fs.unlink path, ->
                        fs.createReadStream path
                            .on 'error', (err) ->
                                if err.code is 'ENOENT' then done()
            }

    describe '`version` ', ->

        it 'exports some message.', ->
            expect(mio['version'].apply()).not.to.equal ''
