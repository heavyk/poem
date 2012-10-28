
/*
upsampling filters
http://www.earlevel.com/main/2010/12/11/a-closer-look-at-upsampling-filters/

switch (irType) {
	default:
	case "none":
		var coefs = [ 1.0 ];			// no interpolation
		break;
	case "zoh":
		var coefs = [ 1.0, 1.0 ];		// zero-order hold
		break;
	case "linear":
		var coefs = [ 0.5, 1.0, 0.5 ];	// linear
		break;
	case "sinc 1":
		var coefs = [ -0.00004032787096706525,0,0.0007920116403661329,0,-0.0040181863877435135,0,0.013232838626812462,0,-0.03441026074262933,0,0.07862928971185519,0,-0.17894257012285258,0,0.6247646537513802,0.9999851027875566,0.6247646537513802,0,-0.17894257012285258,0,0.07862928971185519,0,-0.03441026074262933,0,0.013232838626812462,0,-0.0040181863877435135,0,0.0007920116403661329,0,-0.00004032787096706525 ];
		break;
	case "sinc 2":
		var coefs = [-0.000223155103289621,0.0003247356502056869,0.002380083574542235,0.0027438534027862437,-0.0037062150882656553,-0.01330554064114003,-0.009350354982381237,0.018030953203899643,0.04387884723366638,0.019523380919769573,-0.06308669540223802,-0.1208131753539901,-0.029268372751344085,0.24355509271425682,0.5593570762152679,0.6999189728165084,0.5593570762152679,0.24355509271425682,-0.029268372751344085,-0.1208131753539901,-0.06308669540223802,0.019523380919769573,0.04387884723366638,0.018030953203899643,-0.009350354982381237,-0.01330554064114003,-0.0037062150882656553,0.0027438534027862437,0.002380083574542235,0.0003247356502056869,-0.000223155103289621 ];
		break;
	case "sinc 3":
		var coefs = [ 0.000013982738421036122,0.00003417348318904143,-0.00003764100101012808,-0.0001527896644241927,-0.000015895815917497444,0.000370938970103814,0.0003088857515219192,-0.0005643369112154606,-0.0010055286039766232,0.0003882378973523975,0.002082789124162701,0.0006793822397940184,-0.0030932614643256304,-0.00308104296445819,0.0030388323261787502,0.006724708875382101,-0.0005483107467958783,-0.010504114036064527,-0.005533903255275947,0.012091846641057785,0.015243191772241356,-0.008288444866135194,-0.02659484993886801,-0.003989779910778763,0.03510475757898855,0.026329950381553464,-0.033954239808363346,-0.0575922965125618,0.014370412875668459,0.0934573220760928,0.03608228157111943,-0.1271481305821821,-0.14995942055286846,0.15124582145939883,0.6144968487333189,0.8399992442793526,0.6144968487333189,0.15124582145939883,-0.14995942055286846,-0.1271481305821821,0.03608228157111943,0.0934573220760928,0.014370412875668459,-0.0575922965125618,-0.033954239808363346,0.026329950381553464,0.03510475757898855,-0.003989779910778763,-0.02659484993886801,-0.008288444866135194,0.015243191772241356,0.012091846641057785,-0.005533903255275947,-0.010504114036064527,-0.0005483107467958783,0.006724708875382101,0.0030388323261787502,-0.00308104296445819,-0.0030932614643256304,0.0006793822397940184,0.002082789124162701,0.0003882378973523975,-0.0010055286039766232,-0.0005643369112154606,0.0003088857515219192,0.000370938970103814,-0.000015895815917497444,-0.0001527896644241927,-0.00003764100101012808,0.00003417348318904143,0.000013982738421036122 ];
		break;
}

var coefsLen = coefs.length;
var sigBaseIdx = 0;
var outIdx = 0;
for (var idx = 0; idx < sigLen; idx++) {
	coefsIdx = coefsLen;
	sigIdx = sigBaseIdx++;
	var acc0 = 0;
	var acc1 = 0;
	while (coefsIdx) {
		acc1 += signal[sigIdx] * coefs[--coefsIdx];
		if (coefsIdx)
			acc0 += signal[sigIdx++] * coefs[--coefsIdx];
	}
	signal2[outIdx++] = acc0;
	signal2[outIdx++] = acc1;
}
*/

/*

function interpolate(y0:int, y1:int, numSamples:uint):ByteArray {
    var b:ByteArray = new ByteArray();
    b.endian = Endian.LITTLE_ENDIAN;
    var m:Number = Math.round((y1-y0)/numSamples);
    for(var i:uint=0; i<numSamples; i++) {
        var n:int = m * i + y0;
        b.writeShort(n);
    }
    b.position = 0;
    return 0;
}

// upsample by factor of l
var n1:int = 0;
while(originalWavData.bytesAvailable > 1) {
    var sample:int = originalWavData.readShort();
    upsampleData.writeBytes(interpolate(n1, sample, (l-1)));
    n1 = sample;
}

// downsample by factor of m
while(upsampleData.bytesAvailable > 1) {
    downsampleData.writeShort(upsampleData.readShort());
    upsampleData.position += ((m-1)*2);
}

*/

convert = (signal, max) ->
	signal2 = new Float32Array signal.length
	for i from 0 til signal.length
		signal2[i] = signal[i] / max
	return signal2

upsample = (signal, signal2, method = "linear") ->
	#signal2 = new Float32Array new_len
	inc = signal2.length / (signal.length-1)
	ii = 0
	jj = 0
	signal2[0] = signal[0]
	for i from 1 til signal.length
		jj += inc
		kk = Math.round jj
		dist = kk - ii
		for k from 0 til dist
			#console.log ii+k, ii, jj, k
			signal2[ii+k] = signal[i-1] + (signal[i] - signal[i-1]) * (k / (dist-1))
		ii = kk
	/*
	switch method
	| otherwise =>
	| "none" =>
		coefs = [ 1.0 ]
	| "zoh" =>
		# zero-order hold
		coefs = [ 1.0, 1.0 ]
	| "linear" =>
		coefs = [ 0.5, 1.0, 0.5 ]
	| "sinc 1" =>
		coefs = [ -0.00004032787096706525,0,0.0007920116403661329,0,-0.0040181863877435135,0,0.013232838626812462,0,-0.03441026074262933,0,0.07862928971185519,0,-0.17894257012285258,0,0.6247646537513802,0.9999851027875566,0.6247646537513802,0,-0.17894257012285258,0,0.07862928971185519,0,-0.03441026074262933,0,0.013232838626812462,0,-0.0040181863877435135,0,0.0007920116403661329,0,-0.00004032787096706525 ];
	| "sinc 2" =>
		coefs = [-0.000223155103289621,0.0003247356502056869,0.002380083574542235,0.0027438534027862437,-0.0037062150882656553,-0.01330554064114003,-0.009350354982381237,0.018030953203899643,0.04387884723366638,0.019523380919769573,-0.06308669540223802,-0.1208131753539901,-0.029268372751344085,0.24355509271425682,0.5593570762152679,0.6999189728165084,0.5593570762152679,0.24355509271425682,-0.029268372751344085,-0.1208131753539901,-0.06308669540223802,0.019523380919769573,0.04387884723366638,0.018030953203899643,-0.009350354982381237,-0.01330554064114003,-0.0037062150882656553,0.0027438534027862437,0.002380083574542235,0.0003247356502056869,-0.000223155103289621 ];
	| "sinc 3" =>
		coefs = [ 0.000013982738421036122,0.00003417348318904143,-0.00003764100101012808,-0.0001527896644241927,-0.000015895815917497444,0.000370938970103814,0.0003088857515219192,-0.0005643369112154606,-0.0010055286039766232,0.0003882378973523975,0.002082789124162701,0.0006793822397940184,-0.0030932614643256304,-0.00308104296445819,0.0030388323261787502,0.006724708875382101,-0.0005483107467958783,-0.010504114036064527,-0.005533903255275947,0.012091846641057785,0.015243191772241356,-0.008288444866135194,-0.02659484993886801,-0.003989779910778763,0.03510475757898855,0.026329950381553464,-0.033954239808363346,-0.0575922965125618,0.014370412875668459,0.0934573220760928,0.03608228157111943,-0.1271481305821821,-0.14995942055286846,0.15124582145939883,0.6144968487333189,0.8399992442793526,0.6144968487333189,0.15124582145939883,-0.14995942055286846,-0.1271481305821821,0.03608228157111943,0.0934573220760928,0.014370412875668459,-0.0575922965125618,-0.033954239808363346,0.026329950381553464,0.03510475757898855,-0.003989779910778763,-0.02659484993886801,-0.008288444866135194,0.015243191772241356,0.012091846641057785,-0.005533903255275947,-0.010504114036064527,-0.0005483107467958783,0.006724708875382101,0.0030388323261787502,-0.00308104296445819,-0.0030932614643256304,0.0006793822397940184,0.002082789124162701,0.0003882378973523975,-0.0010055286039766232,-0.0005643369112154606,0.0003088857515219192,0.000370938970103814,-0.000015895815917497444,-0.0001527896644241927,-0.00003764100101012808,0.00003417348318904143,0.000013982738421036122 ];

	coefsLen = coefs.length
	sigBaseIdx = 0
	outIdx = 0
	for idx from 0 til sigLen
		coefsIdx = coefsLen
		sigIdx = sigBaseIdx++
		acc0 = 0
		acc1 = 0;
		while coefsIdx
			acc1 += signal[sigIdx] * coefs[--coefsIdx]
			if coefsIdx
				acc0 += signal[sigIdx++] * coefs[--coefsIdx]
		signal2[outIdx++] = acc0
		signal2[outIdx++] = acc1
	*/
	return signal2

/*
signal = new Float32Array 11
for i from 0 to signal.length
	signal[i] = 0.5 + Math.random! * 0.1

console.log upsample signal, new Float32Array 48
*/

class Emo
	(@url = "http://#{document.location.hostname}:3333/emo") ->
		console.log "other emo!"
		@s = new SockJS @url
		@s.onopen = @_onopen
		@s.onmessage = @_onmessage
		@s.onclose = @_onclose
		# TODO: on init, list the devices here
		@devices = {}
		@msgs = 2000

	rpc: (fn, opts = {}) -> @s.send JSON.stringify opts <<< _: fn

	_onopen: ~>
		console.log "connected to emokit. determining devices... TODO: return a device list"
		@rpc "init"
		@rpc "connect"

	_onmessage: (msg) ~>
		d = JSON.parse msg.data
		if d.connected
			#@devices[d.connected] = {}
			amplify.publish "emo:connected", d.connected
			console.log "connected to device #{d.connected}"
		else if d._id # and @msgs-- > 0 #and Math.random! > 0.99
			amplify.publish d._id, d
		#	console.log "msg", msg.data

	_onclose: ~>
		console.log "closed connection!"



# left: F3, P7, F7, T7, AF3, O1, FC5
# right: F4, P8, F8, T8, AF4, O2, FC6
class BrainWave extends Renderable3
	(d) ->
		console.log "new brainwave!"
		super ...
		@idx = 2
		@verts = 200
		@lines = {}
		@_signals = {}

	listen: (uuid) ~>
		amplify.subscribe uuid, (data) ~>
			for own k, v of data
				if typeof @signals[k] is \undefined then continue
				if typeof @_signals[k] is \undefined
					@_signals[k] = [v]
				else
					@_signals[k].push v

	animate: ->
		for k, v of @_signals
			signal = convert v, 16384
			ss = @signals[k]
			if typeof @lines[k] is \undefined
				geometry = new THREE.Geometry
				material = new THREE.LineBasicMaterial {
					color: new THREE.Color (ss.r .<<. 16) + (ss.g .<<. 8) + ss.b
					opacity: 1
					linewidth: 3
					#vertexColors: true
				}
				geometry.vertices = []
				#geometry.colors = []
				line = new THREE.Line geometry, material
				line.position.z = 40
				line.position.x = 200
				line.scale.x = 3
				line.scale.y = 300
			else line = @lines[k]
			if ss.update
				delete ss.update
				line.material.color = new THREE.Color (ss.r .<<. 16) + (ss.g .<<. 8) + ss.b
				console.log "updated"
			
			for v, i in signal
				prev = line.geometry.vertices[0]
				x = if prev then prev.x+1 else 0
				line.geometry.vertices.unshift new THREE.Vector3 i, v, 0
				#color = new THREE.Color 0xffff00
				#color.setRGB v, 0, 1
				#line.geometry.colors.unshift color

				if line.geometry.vertices.length > @verts
					line.geometry.vertices.pop!
					#line.geometry.colors.pop!

			for i from 0 til line.geometry.vertices.length
				line.geometry.vertices[i].x -= signal.length
			@_signals[k] = []

			if typeof @lines[k] is \undefined
				console.log "add to scene", k
				@lines[k] = line
				@scene.add line
			
		super ...

	render: (view, cb) ->
		el = super ...
		aC el,
			cE 'div', {c:"binaural-visualizer"},
				cE 'h1', null, "open-mindedness"
				cE 'div', {c: 'visualizer-container'}, @renderer.domElement
				cE 'div', {c: 'battery'}, "battery:", "67%"
				cE 'div', {c: 'signal-controls'}, (e) ~>
					controls = []
					pop = null
					_.each @signals, (signal, k) ->
						controls.push cE 'div', {c: 'control'},
							$(cE 'div', c: 'slider').slider {
								orientation: "vertical",
								range: "min",
								min: 0,
								max: 100,
								value: signal.gain*100 || 80,
								slide: (event, ui) ~>
									v = ui.value / 100
									signal.gain = v
							}
							cE 'a', {
								c: 'btn'
								onclick: (evt) ~>
									picker = new ColorPicker
									picker.color "rgb(#{signal.r},#{signal.g},#{signal.b})"
									console.log "TODO: set the colorpicker color value - the component doesn't support it yet"
									picker.on 'change', (color) ~>
										signal <<< color
										signal.update = true
									if pop
										if pop.target[0] is evt.target
											noshow = true
										pop.hide!
									if !noshow
										pop := new Popover picker.el
										pop.show evt.target

							}, "color"
							cE 'h4', null, k
					return controls
				cE 'div', c: 'sliders-container',
					$(cE 'div', c: 'slider1').slider {
						orientation: "vertical",
						range: "min",
						min: 0,
						max: 100,
						value: 10,
						slide: (event, ui) ~>
							$ '#amount' .val ui.value
							v = ui.value / 100
							@vol_l.gain.setValue v
							@vol_r.gain.setValue v
					}
					cE 'div', null, "volume"
					cE 'input', {type: 'text', id: 'amount', value: 10}
					#cE 'a', {c: 'button', onclick: ~> @_num_frames = 3}, "reset"



# TODO: render this a list of components
class AudioComponentGroup extends Renderable
	(d) ~>
		@components = []
		super d

	add: (c) ->
		@components.push c
		@rewire!

	remove: (c) ->
		for cc, i in @components
			# XXX not sure if instanceof is the right operator
			if cc instanceof c
				@components.splice i
		@rewire!

	rewire: ->
		cc = @components[0]
		for c in @components
			cc.connect c
			cc = c

# TODO
class AudioComponent extends Renderable
	(d) ~>
		super d


# based off of http://0xfe.muthanna.com/wavebox/
class FrequencyBox extends Renderable
	(d) ~>
		@_el = 'canvas'
		@actx = new window.webkitAudioContext
		@node = @actx.createJavaScriptNode 4096, 1, 1
		@vol = @actx.createGainNode!
		@vol.gain.value = 0
		@node.onaudioprocess = @process
		@sample_rate = @actx.sampleRate
		@hz = 440
		@tick = 0
		@type = 1
		@fft_points = 2048
		@num_bins = 30
		@bar_spacing = 3
		@update_ms = 50
		@smoothing = 0.75
		@points = 0 # num points we want to display (0 for all)
		@fft = @actx.createAnalyser!
		@node.connect @fft
		@fft.connect @vol
		
		@vol.connect @actx.destination
		@data = new Uint8Array @fft.frequencyBinCount
		
		super d
		
		@size 600, 200
		@vctx = @_el.getContext '2d'
		@enable!
		
	size: (@width, @height) ->
		@_el.width = @width
		@_el.height = @height

	enable: ->
		@iinterval = setInterval @update, @update_ms
		console.log "enabling!!"

	disable: ->
		clearInterval @iinterval
		@iinterval = null

	update: ~>
		if @type is 1
			@fft.smoothingTimeConstant = @smoothing
			@fft.getByteFrequencyData @data
		else
			@fft.smoothingTimeConstant = 0
			@fft.getByteFrequencyData @data
			@fft.getByteTimeDomainData @data

		len = @data.length
		if @fft_points > 0 then len = @fft_points
		@vctx.clearRect 0, 0, @width, @height
		bin_size = Math.floor len / @num_bins
		#debugger
		for i from 0 til @num_bins
			sum = 0
			for j from 0 til bin_size then sum += @data[(i*bin_size)+j]
			avg = sum / bin_size
			bar_width = @width / @num_bins
			scaled_avg = avg / 256 * @height
			if @type is 1
				@vctx.fillRect i*bar_width, @height, bar_width - @bar_spacing, -scaled_avg
			else
				@vctx.fillRect i*bar_width, @height - scaled_avg + 2, bar_width - @bar_spacing, -1

	process: (e) ~>
		data = e.outputBuffer.getChannelData 0
		if typeof @onprocess is \function
			@onprocess data
		else 
			for i from 0 to data.length
				data[i] = 0.75 * Math.sin @tick++ / (@sample_rate / (@hz*2 * Math.PI))
		#console.log "process", data


# http://www.schillmania.com/projects/soundmanager2/
class WaveBox extends FrequencyBox
	(d) ~>
		super d
		@num_bins = 1000
		@bar_spacing = 1
		@type = 0

# F3, FC6, P7, T8, F7, F8, T7, P8, AF4, F4, AF3, O2, O1, FC5
# left: F3, P7, F7, T7, AF3, O1, FC5
# right: F4, P8, F8, T8, AF4, O2, FC6



class OpenMind extends Poem
	(d) ~>
		console.log "open mind", d
		super ...

	render: (view, fn) ->
		cE 'div', {c: 'grid grid-pad'}, ->
			return [
				col 9, 12, (el) ~>
					brainwave = new BrainWave {
						_id: 'brainwave'
						signals:
							# left
							F3: r: 255 g: 0 b: 0
							P7: r: 255-10 g: 0 b: 0
							F7: r: 255-20 g: 0 b: 0
							T7: r: 255-30 g: 0 b: 0
							AF3: r: 255-40 g: 0 b: 0
							O1: r: 255-50 g: 0 b: 0
							FC5: r: 255-60 g: 0 b: 0
							# right
							F4: r: 0 g: 0 b: 255
							P8: r: 0 g: 0 b: 255-10
							F8: r: 0 g: 0 b: 255-20
							T8: r: 0 g: 0 b: 255-30
							AF4: r: 0 g: 0 b: 255-40
							O2: r: 0 g: 0 b: 255-50
							FC6: r: 0 g: 0 b: 255-60
					}
					e = new Emo
					amplify.subscribe 'emo:connected', (uuid) ->
						console.log "connected to #{uuid}"
						brainwave.listen uuid
					return [
						brainwave
					]

					#old code:
					dd = {}
					freqbox = new FrequencyBox {_id: "freqbox"}
					wavebox = new WaveBox {
						_id: "wavebox"
						onprocess: (data) ->
							if dd.F7
								signal = convert dd.F7, 16384
								#for i from 0 til signal.length
								#	data[i] = signal[i]
								#for i from 0 til signal.length
								#	signal[i] = 0.5 + Math.random! * 0.1
								upsample signal, data
								for i from 0 til data.length
									if data[i] < 0.1
										console.log "bad data at", i, data.slice i, 10
								#console.log data.slice 0, 10
								while dd.F7.length > 2
									dd.F7.pop!
					}
					e = new Emo
					amplify.subscribe 'emo:connected', (uuid) ->
						console.log "connected to #{uuid}"
						amplify.subscribe uuid, (data) ->
							#console.log "#{uuid}:", d
							for own k, v of data
								if typeof dd[k] is \undefined
									dd[k] = [v]
								else
									dd[k].push v

					return [
						cE 'div', null, freqbox
						cE 'div', null, wavebox
					]
				col 3, 12, (el) ~>
					cE 'div', null, "col2"
			]
	Poem.add '/open-mind', (ctx, next) ->
		new OpenMind {_id: '12345'}
