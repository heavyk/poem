
#TODO list:
# === phase 1 ===
# save the resolve decision
# after completing each resolve, show the next in the chain of resolves
# pregenerate (fake) users for testing which will also vote on these resolves
# show textbox to create resolves
#  ability to create resolves
#  show last x recently created resolves right below
# show total number of votes on this resolve (and ability to see list of these people)
# tooltip below first resolve to help the person to know what to do
#
# === phase 2 ===
# calculate the proximity with others
#  this should be done on demand when showing other users
#  when saving a resolve, the user should update his/her last resolve date
#  proximity should save a calculation date and update if the user's resolve date is greater than the calc date
#   a crom job should go through the database and calculate out of date proximities when cpu usage is low
#
# === phase 3 ===
# ability to register users (use existing accounts ui)
# after registering, create your mun
#
# === phase 4 ===
# add resolve explanation
#  ability to edit resolve explanation with aloha editor (save each explanation revision)
#
# === phase 5 ===
# ability to define roles (explanation of each role)
#  ability to ask someone for a favor
#  ability to show availability
#
# === phase 6 ===
# comments / discussion
# related / linking
# offer resolve translation
# you could say it better like ... (and vote for, better said)

# few more ideas
# delusion is often a prerequisite to genius

# _observeUnordered
#		added: (obj) ->
#		changed: (obj, old_obj) ->
#		removed: (obj) ->

# rename: renderFunc -> renderEach
# if @render-list then set render = @list function
# else @render-one
# render -> 

belief_prox = (v) ->
	c = if v > 0 then 'prox-belief pos' else 'prox-belief neg'
	s = "width:#{if v > 0 then v*50 else -v*50}%" 
	cE 'div', {c: 'prox'},
		cE 'div', {c,s}

class Belief extends Verse
	(d) ~>
		# this should be by id
		super ...

	# TODO: renderFunc -> render
	renderFunc: ->
		return [
			cE 'div', null, "TODO: show resolve and belief"
			cE 'div', null, "TODO: show comments"
			cE 'div', null, "TODO: show crits"
		]

	model:
		mun:
			type: \uuid
			desc: "mun resonsible for the belief"
			default: -> Mun.id
		resolve:
			type: \uuid
			desc: "the resolve in question"
		v:
			type: \fraction
			desc: "the mun's alignment value to the belief"

	# duplicate me
	Renderable.setup_collection.call @
	# TODO: do this automatically in the collection_setup from the keys
	Poem.add '/belief/:id', (ctx, next) ->
		new Belief {_id: ctx.params.id}

class MyBeliefMask extends RenderableMask
	(d) ~>
		super ...

	render: (d) ->
		console.log "rendering!", {} <<< d
		#debugger
		slider = $(cE 'div', c: 'slider1').slider {
			min: -100
			max: 100
			step: 10
			animate: "fast"
			value: @v*100 || 0
			change: (event, ui) ->
				console.log "change", d
				d.v = v = ui.value / 100
				event.target.style.background =	if v < 0 then "rgba(160,0,0,#{-v})" else "rgba(0,140,0,#{v})"
				event.target.parentNode.previousSibling.style.fontWeight = if v < 0 then Math.round(-v*5) * 100 + 400 else 400
				event.target.parentNode.nextSibling.style.fontWeight = if v > 0 then Math.round(v*5) * 100 + 400 else 400
		}
		cE 'div', {c: 'row-fluid'},
			cE 'div', {c: 'span3 no'}, "No, no estoy de acuerdo..."
			cE 'div', {c: 'span6'}, slider
			cE 'div', {c: 'span3 si'}, "Si, estoy de acuerdo!"

class MyBelief extends Belief
	(d) ~>
		# this should be a list
		@mask = new MyBeliefMask @
		super ...

	model:
		mun:
			type: \uuid
			index: true
			desc: "my uuid"
		resolve:
			type: \uuid
			index: true
			desc: "the resolve in question"

	Renderable.setup_render.call @

class ResolveMask extends RenderableMask
	(d) ~>
		super ...

	render: (d) ->
		cE 'div', {c: "well resolve"}, [
			cE 'h1', {s: "padding-bottom: 11px"}, d.belief
			cE 'div', {c: 'resolve-body'}, ~>
				#new MyBelief resolve: @_id
				
				# add states for loading and stuff... set them accordingly
				# BUILD TEH WEBSITE, DUDE!
				/*
				cE 'div', {c: 'span2'},
						cE 'div', {c: 'mun'},
							new Mun {id: "kenny"}
					cE 'div', {c: 'span2 offset1'}, "No, no estoy de acuerdo..."
					cE 'div', {c: 'span5'}, slider
					cE 'div', {c: 'span2'}, "Si, estoy de acuerdo!"
					*/
			cE 'div', null, ~>
				cE 'div', {c: 'resolve-believers'}, "TODO"
				/*
				believers = ResolveBelief.find {resolve: @_id}
				return [
					@list 'resolve-beliefs', believers, (belief) ~>
						cE 'div', {c: 'mun-belief'}, [
							new Mun _id: belief.mun
							belief_prox belief.v
						]
				]*/
		]

class Resolve extends Verse
	(d) ~>
		console.log "new resolve", d
		super ...
		@mask = new ResolveMask @

	#fsm: null
	model:
		mun:
			type: \uuid
			required: true
			desc: "writer of this gem"
		featured:
			type: \string
			desc: "featured resolves list"
		belief:
			type: \string
			required: true
			desc: "what the mun has to say"

	Renderable.setup_collection.call @

class FeaturedResolveMask extends RenderableMask
	(d) ~>
		console.log "FeaturedResolveMask", d

	render: (d) ->
		console.log "FeaturedResolveMask.render", d
		cE 'div', {c: "well resolve"},
			cE 'h1', {s: "padding-bottom: 11px"}, d.belief
			cE 'div', {c: 'resolve-body'}, ->
				MyBelief resolve: d._id .on 'insert', ~>
					console.log "TODO: inserted a belief. show next"

class FeaturedResolves extends Resolve
	(d) ~>
		# this should be a list
		console.log "FeaturedResolves", d
		super ...
		@mask = new FeaturedResolveMask @

	model:
		mun:
			type: \uuid
			desc: "featured resolves for this mun"
		featured:
			index: true
			desc: "featured resolves list"
		belief:
			type: \string
			desc: "what the mun has to say"

	Renderable.setup_render.call @

# RIGHT NOW:
# abstract the fsm to allow for custom states
# make a new state where I enter the 'new' state
# the selector should always start with the first item.
# if there are no elements to be selected, make a new obj
#


class RealMun extends Poem
	(d) ~>
		console.log "entering the real man"
		console.log "d", d
		super ...

	render: (view, fn) ->
		cE 'div', {c: 'grid grid-pad'}, # <<< I don't like this
			col 9, 12, (el) ~>
				#headline_items = Resolve.find featured: 'headline'

				return [
					cE 'div', {c: 'headline create well'},
						cE 'h2', null, "write anything that comes to mind..."
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
						cE 'div', {c: 'input-append'},
							cE 'input', {c: 'input-xxlarge', type: 'text', name: 'belief', placeholder: 'It could be said that...'}
							cE 'button', {c: 'btn' type: 'submit'}, "Yep!"
						cE 'div', null, "TODO: slider"
					new FeaturedResolves featured: \headline
					#.on '_val:change', ->
					#	aC el, Resolve {id: 2, _view: 'headline', belief: "Eres Sincero?"}
				]
	Poem.add '/real-mun', (ctx, next) ->
		new RealMun {_id: '1234'} #name: ctx.params.user
/*

... this gets populated with the user data:
	new Mun {id: Meteor.userId!, view: "small"}

... this will be a published list:
for r in Resolve.find {feature: 'headline'} .sort {z:1}
	new Resolve {id: r.id, view: "headline"}

... all resolves that I have in common with another user
for r in Resolve.find {'$and': [ {mun: Meteor.userId!}, {mun: {'$not': Meteor.userId!}} ] }
	for rr in Resolve.find {mun: {'$not': Meteor.userId!}}

for u in Mun.find {}

------------------

multiple ideas:
 - your goal is to discover who you really are, and how others pretend to be
 - men are to have an image
 - women are to comment on the man's who they say they are, remaining anonymous
 - men will present themselves
 - you accountable and you are to keep others accountable
 - image is taboo on this site. we are to know the person for who they are, not for what they look like
 - women do not know what they want and men are trained to see (which is why image is taboo here)
 - women over time
*/
