String::replace_all = (f, r) ->
	str = @
	until str.indexOf f is -1
		str = str.replace f, r
	str

/*
cE = (el, opts) ->
	ret = "<#{el}"
	console.log el, opts
	while typeof opts is \function
		opts = opts!
	if typeof opts is \object
		#ret += ' '
		for id, val of opts
			if id is \c then id = \class
			ret += " #{id}=\"#{val.toString!.replace_all '"', '\\"'}\""

	len = arguments.length
	if len > 2
		ret += '>'
		for i from 2 til len
			d = @@[i]
			switch typeof d
			case \function then ret += d!
			default then ret += d
		ret += "</#{el}>"
	else
		ret += '/>'
	return ret
*/
