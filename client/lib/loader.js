
function aC(el, els, idx) {
	if(!el) {
		el = document.getElementsByTagName('body')[0];
	}
	switch(typeof els) {
		case 'string':
		case 'number':
		case 'boolean':
			els = document.createTextNode(els)
			el.appendChild(els);
		break;
		case 'function':
			// DEBUG
			//try {throw new Error('m')} catch(e) {
			//	loading = cE('div', 0, "loading in progres,,,s", e.stack);
			//}
			//TODO: only do the loading box when the stack depth is large
			return aC(el, els(el));
			loading = cE('div', {c: 'loading'}, "loading...");
			//el.appendChild(loading);
			aC(el, loading, idx);
			aC.next(function(p, c, i, l, scope) {
				return function() {
					while(typeof c === 'function') {
						c = c.call(scope, p);
					}
					if(l.parentNode) p.removeChild(l);
					var df = document.createDocumentFragment();
					aC.call(scope, df, c, i);
					console.log("p.replaceChild(df, l)", p, df, l)
					//p.replaceChild(df, l);
					//debugger
					p.insertBefore(df, l);
					p.deleteNode(l);
				}
			} (el, els, idx, loading, this));
			return el;
		case 'object':
			if(typeof els.get === 'function') {
				return aC(el, els.get());
			}
			if(typeof els.render === 'function') {
				return aC(el, els.render());
			}
			if(typeof els.appendChild === 'function') {
				if(typeof idx === 'undefined') {
					el.appendChild(els);
				} else {
					el.insertBefore(els, el.childNodes[idx]);
				}
				
			} else if(els.length > 0) {
				for(var i = 0, df = document.createDocumentFragment(); i < els.length; i++) {
					aC(df, els[i]);
				}
				// someday, maybe cache this and do df.cloneNode(true)
				aC(el, df, idx);
			} else {
				console.log("edge case:", els)
			}
	}
	return el;
}
aC.cb = []
aC.id = null
aC.next = function(fn) {
	if(typeof fn === 'function') {
		aC.cb.push(fn);
	}
	if(aC.cb.length && !aC.id) {
		aC.id = setTimeout(function(f) {
			return function() {
				f();
				aC.id = null
				aC.next();
			};
		}(aC.cb.shift()), 0);
	}
}


function cE(type, opts) {
	var e = document.createElement(type),
		len = arguments.length;

	if(typeof opts === 'object') {
		for(var i in opts) {
			var v = opts[i];
			switch(i) {
				case "c":
				case "class":
					e.className = v;
				break;
				case "data":
				for(var k in v) {
					//e.setAttribute('data-'+k, v[k]);
					e.dataset[k] = v[k];
				}
				break;
				case "s":
				case "style":
					e.style.cssText = v;
				break;
				case "t":
				case "template":
					v = SKIN.getTemplate(v);
				case "html":
					e.innerHTML = v;
				break;
				default:
					e[i] = v;
			}
		}
	}
	

	if(len > 1) {
		for(var i = 2; i < len; i++) {
			var a = arguments[i];
			//while(typeof a === 'function') {
			//	a = a.call(this, e);
			//}
			aC(e, a);
		}
	}

	return e;
}

// object.watch
if (!Object.prototype.watch) {
	Object.defineProperty(Object.prototype, "watch", {
		enumerable: false,
		configurable: true,
		writable: false,
		value: function (prop, handler) {
			var oldval = this[prop],
				newval = oldval,
				getter = function() {
					return newval;
				},
				setter = function(val) {
					oldval = newval;
					return newval = handler.call(this, prop, oldval, val);
				};
			
			if(delete this[prop]) { // can't watch constants
				Object.defineProperty(this, prop, {
					get: getter,
					set: setter,
					enumerable: true,
					configurable: true
				});
			}
		}
	});
}

// object.unwatch
if (!Object.prototype.unwatch) {
	Object.defineProperty(Object.prototype, "unwatch", {
		enumerable: false,
		configurable: true,
		writable: false,
		value: function (prop) {
			var val = this[prop];
			delete this[prop]; // remove accessors
			this[prop] = val;
		}
	});
}
