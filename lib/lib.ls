

if Meteor.isServer
	publish = (key, cursor_fn) ->
		console.log "lets try publishing #key", cursor_fn
		Meteor.publish key, !->
			cursor = cursor_fn.apply this, arguments
			collection = cursor.collection_name
			cursor.observe {
				#_suppress_initial: 1
				added: (doc) ~>
					@set collection, doc._id, doc
					@flush!

				changed: (obj, old_idx, old_obj) ~>
					set = {}
					_.each obj, (v, k) ->
						if !_.isEqual v, old_obj[k]
							set[k] = v
					@set collection, obj._id, set
					dead_keys = _.difference _.keys(old_obj), _.keys(obj)
					@unset collection, obj._id, dead_keys
					@flush!

				removed: (old_obj, old_idx) ~>
					@unset collection, old_obj._id, _.keys old_obj
					@flush!
			}

			@complete!
			@flush!

Meteor.methods {
	test: (data) ->
		console.log "this is a test method... will run on server, but appear to run on the client at the same time", data
}


Renderable = (d = {}) ->
	#if typeof d is \function then d = d!
	if typeof d is \string
		id = d
		d = Renderable.obj[d]
	if !d then d = {}
	if !d._id
		console.error "TODO: something wrong? rendering something without an id!"
		d._id = Meteor.uuid!
		#debugger

	@_state = 'loading'
	@_class = ''
	@_prefix = 'i'
	for own k, v of d
		@[k] = v
	
	Renderable.obj[@_id] = @
	Renderable.length++
	if typeof @_el is \undefined then @_el = 'div'
	@_el = cE @_el, {c: @_class, id: "#{@_prefix}_#{@_id}"}

Renderable.obj = {}
Renderable.length = 0
Renderable.is_id = (i) ->
	typeof i is 'string' and (i = i.replace /-/g, '').length is 32 and i.match /[0-9a-f]*/ .0.length is 32
Renderable.forEach = (cb) ->
	for own k, v of Renderable.obj
		cb v, k
Renderable.show_controls = ->
	Renderable.forEach (obj, id) ->
		obj.show_controls!
Renderable.hide_controls = ->
	Renderable.forEach (obj, id) ->
		obj.hide_controls!

Renderable:: = {
	render: (view, render_func) ->
		if typeof view is \function
			render_func = view
			view = '_'
		if typeof render_func is not \function then render_func = ->
		#TODO: empty the node for a rerender
		aC @_el, ~>
			if typeof(f = @renderFunc) is \function
				f.call this, view, render_func
			else
				render_func.call this, @_el
		return @_el

	show_controls: ->
		@_el.style.margin = '-2px'
		@_el.style.border = 'solid 2px rgba(128,0,0,.5)'
		@render 'controls'

	hide_controls: ->
		@_el.style.margin = ''
		@_el.style.border = ''
		@render 'controls'

	on: (evt, cb) ->
		console.log "subscribing to event:", evt
		console.log "TODO: test this is working properly..."
		amplify.subscribe "#{@_id}:#{evt}", cb
		return @

	update: (selector, cb) ->
		if typeof selector is \function
			cb = selector
			selector = ""
		for p, i in els = $ "#{@_prefix}_#{@_id} #{selector}".trim!
			cb p, i, els

	list: (key, cursor, fn) ->
		obj = this
		sub_fn = (el, observe_fn) ->
			return ->
				offset = 0
				list = el
				while list = list.previousSibling
					offset++
				list = el.parentNode
				els = []
				observers = {
					render: ->
					added: (doc, idx) ~>
						e = observers.render.call(obj, doc)
						aC list, e, idx+offset
						#console.log "observe.added", arguments, @_id
					changed: (doc, idx, old_obj) ~>
						console.log "observe.changed", arguments
					moved: (doc, old_idx, new_idx) ~>
						console.log "observe.moved", arguments
					removed: (doc, idx) ~>
						console.log "observe.removed", arguments
				}

				if typeof observe_fn is \function
					observers.render = observe_fn
				
				cursor.observe observers
				$ el .remove!
				#$ el .empty!
				#console.log el
				#cursor.forEach (doc) ->
				#	console.log "foreach", el, doc
				#	aC el, observers.render.call obj, doc
				

		selector = cursor.selector
		keys = _.keys selector .sort!
		args = [key]
		for k in keys
			v = selector[k]
			args.push v

		list_el = cE 'div', {c:"list-#{key}"}, "loading..."
		Meteor.subscribe.apply this, args +++ sub_fn list_el, fn
		#debugger;
		#console.log obj.render!
		return list_el
}

# add states ... unloaded, loaded, running, paused
# publish these events on amplifiyjs
# later use amplify to simplify requests to gatunes (and other resources)
class Machina extends Renderable
	(d) ~>
		super d
		# user getter/setter functions


# when entering the loaded state, resize and add the renderer
class Renderable3 extends Machina
	(d) ~>
		super d
		@camera = new THREE.PerspectiveCamera 75, window.innerWidth / window.innerHeight, 1, 1000
		@camera.position.z = 500
		@scene = new THREE.Scene
		@renderer = new THREE.CanvasRenderer
		#@renderer = new THREE.WebGLRenderer antialias: true #, sortObjects: false
		@renderer.setSize 10, 10
		@_num_frames = 4
		#window.addEventListener 'resize', ~>
		setTimeout ~>
			el = @_el
			console.log el, el.clientWidth, el.clientHeight, @renderer
			@renderer.setSize el.clientWidth, 500
			@animate!
		, 10

	animate: ->
		let a = @animate, obj = @
			requestAnimationFrame ->
				return a.apply obj, arguments
		@renderer.render @scene, @camera

	render: ->
		# switch this over to, if amplify.publish "#{prefix}_#{id}.render"
		el = super ...
		aC el, @renderer.domElement
		return el

class Verse extends Renderable
	(d) ~>
		super ...
		#TODO: load these from the database!

class TODO extends Verse
	(d) ~>
		super ...
		#TODO: record how many times this was rendered, and add that to the stats

	# statics
	@_collection = new Meteor.Collection 'todo'
	for k in ['find', 'findOne', 'insert', 'update', 'remove']
		let c = @_collection
			if typeof(v = c[k]) is \function
				@[k] = ->
					v.apply c, arguments


class Icosahedron extends Renderable3
	(d) ~>
		super d
		@geometry = new THREE.IcosahedronGeometry 200, 1
		@material = new THREE.MeshBasicMaterial color: 0x000000, wireframe: true, wireframeLinewidth: 2
		@mesh = new THREE.Mesh @geometry, @material
		@scene.add @mesh

	animate: ->
		@mesh.rotation.x = Date.now! * 0.0005
		@mesh.rotation.y = Date.now! * 0.001
		super!

class Poem extends Renderable
	(d) ~>
		console.log "poem", d
		if typeof d is \string
			if Renderable.is_id d
				d = Poem.findOne d
			else
				d = Poem.findOne name: d
		else if typeof d is \object
			dd = Poem.find d .fetch!
			if dd.length then d = dd.0
			console.log "d", d
		super d

	renderFunc: (view, fn) ->
		cE 'div', {c: 'grid grid-pad'}, -> "WTF"

	# statics
	@_router = {}
	@add = (route, cb) ->
		if typeof page is \function
			console.error "TODO: add a lazy-loading feature to the client"
			# obviously I don't want to put the `$ '#content' .empty!append` code here, as the poem might be loaded standalone
		else
			# when the client is finally loaded, lazy-load these
			if typeof @_router[route] is not \object
				@_router[route] = [cb]
			else
				@_router[route].push cb

	@_collection = new Meteor.Collection 'poem'
	for k in ['find', 'findOne', 'insert', 'update', 'remove']
		let c = @_collection
			if typeof(v = c[k]) is \function
				@[k] = ->
					v.apply c, arguments

class Mun extends Verse
	(d) ~>
		console.log "new mun", d
		super ...

	render: ->
		switch @_view
		| "very small" =>
			user = Mun.find {user: @_id}
			@list 'mun-user', user, (mun) ->
				cE 'div', {c: 'mun'},
					cE 'a', {c: 'name' href: "/mun/#{mun.name}"},
						cE 'div', {c: 'avatar-small'},
							cE 'i', {c: "icon-user"}
							cE 'span', null, mun.name
					cE 'a', {
						c: 'logout'
						href: '/logout'
						onclick: ->
							Meteor.logout ->
								Meteor._reload.reload!
							return false
					}, "logout"
		| otherwise =>
			cE 'div', {c: 'mun'},
				cE 'a', {href: "/user/#{@name}"},
					cE 'div', {c: 'avatar'},
						cE 'i', {c: "icon-user"}
					$(cE 'div', {c: 'prox'}).progressbar value: Math.random! * 100

	@_collection = new Meteor.Collection 'mun'
	for k in ['find', 'findOne', 'insert', 'update', 'remove']
		let c = @_collection
			if typeof(v = c[k]) is \function
				@[k] = ->
					v.apply c, arguments
	if Meteor.isServer
		publish "mun-user", (user) ->
			Mun.find {user}
		publish "mun-name", (name) ->
			Mun.find {name}

class MunPoem extends Poem
	(d) ~>
		super ...

	render: (view, fn) ->
		cE 'div', {c: 'grid grid-pad'}, # <<< I don't like this
			col 9, 12, (el) ~>
				user = Mun.find {name: @name}
				console.log "WOAH YEAH", @name
				return [
					@list 'mun-name', user, (mun) ->
						resolves = Resolve.find mun: mun._id, parent: null
						return [
							cE 'h1', null, mun.name
							cE 'h3', null, "beliefs"
							@list 'resolve-mun', resolves, (resolve) ->
								resolve._view = 'headline'
								Resolve resolve /* .on '_val:change', ->
									aC el, Resolve {id: 2, _view: 'headline', belief: "Eres Sincero?"} */
						]
				]
	Poem.add '/mun/:user', (ctx, next) ->
		new MunPoem {name: ctx.params.user}

