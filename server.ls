
Path = require "path"


Program = require "commander"
Livescript = require 'livescript'

Express = require "express"
Connect = require "connect"
WebSocket = require 'ws'

Mongoose = require 'mongoose'
Schema = Mongoose.Schema
ObjectId = Schema.ObjectId

Stylus = require "stylus"

Inspect = require 'eyes' .inspector!

ONE_YEAR = 1000 * 60 * 60 * 24 * 365

#FEATURE: add a json config parser (guille?)
Config = {
	port: 1155
}

port = process.env.PORT || Config.port

Program
	.version "0.1.1"
	.usage "[options] [dir]"
	.option "-p, --port <port>", "specify the port [#{port}]", Number, port
	.parse process.argv


#IMPROVEMENT: move this over to a lib file somewhere
str_replace = (str, f, r) ->
	until str.indexOf f is -1
		str = str.replace f, r
	return str
	
path = Path.resolve Program.args.shift! or \.
#root = Path.dirname __dirname
root = __dirname
public_path = Path.join root, 'public'
views_path = Path.join root, 'views'


Express.static.mime.define 'application/dart': ['dart']
server = Express.createServer!
#server.engine '.html', Ejs.__express
server.set 'env', if Config.debug then 'development' else 'production'
server.use Stylus.middleware {
	src: public_path
	compile: (str, path) ->
		return Stylus str
			.use Bootstrap!
			.set 'filename', path
			.set 'compress', true
			.set 'firebug', true
			.set 'linenos', true
	}
server.use Express.favicon!
#server.use Gzippo.staticGzip public_path, maxAge: 1000 #ONE_YEAR
#server.use Express.compress!
server.use Express.methodOverride!
server.use Express.bodyParser!
server.use Express.cookieParser 'chucknorris'
server.use Express.session { secret: "chucknorris" }
server.set "view options", { layout: true }
server.set "view engine", "ejs"
server.set "views", views_path
server.use "/", Express.static public_path, maxAge: 1
#server.use nQuery.middleware
server.use server.router

server.listen port, ->
	console.log "listening on port #{port}"

cmds = [
	"new", "lala"
]



Program.choose cmds, (i) ->
	console.log "cmd: #{i}"
	process.stdin.destroy!
