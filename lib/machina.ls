# conversion by kenny
# original: https://github.com/ifandelse/machina.js

slice = [].slice
NEXT_TRANSITION = 'transition'
NEXT_HANDLER = 'handler'
HANDLING = 'handling'
HANDLED = 'handled'
NO_HANDLER = 'nohandler'
TRANSITION = 'transition'
INVALID_STATE = 'invalidstate'
DEFERRED = 'deferred'
NEW_FSM = 'newfsm'
utils = {
	makeFsmNamespace: (->
		machinaCount = 0
		-> 'fsm.' + machinaCount++)!
	getDefaultOptions: ->
		{
			initialState: 'uninitialized'
			eventListeners: {'*': []}
			states: {}
			eventQueue: []
			namespace: utils.makeFsmNamespace!
		}
}

class Fsm
	(options) ->
		opt = void
		initialState = void
		defaults = utils.getDefaultOptions!
		if options
			@eventListeners = _.extend {}, options.eventListeners if options.eventListeners
			if options.messaging then options.messaging = _.extend {}, defaults.messaging, options.messaging
		opt = _.extend defaults, options || {}
		initialState = opt.initialState
		delete opt.initialState
		_.extend this, opt
		@targetReplayState = ''
		@state = undefined
		@priorState = undefined
		@_priorAction = ''
		@_currentAction = ''
		if initialState then @transition initialState
		#machina.fireEvent NEW_FSM, this
		#Machina.emit 'new', this

	fireEvent: (eventName) ~>
		args = arguments
		_.each @eventListeners.'*', (callback) ->
			try
				callback.apply this, slice.call args, 0
			catch exception
				console.log exception.toString! if console && typeof console.log isnt 'undefined'
		console.log "fireEvent", eventName, args
		if list = @eventListeners[eventName]
			doListener = (callback) ~>
				try
					callback.apply this, slice.call args, 1
				catch exception
					console.log exception.toString! if console && typeof console.log isnt 'undefined'
			Meteor.setTimeout ->
				if typeof list is \function then doListener list
				else _.each list, doListener
			, 0
	
	handle: (msgType) ~>
		states = @states
		current = @state
		args = slice.call arguments, 0
		handlerName = void
		@currentActionArgs = args
		if states[current] && (states[current][msgType] || states[current].'*')
			handlerName = if states[current][msgType] then msgType else '*'
			@_currentAction = current + '.' + handlerName
			@fireEvent.apply this, [HANDLING].concat args
			states[current][handlerName].apply this, args.slice 1
			@fireEvent.apply this, [HANDLED].concat args
			@_priorAction = @_currentAction
			@_currentAction = ''
			@processQueue NEXT_HANDLER
		else
			@fireEvent.apply this, [NO_HANDLER].concat args
		@currentActionArgs = arguments
	
	transition: (newState) ~>
		oldState = void
		if @states[newState]
			@targetReplayState = newState
			@priorState = @state
			@state = newState
			oldState = @priorState
			@fireEvent.apply this, [
				TRANSITION
				oldState
				newState
			]
			@states[oldState]._onExit.call this if oldState and @states[oldState]._onExit
			@states[newState]._onEnter.call this if @states[newState]._onEnter
			if @targetReplayState is newState then @processQueue NEXT_TRANSITION
			return 
		throw new Error "#{@obj?displayName} #{@state}->#{newState} error: '#{newState}' not defined"
		@fireEvent.apply this, [
			INVALID_STATE
			@state
			newState
		]
	
	processQueue: (type) ->
		filterFn = void
		if type is NEXT_TRANSITION
			filterFn = (item) -> item.type is NEXT_TRANSITION && (not item.untilState || item.untilState is @state)
		else
			filterFn = (item) -> item.type is NEXT_HANDLER
		toProcess = _.filter @eventQueue, filterFn, this
		@eventQueue = _.difference @eventQueue, toProcess
		_.each toProcess, ((item) -> @handle.apply this, item.args), this
	
	clearQueue: (type, name) ->
		filter = void
		if type is NEXT_TRANSITION
			filter = (evnt) -> evnt.type is NEXT_TRANSITION && if name then evnt.untilState is name else true
		else
			if type is NEXT_HANDLER then filter = (evnt) -> evnt.type is NEXT_HANDLER
		@eventQueue = _.filter @eventQueue, filter
	
	deferUntilTransition: (stateName) ->
		if @currentActionArgs
			queued = {
				type: NEXT_TRANSITION
				untilState: stateName
				args: @currentActionArgs
			}
			@eventQueue.push queued
			@fireEvent.apply this, [
				DEFERRED
				@state
				queued
			]
	
	deferUntilNextHandler: ->
		if @currentActionArgs
			queued = {
				type: NEXT_TRANSITION
				args: @currentActionArgs
			}
			@eventQueue.push queued
			@fireEvent.apply this, [
				DEFERRED
				@state
				queued
			]
	
	on: (eventName, callback) ~>
		@eventListeners[eventName] = [] if not @eventListeners[eventName]
		@eventListeners[eventName].push callback
	off: (eventName, callback) ~>
		@eventListeners[eventName] = _.without @eventListeners[eventName], callback if @eventListeners[eventName]

machina = {
	Fsm: Fsm
	bus: undefined
	utils: utils
	on: (eventName, callback) ->
		@eventListeners[eventName] = [] if not @eventListeners[eventName]
		@eventListeners[eventName].push callback
	off: (eventName, callback) ->
		@eventListeners[eventName] = _.without @eventListeners[eventName], callback if @eventListeners[eventName]
	fireEvent: (eventName) ->
		i = 0
		len = void
		args = arguments
		listeners = @eventListeners[eventName]
		_.each listeners, (callback) -> callback.apply null, slice.call args, 1 if listeners && listeners.length
	eventListeners: {newFsm: []}
}
#global.machina = machina
#machina


# ==================================
# ==================================
# ==================================


# Machina states:
# (uninitialized)
# (loading)
#  [loaded] -> if obj._dd \ready else \new
# new
#  [save] -> saving
# ready
#  [remove] -> unloading
#  [loaded] -> saving
# editing
#  [save] -> saving
# saving
#  [saved] -> ready



class Machina #extends Verse
	func: 'none'
	(obj, fsm) ~>
		if obj not instanceof Renderable then throw new Error "you must initialize your machina with a verse"
		#@obj = obj
		@fsm = new Fsm deep_extend {obj}, @@fsm, fsm

	transition: ~> @fsm.transition ...
	emit: ~> @fsm.fireEvent ...
	on: ~> @fsm.on ...
	off: ~> @fsm.off ...

	#default state machine
	@fsm =
		eventListeners:
			# -------- called from observe -------
			added: (doc, idx) ->
				if idx >= @obj._dd.length
					@obj._dd.push doc
				else
					@obj._dd.splice idx, 0, doc
				console.log "evt.added", idx, doc
			changed: (doc, idx, old_doc) ~>
				# TODO: add is.dirty field
				# TODO: do insert/update on a timeout
				for own k, v of doc
					if typeof v is not \undefined and !_.isEqual old_doc[k], v
						@obj._dd[idx][k] = v
						#amplify.publish "#{@_prefix}_#{doc._id}.#{k}", v
				console.log "evt.changed", arguments
			moved: (doc, idx, new_idx) ~>
				#if cn = list.childNodes[idx+offset]
				#	list.removeChild cn
				#	aC list, cn, new_idx
				oo = @obj._dd.splice idx, 1 .0
				@obj._dd.splice new_idx, 1, oo
				console.log "evt.moved", arguments
			removed: (doc, idx) ~>
				@obj._dd.splice idx, 0
				#if cn = list.childNodes[idx+offset]
				#	list.removeChild cn
				console.log "evt.removed", arguments
			# --------- end observe calls --------
			save: (doc) ->
				console.log "TODO!!! evt.save"
			saved: (doc) ->
				console.log "TODO!!!! evt.saved", doc
			remove: ->
				console.log "TODO!!! evt.remove"

		states:
			uninitialized:
				_onEnter: ->
					#@obj._state = 'loading'
					@transition \loading
					console.log "TODO!!! load obj from db"

			loading:
				_onEnter: ->
					console.log "Machina.state:loading" @obj
					#throw new Error

			ready:
				_onEnter: ->
					console.warn "now ready state", @obj, @obj.skip!, @obj.limit!, @obj._dd
					@obj._state = 'ready'
					els = []
					for i til 1#@limit!
						doc = @obj._dd[i]
						unless doc then break
						if @obj.mask
							els.push @obj.mask.render doc #@obj._new
					#@render els
					$ @obj._el .empty!
					if els.length
						aC @obj._el, els
						@transition \ready
					else
						@transition \new
					console.log "docs", @obj._dd, els

				'*': ->
					console.log "an event in the ready state"

				# these events should modify _dd and also send a message over to the mask
				added: (doc, idx) ~>
					#@_dd.splice idx, 0, doc
					console.log "ready.added", idx, doc
				changed: (doc, idx, old_doc) ~>
					# TODO: add is.dirty field
					# TODO: do insert/update on a timeout
					#for own k, v of doc
					#	if !_.isEqual old_doc[k], v
					#		@_dd[idx][k] = v
					#		amplify.publish "#{@_prefix}_#{doc._id}.#{k}", v
					console.log "ready.changed", arguments
				moved: (doc, idx, new_idx) ~>
					#if cn = list.childNodes[idx+offset]
					#	list.removeChild cn
					#	aC list, cn, new_idx
					oo = @_dd.splice idx, 1 .0
					@_dd.splice new_idx, 1, oo
					console.log "ready.moved", arguments
				removed: (doc, idx) ~>
					@_dd.splice idx, 0
					#if cn = list.childNodes[idx+offset]
					#	list.removeChild cn
					#console.log "ready.removed", arguments
			new:
				_onEnter: (doc = {}) ->
					console.log "now in new state", arguments
					if @obj.mask
						#TODO: add option to only insert when save is called ...
						#Renderable.def_model doc, @obj.model, doc, @obj
						console.log "rendering", @obj.model, @obj.selector
						aC @obj._el, @obj.mask.render @obj._new

				added: (doc, idx) ->
					@transition \ready
				
				save: (doc) ->
					delete doc._id
					id = @obj.model["model.collection"].insert {} <<< doc
					console.log "new.save",{} <<< doc
					console.log "new.save",id, doc, @obj.model
					doc._id = @obj._id = id
					@fireEvent \saved doc
					#TODO: @save!
				error: (err) ->
					console.log "new.err", err
				sync: ->
					console.log "new.save", @
					@fireEvent \save doc

# SingleObjMachina states:
# (uninitialized)
# (loading)
#  [loaded] -> if obj._dd.length \ready else \new
# new
#  [save] -> saving
# ready
#  [remove] -> unloading
#  [loaded] -> saving
# editing
#  [save] -> saving
# saving
#  [saved] -> ready

class SingleObjMachina extends Machina
	(obj, fsm) ~> super obj, (deep_extend {}, @@fsm, fsm)
	@fsm =
		states:
			loading:
				_onEnter: ->
					console.log "SingleObjMachina.state:loading" @

			loaded:
				_onEnter: ->
					switch @obj._dd.length
					| 0 => @transition \new
					| 1 => @transition \ready
					| _ => throw new Error "there was an error for some reason... multiple objects found in a SingleObjMachina"

			ready:
				_onEnter: ->
					#@obj._state = 'ready'
					if @obj.mask
						doc = @obj._dd[0]
						$ @obj._el .empty!
						aC @obj._el, @obj.mask.render doc
					else throw new Error "mask must implement"

				'*': ->
					console.log "an event in the ready state", arguments

				changed: (doc, idx, old_doc) ~>
					for own k, v of doc
						if !_.isEqual old_doc[k], v
							@_dd[0][k] = v
							#amplify.publish "#{@_prefix}_#{doc._id}.#{k}", v
					console.log "TODO!!! (rerender) ready.changed", arguments
				
				removed: ->
					@transition \unloading
					#if cn = list.childNodes[idx+offset]
					#	list.removeChild cn
					console.log "TODO!!! loaded.removed", arguments

			new:
				_onEnter: (doc = {}) ->
					console.log "now in new state", arguments
					if @obj.mask[@state]
						console.log "rendering", @obj.model, @obj.selector
						aC @obj._el, @obj.mask.new @obj._new
					else console.warn ""

				added: (doc, idx) ->
					@transition \loaded
				
				save: (doc) ->
					delete doc._id
					id = @obj.model["model.collection"].insert {} <<< doc
					console.log "new.save",{} <<< doc
					console.log "new.save",id, doc, @obj.model
					doc._id = @obj._id = id
					@fireEvent \saved doc
					#TODO: @save!
				error: (err) ->
					console.log "new.err", err
				sync: ->
					console.log "new.save", @
					@fireEvent \save doc

# SingleObjMachina states:
# (uninitialized)
# (loading)
#  [loaded] -> if obj._dd.length \ready else \new
# new
#  [save] -> saving
# ready
#  [remove] -> unloading
#  [loaded] -> saving
# editing
#  [save] -> saving
# saving
#  [saved] -> ready

class OrderedListMachina extends Machina
	(obj, fsm) ~> super obj, (deep_extend {}, @@fsm, fsm)
	@fsm =
		states:
			loaded:
				_onEnter: ->
					switch @obj._dd.length
					| 0 => @transition \new
					| _ => @transition \ready

			ready:
				_onEnter: ->
					#@obj._state = 'ready'
					if @obj.mask
						els = []
						for i til @obj.limit!
							doc = @obj._dd[i]
							unless doc then break
							if @obj.mask
								els.push @obj.mask.render doc #@obj._new
						#@render els
						$ @obj._el .empty!
						if els.length
							aC @obj._el, els
					else throw new Error "mask must implement"

				'*': ->
					console.log "an event in the ready state", arguments

				changed: (doc, idx, old_doc) ~>
					for own k, v of doc
						if !_.isEqual old_doc[k], v
							@_dd[0][k] = v
							#amplify.publish "#{@_prefix}_#{doc._id}.#{k}", v
					console.log "TODO!!! (rerender) ready.changed", arguments
				
				removed: ->
					@transition \unloading
					#if cn = list.childNodes[idx+offset]
					#	list.removeChild cn
					console.log "TODO!!! loaded.removed", arguments

			new:
				_onEnter: (doc = {}) ->
					console.log "now in new state", arguments
					if @obj.mask[@state]
						console.log "rendering", @obj.model, @obj.selector
						aC @obj._el, @obj.mask.new @obj._new
					else console.warn ""

				added: (doc, idx) ->
					@transition \loaded
				
				save: (doc) ->
					delete doc._id
					id = @obj.model["model.collection"].insert {} <<< doc
					console.log "new.save",{} <<< doc
					console.log "new.save",id, doc, @obj.model
					doc._id = @obj._id = id
					@fireEvent \saved doc
					#TODO: @save!
				error: (err) ->
					console.log "new.err", err
				sync: ->
					console.log "new.save", @
					@fireEvent \save doc

