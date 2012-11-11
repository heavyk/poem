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

	fireEvent: (eventName) ->
		args = arguments
		_.each @eventListeners.'*', (callback) ->
			try
				callback.apply this, slice.call args, 0
			catch exception
				console.log exception.toString! if console && typeof console.log isnt 'undefined'
		if @eventListeners[eventName]
			_.each @eventListeners[eventName], (callback) ->
				try
					callback.apply this, slice.call args, 1
				catch exception
					console.log exception.toString! if console && typeof console.log isnt 'undefined'
	
	handle: (msgType) ->
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
	
	transition: (newState) ->
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
			@states[oldState]._onExit.call this if @states[oldState]?_onExit
			@states[newState]._onEnter.call this if @states[newState]._onEnter
			if @targetReplayState is newState then @processQueue NEXT_TRANSITION
			return 
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
	
	on: (eventName, callback) ->
		@eventListeners[eventName] = [] if not @eventListeners[eventName]
		@eventListeners[eventName].push callback
	off: (eventName, callback) ->
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
