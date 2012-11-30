


grid = ->
	cE 'div', {c: 'grid grid-pad'}, ...

col = (col, total, ...args) ->
	cE 'div', {c: "col-#{col}-#{total}"},
		cE 'div', {c: 'content'}, args

Meteor.autorun ->
	#BUG: this has bugs and has duplicated code for what is inside of the menu. poems/poem/poem.ls
	if id = Meteor.userId!
		console.log "logged in user: #id"
		if mun = Session.get 'mun'
			console.log "logged in mun:", mun
			Mun.id = mun._id
		else
			console.log "don't have mun yet..."
	else# if Mun.id
		console.log "logged out", Session.get 'mun'
		Mun.id = null
		Session.set 'mun', null



Meteor.startup ->
	doc = $ document
	window.page = require 'visionmedia-page.js'
	window.THREE = require 'timoxley-threejs'
	window.Mousetrap = require 'component-mousetrap'
	window.sprintf = require 'heavyk-format' .sprintf
	window.ColorPicker = require 'heavyk-color-picker'
	window.Popover = require 'component-popover'
	
	page '/', (ctx, next) ->
		console.log "TODO: default! DO SPLASH PAGE"
		$ '#content' .empty!append cE 'h2', {s: 'color:#f0f'}, "TODO: SPLASHY SPLISH-SPLASH"

	#for own route, cbs of Poem._router
	_.each Poem._router, (cbs, route) ->
		callbacks = []
		for cb in cbs
			callbacks.push (ctx, next) ->
				panel = cb ...
				if panel
					$ '#content' .empty!append panel.render!
				else next!
		page.apply @, [route].concat callbacks
		delete Poem._router[route]

	page '*', (ctx, next) ->
		console.log "trying the router...", Poem._router
		next!
	page '*', (ctx, next) ->
		console.log "TODO: 404! show splash page 404 (create a new poem)", ctx
		$ '#content' .empty!append cE 'h2', {s: 'color:#f00'}, "404!"

	menu = Menu {_id: '1111', _classes: 'sidebar'}
	$ '#sidebar' .empty!append menu.render!
	
	Mousetrap.bind 'meta+g', (e) ->
		console.log "TODO: show a little popup query box listing the poems installed (and blur the screen!!)"
		e.preventDefault!

	keydown = (evt) ->
		switch evt.keyCode
		| 17, 91 => # ctrl / meta key
			if evt.ctrlKey and evt.metaKey then Renderable.show_controls!
	keyup = (evt) ->
		switch evt.keyCode
		| 17, 91 => # ctrl / meta key
			if evt.ctrlKey or evt.metaKey then Renderable.hide_controls!

	doc.keydown keydown
	doc.keyup keyup
	
	page.start! # {-dispatch}

	/*
	# TODO: abandon this idea, and instead implement the nshell
	# https://github.com/visionmedia/nshell
	require ["vfs-socket/consumer", "ace", "tty"], (consumer, ace, tty) ->
		console.log $ 'div [data-editor="ace"]'

	require ["vfs-socket/consumer", "ace", "tty"], (consumer, ace, tty) ->
		console.log "inside require"
		BrowserTransport = consumer.smith.BrowserTransport
		Consumer = consumer.Consumer
		Terminal = tty.Terminal

		consumer = new Consumer!

		url = document.location.origin.replace /^http/, "ws"
		ws = new WebSocket url
		ws.onopen = ->
			consumer.connect new BrowserTransport(ws, true), (err, server) ->
				if err then throw err
				window.server = server
				server.readdir "/", {}, (err, meta) ->
					meta.stream.on "data", (stat) ->
						row = document.createElement "p"
						row.textContent = JSON.stringify stat
						document.getElementById "files" .appendChild row
					ace.edit document.getElementById "editor"
					terminal = new Terminal 80, 24, (chunk) ->
						console.log "->", chunk
					terminal.open document.getElementById "terminal"
*/
