# Description:
#   Just WTF. Fork of https://github.com/jakswa/hubot-reaction
#
# Dependencies:
#   "request"
#   "cheerio"
#
# Configuration:
#   None
# 
# Author:
#   jakswa 

request = require('request')
cheerio = require('cheerio')
format = require('util').format

module.exports = (robot) ->
  robot.hear /wtf/i, (msg) ->
    getGifs "what-the-fuck", (gifs) ->
      if gifs.length > 0
        ind = Math.floor(Math.random() * gifs.length)
        msg.send gifs.eq(ind).attr('src').replace('thumbnail', 'i')

  # simple, in-memory, hour-long cache of requests
  # (don't run this for years or anything, not cleaning up unused ones :)
  gifSets = {}
  getGifs = (tag, callback) ->
    gifSet = gifSets[tag]
    if gifSet && ((new Date()) - gifSet.date) > 3600000 # 1 hour
      gifSet = gifSets[tag] = null # clear old cache item if expired
    if gifSet
      callback(gifSet.gifs) 
      return
    request format('http://replygif.net/t/%s', tag), (err, resp, body) ->
      if err
        callback []
        return
      gifs = cheerio.load(body)('img.gif')
      gifSets[tag] = {date: new Date(), gifs: gifs}
      callback(gifs)
