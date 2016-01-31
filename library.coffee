# settings
CONF_FILE_NAME = '.node-miopon'
CONF_PATH = (process.env.HOME || process.env.USERPROFILE) + '/' + CONF_FILE_NAME

# modules requirement
fs = require 'fs'
_ = require 'underscore'
miopon = require 'node-miopon'
moment = require 'moment'

readConfig = ({path, success, failure}) ->
    data = ''
    fs.createReadStream path
        .on 'error', (err) ->
            if err.code is 'ENOENT'
                if typeof failure is 'function'
                    red     = '\u001b[31m'
                    reset   = '\u001b[0m'
                    console.log "[#{red}WARN#{reset}] no config file specified."
                    failure()
        .on 'data', (chunk) ->
            data += chunk
        .on 'end', () ->
            config = JSON.parse data
            if typeof success is 'function'
                success config


#exportsするもの
e = {}

e.init = ({path, mioID, mioPass, client_id, redirect_uri, success}) ->
    path = if path then path else CONF_PATH

    if mioID && mioPass && client_id && redirect_uri
        ws = fs.createWriteStream path
        ws.write JSON.stringify {mioID, mioPass, client_id, redirect_uri}
        ws.end()
        if typeof success is 'function'
            success()
    else
        rl = require('readline').createInterface {
                input: process.stdin,
                output: process.stdout
        }

        rl.question '(mio ID)? ', (mioID) ->
            rl.question '(IIJ password)? ', (mioPass) ->
                rl.question '(IIJ developers ID)? ', (client_id) ->
                    rl.question '(redirect URI)? ', (redirect_uri) ->
                        ws = fs.createWriteStream path
                        ws.write JSON.stringify {mioID, mioPass, client_id, redirect_uri}
                        ws.end()
                        rl.close()
                        if typeof success is 'function'
                            success()
    return


# access_tokenの情報を取得する
e.info = ({path, success, failure}) ->
    green   = '\u001b[32m'
    red     = '\u001b[31m'
    reset   = '\u001b[0m'

    path = if path then path else CONF_PATH
    readConfig {
        path
        success: (config) ->
            expired_in = moment config.expires_at
                .diff moment(), 'second'
            expired = expired_in < 0
            if expired
                message = "[#{red}WARN#{reset}] token has been exipred."
            else
                message = "[#{green}OK#{reset}] token is available."
            console.log message
            if typeof success is 'function'
                success expired
        failure: ->
            failure()
    }


# oAuthする
e.update = ({path}) ->
    path = if path then path else CONF_PATH
    readConfig {
        path
        success: (config) ->
            miopon.oAuth {
                mioID: config.mioID
                mioPass: config.mioPass
                client_id: config.client_id
                redirect_uri: config.redirect_uri

                success: ({client_id, access_token, expires_in}) ->
                    config.access_token = access_token
                    config.expires_at = moment().add(expires_in, 'second')
                    ws = fs.createWriteStream path
                    ws.write JSON.stringify config
                    ws.end()
            }
    }

#認証情報を削除する
e.delete = ({path}) ->
    path = if path then path else CONF_PATH
    readConfig {
        path
        success: ->
            fs.unlink path
    }

e.version = ->
    pkg = require "#{__dirname}/package.json"
    green   = '\u001b[32m'
    cyan    = '\u001b[36m'
    reset   = '\u001b[0m'
    message = "#{green}#{pkg.name} #{reset}version #{cyan}#{pkg.version}#{reset}"
    console.log message
    return message

e.on = ->
    return

e.off = ->
    return


synonyms =
    info: ['i']
    update: ['auth']
    delete: ['d','del']
    version: ['v', 'ver']

for method in Object.keys synonyms
    for synonym in synonyms[method]
        if method in Object.keys e
            e[synonym] = e[method]

module.exports = e



return




delay = if process.argv[3] then (process.argv[3] / 1000) else 0
data = ''

fs.createReadStream CONF_PATH
    .on 'error', (err) ->
        if err.code is 'ENOENT'
            console.log 'config file not found.'
    .on 'data', (chunk) ->
        data += chunk
    .on 'end', () ->
        config = JSON.parse data
        console.log 'config read finished.'

        mioID = config.mioID
        mioPass = config.mioPass
        client_id = config.client_id
        access_token = config.access_token
        redirect_uri = config.redirect_uri

        setTimeout ->
            coupon.inform {
                client_id
                access_token
                success: ({information})->
                    console.log 'coupon information obtained.'
                    coupon.turn {
                        client_id
                        access_token
                        query: querify {
                            information
                            couponUse: usage
                        }
                        success: ->
                            console.log 'coupon turn successed!'
                        failure: ->
                            console.log 'coupon turn failed..'
                    }
                failure: (err) ->
                    console.log err

                failure: (err, res) ->
                    console.log 'coupon information not obtained.'
                    console.log err
                    unless res
                        console.log 'access too many'
                        return
                    coupon.oAuth {
                        mioID
                        mioPass
                        client_id
                        redirect_uri
                        success: (result)->
                            console.log 'oAuth success.'
                            access_token = result.access_token
                            config.access_token = access_token
                            ws = fs.createWriteStream CONF_PATH
                            ws.write JSON.stringify config
                            ws.end()
                            coupon.inform {
                                client_id
                                access_token
                                success: ({information})->
                                    console.log 'coupon information obtained with new access_token.'
                                    coupon.turn {
                                        client_id
                                        access_token
                                        query: querify {
                                            information
                                            couponUse: usage
                                        }
                                    }
                            }
                    }
                }
        , delay
