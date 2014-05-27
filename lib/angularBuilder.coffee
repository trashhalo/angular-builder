angular = if @.window then @.window.angular else null

class ServiceBuilder
	constructor: ()->
		this.service = {
			name: null,
			module: null,
			dependsOn: [],
			injects: [],
			defines: [],
			exposes: [],
			constructors: []
		}
	name: (name)->
		this.service.name = name
		if(this.service.module == null)
			this.service.module = name
		this
	module: (module)->
		this.service.module = module
		this
	dependsOn: (module)->
		this.service.dependsOn.push module
		this
	inject: (name)->
		this.service.injects.push name
		this
	define: (key, val)->
		this.service.defines.push {
			key: key,
			val: val
		}
		this
	expose: (key, val)->
		this.service.exposes.push {
			key: key,
			val: val
		}
		this
	cons: (fn)->
		this.service.constructors.push(fn)
		this

	@::$private = {}
	
	@::$private.angular = angular

	@::$private.bind = (fn, thisWrapper) ->
		() -> fn.apply(thisWrapper, arguments)

	@::$private.addInject = (injectKey, injectVal, result, thisWrapper) ->
		result.$injects[injectKey] = injectVal
		Object.defineProperty thisWrapper, injectKey, {
			get: ()-> result.$injects[injectKey],
			enumerable : true,
			configurable : true
		}

	@::$private.addInjects = (service, values, result, thisWrapper) ->
		for inject, index in service.injects
			@.addInject inject, values[index], result, thisWrapper
	
	@::$private.fireConstructor = (service, constructor, thisWrapper) ->
		constructor.apply(thisWrapper, [service])
	
	@::$private.fireConstructors = (service, thisWrapper) ->
		for con in service.service.constructors
			@.fireConstructor(service, con, thisWrapper)

	@::$private.addDefine = (defineKey, defineValue, result, thisWrapper) ->
		if typeof defineValue == 'function'
			result.$private[defineKey] = @.bind defineValue, thisWrapper
		else
			result.$private[defineKey] = defineValue
		Object.defineProperty thisWrapper, defineKey, {
			get: ()-> result.$private[defineKey],
			set: (val)-> result.$private[defineKey] = val,
			enumerable : true,
			configurable : true
		}
	
	@::$private.addDefines = (service, result, thisWrapper) ->
		for def in service.defines
			@.addDefine def.key, def.val, result, thisWrapper
	
	@::$private.addExpose = (exposeKey, exposeValue, result, thisWrapper) ->
		if typeof exposeValue == 'function'
			result[exposeKey] = @.bind exposeValue, thisWrapper
		else
			result[exposeKey] = exposeValue
		Object.defineProperty thisWrapper, exposeKey, {
			get: ()-> result[exposeKey],
			enumerable : true,
			configurable : true
		}

	@::$private.addExposes = (service, result, thisWrapper) ->
		for def in service.exposes
			@.addExpose def.key, def.val, result, thisWrapper

	build: ()->
		
		serviceConstructor = () =>
			result = {
				$private : {},
				$injects : {}
			}
			thisWrapper = {}
			@.$private.addInjects this.service, arguments, result, thisWrapper
			@.$private.fireConstructors @, thisWrapper
			@.$private.addDefines this.service, result, thisWrapper
			@.$private.addExposes this.service, result, thisWrapper
			result

		serviceConstructor.$inject = this.service.injects
		@.$private.angular.module(this.service.module, this.service.dependsOn).factory(this.service.name, serviceConstructor)

class Builder
	service: (callback) =>
    	serviceBuilder = new @.$private.ServiceBuilder
    	callback(serviceBuilder)
    	serviceBuilder.build()

  	@::$private = {}
  	@::$private.ServiceBuilder = ServiceBuilder

builder = new Builder

if(angular)
	angular.$build = builder
else
	@.$build = builder

builder