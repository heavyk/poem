
class Mask #extends Verse
	(obj, states) ->
		if obj not instanceof Renderable then throw new Error "you must initialize your machina with a verse"
		@obj = obj
		@states <<< states

	render: (doc) ->
		throw new Error "undefined render func for object #{JSON.stringify doc}"

	states:
		loading: ->
			cE \div null, "loading"

		new: ->
			cE \div null, "TODO: you need to make a 'new' state render function"

		ready: ->
			cE \div null, "TODO: you need to make a 'ready' state render function"

		editing: ->
			cE \div null, "TODO: you need to make an 'editing' state render function"


class TODO_Mask extends Mask
	(obj, states) ->
		super ...

	render: (doc) ->
		throw new Error "undefined render func for object #{JSON.stringify doc}"

	states:
		new: ->
			cE \div null, "TODO: you need to make a 'new' state render function"

		ready: ->
			cE \div null, "TODO: you need to make a 'ready' state render function"

		editing: ->
			cE \div null, "TODO: you need to make an 'editing' state render function"

