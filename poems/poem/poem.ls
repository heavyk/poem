

class Menu extends Verse
	(d) ~>
		# if finding more than one, save them as variations and alert the user
		#verse = Menu._collection.findOne d
		#console.log "we found:", d, verse
		super ...#verse.toObject!
			
	renderFunc: (view, fn) ->
		#Meteor.defer ~>
		cE 'div', {},
			cE 'h2', null, "poem"
			cE 'div', {c:'tagline'}, "creative programming"
			cE 'div', null, (el) ~>
				if Meteor.userId!
					Mun.current = Session.get 'mun'
					user = Mun.find {}
					@list 'user-muns', user, (uu) ->
						if !Mun.id
							Session.set 'mun', uu
							Mun.id = uu._id
						if uu._id is Mun.id
							cE 'div', null, ->
								return [
									new Mun uu <<< {_view: 'very small'}
									cE 'a', {
										c: 'logout'
										href: '/logout'
										onclick: ->
											Meteor.logout ->
												Session.set 'mun', null
												Meteor._reload.reload!
											return false
									}, "logout"
								]
				else
					cE 'a', {
						c: 'login'
						onclick: ->
							console.log "login hamsternipples"
							Meteor.loginWithPassword 'hamsternipples', 'lala', ->
								console.log "TODO: logged in feedback!"
								dialog_el = $(cE 'div', null, "hello hamsternipples").dialog {
									buttons:
										ok: ->
											dialog_el.dialog 'close'
											Meteor._reload.reload!
								}
					}, 'login'
			cE 'ul', {c: 'nav nav-list'}, ~>
				menu_items = Poem.find featured: 'client/menu'
				featured_items = Poem.find featured: 'client/featured'
				suggested_items = Poem.find featured: 'client/suggested'
				return [
					@list "poem-menu", menu_items, (poem) ->
						cE 'li', {},
							cE 'a', {href: "/#{poem.name}" data: menu: "poem-#{poem.name}"},
								cE 'i', {c: "icon-#{poem.icon}"}
								' ', poem.title
					cE 'li', {c: 'nav-header'}, "featured"
					@list "poem-menu", featured_items, (poem) ->
						cE 'li', {},
							cE 'a', {href: "/#{poem.name}" data: menu: "poem-#{poem.name}"},
								cE 'i', {c: "icon-#{poem.icon}"}
								' ', poem.title
					cE 'li', {c: 'nav-header'}, "you might also like"
					@list "poem-menu", suggested_items, (poem) ->
						cE 'li', {},
							cE 'a', {href: "/#{poem.name}" data: menu: "poem-#{poem.name}"},
								cE 'i', {c: "icon-#{poem.icon}"}
								' ', poem.title
				]

	if Meteor.isServer
		publish "poem-menu", (featured) ->
			Poem.find {featured}
