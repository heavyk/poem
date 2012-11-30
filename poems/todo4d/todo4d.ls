/*
class TodoTask extends Verse
	(d) ~>
		console.log "new resolve", d
		super ...
		@mask = new ResolveMask @


	model:
		mun:
			type: \uuid
			required: true
			desc: "writer of this todo"
		desc:
			type: \string
			desc: "task description"
		status:
			type: \string
			desc: "current task status"
		hours:
			type: \number
			default: 0.5
			desc: "hourly time estimation"

	Renderable.setup_collection.call @

class TodoTaskMask extends RenderableMask
	(d) ~>
		console.log "FeaturedResolveMask", d

	render: (d) ->
		console.log "FeaturedResolveMask.render", d
		cE \div, {c: "well resolve"},
			cE 'h1', {s: "padding-bottom: 11px"}, d.belief
			cE \div, {c: 'resolve-body'}, ->
				#MyBelief resolve: d._id .on 'insert', ~>
				console.log "TODO: inserted a belief. show next"


class TaskList extends TodoTask
	(d) ~>
		# this should be a list
		console.log "TaskList", d
		super ...
		@mask = new TodoTaskMask @

	model:
		mun:
			type: \uuid
			index: true
			desc: "task list for this mun"
		desc:
			type: \string
		status:
			type: \string

	Renderable.setup_render.call @
*/

class TodoItemMask extends Mask
	(obj, states) ->
		super ...

	render: (d) ->
		#throw new Error "undefined render func for object #{JSON.stringify doc}"
		#cE \div, null, JSON.stringify doc
		cE \div, {c: "well resolve"},
			cE \h3, {s: "padding-bottom: 11px"}, d.desc
			cE \div, {c: 'resolve-body'}, ->
				cE \h6 c: 'status', d.status

	states:
		new: ->
			cE \div null, "TODO: you need to make a 'new' state render function"

		ready: ->
			cE \div null, "TODO: you need to make a 'ready' state render function"

		editing: ->
			cE \div null, "TODO: you need to make an 'editing' state render function"



class TodoTask extends Verse
	#~> super ...
	mask: TodoItemMask
	machina: SingleObjMachina
	model:
		mun:
			type: \uuid
			required: true
			desc: "writer of this todo"
		desc:
			type: \string
			desc: "task description"
		status:
			type: \string
			desc: "current task status"
		hours:
			type: \number
			#BUG: defaults are treated like "required fields" !!!
			#BUG: while, I'm thinking about it.. I should be deep_extending the models
			#default: 0.5 
			desc: "hourly time estimation"
	Renderable.setup_collection.call @

#BUG: TodoTaskList.find will search the whole collection, and not merge the selectors
class TodoTaskList extends TodoTask
	mask: TodoItemMask
	machina: OrderedListMachina
	model:
		mun:
			type: \uuid
			index: true
			desc: "task list for this mun"
		desc:
			type: \string
		status:
			type: \string
	Renderable.setup_render.call @


class Todo4D extends Poem
	(d) ~>
		super ...

	render: (view, fn) ->
		cE \div, {c: 'grid grid-pad'}, # <<< I don't like this
			col 9, 12, (el) ~>
				console.log "TODOS FOR", Mun.id
				return [
					cE \div, {c: 'headline create well'},
						cE 'h2', null, "I need to..."
						cE 'form', {
							c:'form-inline'
							onsubmit: (evt) ->
								console.log arguments
								vals = {}
								for e in evt.target
									console.log e
									switch e.type
									| "text" =>
										vals[e.name] = e.value
									| otherwise =>
										console.error "TODO: form element not supported", e

								console.log "making new", vals
								Resolve.insert vals
								return false
						},
							cE \div, {c: 'input-append'},
								cE 'input', {c: 'input-xlarge', type: 'text', name: 'belief', placeholder: 'example: Be Awesome'}
								cE 'button', {c: 'btn' type: 'submit'}, "Do it!"
							cE \div c: 'row-fluid',
								cE \h4 null "status"
								cE \div c: 'input-append',
									cE \input c: 'span3' type: 'text' value: 0.5
									cE \span c: 'add-on', "hours"
								cE \div c: 'input-append',
									cE \input c: 'span3' type: 'text'
									cE \span c: 'add-on', "days"
							cE \br
								cE \input c: 'span6' name: 'status' type: 'text', placeholder: 'status...'
					#new TodoTask _id: "e06c7a69-1261-4788-bf86-828f5839af6d"
					new TodoTaskList mun: Mun.id
				]
	Poem.add '/todo4d', (ctx, next) ->
		new Todo4D {_id: '1234'} #name: ctx.params.user

#TODO:
# task list
# estimated time for each task
# time categories (work, spare time, etc.)
# visualizer of TODOs over time
