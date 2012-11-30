


Meteor.startup ->
	
	hamsternipples = Mun._collection.findOrInsert {
		name: "hamsternipples"
	}, {
		real_name: "Kenny Bentley"
		dob: new Date('May 28, 1983 06:06:00 -7:00')
	}

	real_man = Mun._collection.findOrInsert {
		name: "real_nam"
	}, {
		real_name: "Kenny Bentley"
		dob: new Date('May 28, 1983 06:06:00 -7:00')
	}

	#if Acc
	if !hn = Meteor.users.findOne {username: "hamsternipples"}
		hn = Accounts.createUser {
			username: "hamsternipples"
			email: "kenny@gatunes.com"
			password: "lala"
			profile:
				name: "Kenny Bentley"
				dob: new Date('May 28, 1983 06:06:00 -7:00')
		}
		Meteor.users.update {username: 'hamsternipples'}, {'$set': mun: hamsternipples, muns: [hamsternipples, real_man]}

	#console.log hamsternipples
	#console.log hn
	#@setUserId hamsternipples._id

	Belief._collection.allow {
		insert: (uuid, doc) ->
			console.log "ResolveBelief.insert", uuid, doc
			if uuid then true else false
		update: (uuid, docs, fields, modifier) ->
			console.log "ResolveBelief.update", uuid, docs
			return true
		remove: (uuid, docs) ->
			console.log "ResolveBelief.remove", uuid, docs
			if uuid then true else false
		#fetch: ['mun']
	}

	Resolve._collection.allow {
		insert: (uuid, doc) ->
			console.log "Resolve.insert", uuid, doc
			if uuid then true else false
		update: (uuid, docs, fields, modifier) ->
			console.log "Resolve.update", uuid, docs
			return true
		remove: (uuid, docs) ->
			console.log "Resolve.remove", uuid, docs
			if uuid then true else false
		#fetch: ['mun']
	}

	r1 = Resolve._collection.findOrInsert {
		belief: "¿Crees que te conoces?"
	}, {
		featured: 'headline'
		mun: hamsternipples
	}

	r2 = Resolve._collection.findOrInsert {
		belief: "¿Eres sincero?"
	}, {
		parent: r1
		mun: hamsternipples
	}

	r3 = Resolve._collection.findOrInsert {
		belief: "¿dices lo que quiere oir la otra persona?"
	}, {
		parent: r2
		mun: hamsternipples
	}

	r4 = Resolve._collection.findOrInsert {
		belief: "¿Mientes?"
	}, {
		parent: r3
		mun: hamsternipples
	}

	todo1 = TodoTask._collection.findOrInsert {
		desc: "something important"
	}, {
		status: "not started"
		mun: hamsternipples
	}

	todo1 = TodoTask._collection.findOrInsert {
		desc: "something more important"
	}, {
		status: "not started"
		mun: hamsternipples
	}

	todo1 = TodoTask._collection.findOrInsert {
		desc: "something even more important"
	}, {
		status: "not started"
		mun: hamsternipples
	}

	

	home = Poem._collection.findOrInsert {
		name: \home
	}, {
		featured: 'client/menu'
		version: '0.0.0'
		icon: 'home'
		title: "Home"
		description: "a newer way to open your mind"
		tagline: "poetic programming"
		# TODO: move the client side functions over to the  render: ->
		fn: """
		cE 'div', {c: 'splash'},
			cE 'p', {c: 'new-poem'}
				cE 'button', {c: 'btn btn-large btn-primary'}, "New Poem"
			cE 'p', {c: 'load-poem'}
				cE 'button', {c: 'btn btn-large'}, "Load"
			cE 'p', {c: 'tutorial'}
				cE 'button', {c: 'btn btn-large'}, "Tutorial"
			cE 'div', 0
				cE 'div', {c: 'span6', 'data-editor': 'ace', style: "height:400px"}, "a good editor"
			->
				r = []
				console.log poem
				poems = Poem.find {}
				poems.forEach (p) ->
					console.log "p", p
				Meteor.setTimeout ->
					Meteor.flush!
					els = $ '[data-editor*=]'
					require ["vfs-socket/consumer", "ace", "tty", "ace/mode/ls"], (consumer, ace, tty, ls_mode) ->
						for el in els
							editor = ace.edit el
							session = editor.getSession!
							console.log editor, session
							session.setMode new ls_mode.Mode
							session.setTabSize 2
				, 20
				r.join ''
		"""
		tpl_sidebar: "TODO"
	}


	library = Poem._collection.findOrInsert {
		name: \library
	}, {
		featured: 'client/menu'
		version: '0.0.0'
		icon: 'book'
		title: "Library"
		description: "a list of all of your media files"
		tagline: "gimme everything you got!"
		tpl_head: "<title>Library - [TODO]</title>"
		tpl_body: "<h1>Library</h1><h6>gimme everything you got!</h6>"
	}

	poem = Poem._collection.findOrInsert {
		name: \poem
	}, {
		featured: 'client/menu'
		version: '0.0.0'
		icon: 'italic'
		title: "Create"
		description: "a new way to open your mind"
		tagline: "poetic programming"
		tpl_head: "<title>poem ([TODO]): clever poetry</title>"
		tpl_body: "<h1>Poem</h1><h6>clever programming</h6><h4>Principals</h4><p>poem is a new way to program. it thinks from the creative side of your brain</p>"
	}

	poem = Poem._collection.findOrInsert {
		name: \discover
	}, {
		featured: 'client/menu'
		version: '0.0.0'
		icon: 'globe'
		title: "Discover"
		description: "a new way to open your mind."
		tagline: "poetic programming"
		tpl_head: "<title>poem ([TODO]): clever poetry</title>"
		tpl_body: "<h1>Poem</h1><h6>clever programming</h6><h4>Principals</h4><p>poem is a new way to program. it thinks from the creative side of your brain</p>"
	}

	eapp = Poem._collection.findOrInsert {
		name: \eapp
	}, {
		featured: 'client/suggested'
		version: '0.0.0'
		icon: 'warning-sign'
		title: "Aditivos application"
		description: "a first attempt to create an application about the dangers of aditivos"
		tagline: "they're killin' ya!"
		tpl_head: "<title>aditivos: they're killin' ya!</title>"
		tpl_body: "<h1>Aditivos application</h1><h6>they're killin' ya!</h6>"
	}

	vulcrum = Poem._collection.findOrInsert {
		name: \vulcrums-lare
	}, {
		featured: 'client/featured'
		version: '0.0.0'
		icon: 'fire'
		title: "Vulcrum's Lare"
		description: "A first alchemical mix of programming and gold: The Philosopher's Tome"
		tagline: "imagination becomes reality in vulcan's lair"
		tpl_head: "<title>Vulcrum's Lare</title>"
		tpl_body: "<h1>Vulcrum's Lair</h1><h6>where imagination becomes reality</h6>"
	}

	eapp = Poem._collection.findOrInsert {
		name: \open-mind
	}, {
		featured: 'client/featured'
		version: '0.0.0'
		icon: 'unlock'
		title: "Open Mind"
		description: "open your mind up with a headset"
		tagline: "mind blowing!"
	}

	eapp = Poem._collection.findOrInsert {
		name: \real-mun
	}, {
		featured: 'client/featured'
		version: '0.0.0'
		icon: 'comments-alt'
		title: "Kilgore's Trout"
		description: "untitled"
		tagline: "untitled"
	}

	eapp = Poem._collection.findOrInsert {
		name: \binaural
	}, {
		featured: 'client/featured'
		version: '0.0.0'
		icon: 'headphones'
		title: "Binaral Frequencies"
		description: "build your own binaural beats"
		tagline: "mind blowing!"
	}

	eapp = Poem._collection.findOrInsert {
		name: \timeline
	}, {
		featured: 'client/featured2'
		version: '0.0.0'
		icon: 'time'
		title: "Timeline"
		description: "look through any section of history, find paralles and watch history's interaction with the stars"
		tagline: "mind blowing!"
	}

	eapp = Poem._collection.findOrInsert {
		name: \playbox
	}, {
		featured: 'client/suggested'
		version: '0.0.0'
		icon: 'music'
		title: "playbox"
		description: "social media player"
		tagline: "mind blowing!"
	}
