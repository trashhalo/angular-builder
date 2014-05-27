builder = require("./../../lib/angularBuilder").$build

describe "builder", ->
	subject = null
	
	beforeEach ->
		subject = builder

	it "is defined", ->
		expect(subject).toBeDefined()
	
	it "has a service method", ->
		expect(subject.service).toEqual jasmine.any Function
	
	describe "service", ->
		serviceBuilderSpy = null
		callback = null

		beforeEach ->
			serviceBuilderSpy = jasmine.createSpyObj('serviceBuilder', ['build'])
			spyOn(subject.$private, "ServiceBuilder").andReturn(serviceBuilderSpy)
			callback = jasmine.createSpy 'callback'
			subject.service(callback)

		it "creates a ServiceBuilder", ->
			expect(subject.$private.ServiceBuilder).toHaveBeenCalled()
		
		it "invokes callback with ServiceBuilder object", -> 
			expect(callback).toHaveBeenCalledWith serviceBuilderSpy

		it "calls build", ->
			expect(serviceBuilderSpy.build).toHaveBeenCalled()


	describe "ServiceBuilder", ->
		
		beforeEach ->
			subject = new builder.$private.ServiceBuilder

		it "sets name", ->
			subject.name("foo")
			expect(subject.service.name).toBe "foo"
		
		it "sets module", ->
			subject.module("foo")
			expect(subject.service.module).toBe "foo"
		
		it "adds depends", ->
			subject.dependsOn "fooModule"
			expect(subject.service.dependsOn).toEqual ["fooModule"]
		
		it "adds defines", ->
			subject.define "fooKey", "fooVal"
			expect(subject.service.defines).toEqual [
				key: "fooKey"
				val: "fooVal"
			]
		
		it "adds exposes", ->
			subject.expose "fooKey", "fooVal"
			expect(subject.service.exposes).toEqual [
				key: "fooKey"
				val: "fooVal"
			]
		
		it "adds injects", ->
			subject.inject "fooService"
			expect(subject.service.injects).toEqual ["fooService"]

		describe "addInject", ->
			thisWrapper = null
			result = null
			
			beforeEach ->
				thisWrapper = {}
				result = {$injects:{}}
				subject.$private.addInject "fooKey", "fooVal", result, thisWrapper
			
			it "adds key to results $injects", ->	
				expect(result.$injects.fooKey).toBe "fooVal"

			it "adds key to thisWrapper", ->	
				expect(thisWrapper.fooKey).toBe "fooVal"

		describe "addDefine", ->
			thisWrapper = null
			result = null

			beforeEach ->
					thisWrapper = {}
					result = {$private:{}}

			describe "called with a object value", ->
				beforeEach ->
					subject.$private.addDefine "fooKey", "fooVal", result, thisWrapper
				
				it "adds key to result", ->	
					expect(result.$private.fooKey).toBe "fooVal"

				it "adds key to thisWrapper", ->	
					expect(thisWrapper.fooKey).toBe "fooVal"
			
			describe "called with a function value", ->
				fooVal = null

				beforeEach ->
					fooVal = () ->
					subject.$private.addDefine "fooKey", fooVal, result, thisWrapper

				it "is a function", ->
					expect(result.$private.fooKey).toEqual jasmine.any(Function)

				it "wraps function to force this binding", ->	
					expect(result.$private.fooKey).not.toBe 

		describe "addExpose", ->
			thisWrapper = null
			result = null
			
			beforeEach ->
				thisWrapper = {}
				result = {}
				
			
			describe "called with a object value", ->
	
				beforeEach ->
					subject.$private.addExpose "fooKey", "fooVal", result, thisWrapper
				
				it "adds key to result", ->	
					expect(result.fooKey).toBe "fooVal"

				it "adds key to thisWrapper", ->	
					expect(thisWrapper.fooKey).toBe "fooVal"

			describe "called with a function value", ->

				fooVal = null

				beforeEach ->
					fooVal = () ->
					subject.$private.addExpose "fooKey", fooVal, result, thisWrapper

				it "is a function", ->
					expect(result.fooKey).toEqual jasmine.any(Function)

				it "wraps function to force this binding", ->	
					expect(result.fooKey).not.toBe 

		describe "addInjects", ->
			result = null
			thisWrapper = null

			beforeEach ->
				spyOn subject.$private, 'addInject'
				result = {}
				thisWrapper = {}
				subject.$private.addInjects {injects: ["fooKey"]}, ["fooVal"], result, thisWrapper

			it "calls addInject", ->
				expect(subject.$private.addInject).toHaveBeenCalledWith("fooKey", "fooVal", result, thisWrapper)

		describe "addDefines", ->
			result = null
			thisWrapper = null

			beforeEach ->
				spyOn subject.$private, 'addDefine'
				result = {}
				thisWrapper = {}
				subject.$private.addDefines {defines: [{key: "fooKey", val: "fooVal"}]}, result, thisWrapper

			it "calls addDefine", ->
				expect(subject.$private.addDefine).toHaveBeenCalledWith("fooKey", "fooVal", result, thisWrapper)

		describe "addExposes", ->
			result = null
			thisWrapper = null

			beforeEach ->
				spyOn subject.$private, 'addExpose'
				result = {}
				thisWrapper = {}
				subject.$private.addExposes {exposes: [{key: "fooKey", val: "fooVal"}]}, result, thisWrapper

			it "calls addExpose", ->
				expect(subject.$private.addExpose).toHaveBeenCalledWith("fooKey", "fooVal", result, thisWrapper)

		describe "build", ->
			angular = null
			angularModule = null
			constructorFunction = null

			beforeEach ->
				angular = jasmine.createSpyObj 'angular', ['module']
				angularModule = jasmine.createSpyObj 'angularModule', ['factory']
				angular.module.andReturn angularModule
				angularModule.factory.andCallFake (name, fn)-> constructorFunction = fn
				subject.$private.angular = angular

			describe "empty service created", ->
				beforeEach ->
					subject.name "myCoolService"
					subject.module "bb.myCoolService"
					subject.build()

				it "calls angular module", ->
					expect(angular.module).toHaveBeenCalledWith("bb.myCoolService", [])

				it "creates a factory on the angular module", ->
					expect(angularModule.factory).toHaveBeenCalledWith("myCoolService", jasmine.any(Function))

				it "sets $inject to an empty array", ->
					expect(constructorFunction.$inject).toEqual []
			
			describe "empty service with one inject and one depends", ->
				beforeEach ->
					subject.name "myCoolService"
					subject.module "bb.myCoolService"
					subject.dependsOn "bb.myOtherService"
					subject.inject "myOtherService"
					subject.build()

				it "adds the module as a dependency", ->
					expect(angular.module).toHaveBeenCalledWith(jasmine.any(String), ["bb.myOtherService"])

				it "adds the $inject", ->
					expect(constructorFunction.$inject).toEqual ["myOtherService"]

			describe "service with one exposed and one private method", ->
				service = null
				beforeEach ->
					subject.name "myCoolService"
					subject.module "bb.myCoolService"
					subject.expose "myPublicMethod", ->
					subject.define "myPrivateMethod", ->
					subject.build()
					service = constructorFunction()

				it "exposes the public method", ->
					expect(service.myPublicMethod).toEqual jasmine.any Function

				it "defines the private method", ->
					expect(service.$private.myPrivateMethod).toEqual jasmine.any Function