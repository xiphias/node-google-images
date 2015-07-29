request = require 'request'
fs = require 'fs'

generateInfo = (item) ->
  info = 
		width: item.width
		height: item.height
		unescapedUrl: item.unescapedUrl
		url: item.url
		writeTo: (path, callback) ->
			stream = fs.createWriteStream path
			stream.on 'close', ->
				callback?()
			request(item.url).pipe stream
  return info

exports.search = (query, options) ->
	if typeof query is 'object'
		options = query
		query = options.for
		callback = options.callback if options.callback?
	if typeof query is 'string' and typeof options is 'function'
		callback = options
		options = {}
	if typeof query is 'string' and typeof options is 'object'
		callback = options.callback if options.callback?
	
	options.page = 0 if not options.page?
	options.hl = 'en' if not options.hl?
	
	request "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&hl=#{options.hl}&q=#{ query.replace(/\s/g, '+') }&start=#{ options.page }", (err, res, body) ->
		items = JSON.parse(body).responseData.results
		images = []
		for item in items
      images.push generateInfo item
		
		callback no, images if callback
