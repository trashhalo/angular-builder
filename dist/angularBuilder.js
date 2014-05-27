(function() {
  var Builder, ServiceBuilder, angular, builder,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  angular = this.window ? this.window.angular : null;

  ServiceBuilder = (function() {
    function ServiceBuilder() {
      this.service = {
        name: null,
        module: null,
        dependsOn: [],
        injects: [],
        defines: [],
        exposes: [],
        constructors: []
      };
    }

    ServiceBuilder.prototype.name = function(name) {
      this.service.name = name;
      if (this.service.module === null) {
        this.service.module = name;
      }
      return this;
    };

    ServiceBuilder.prototype.module = function(module) {
      this.service.module = module;
      return this;
    };

    ServiceBuilder.prototype.dependsOn = function(module) {
      this.service.dependsOn.push(module);
      return this;
    };

    ServiceBuilder.prototype.inject = function(name) {
      this.service.injects.push(name);
      return this;
    };

    ServiceBuilder.prototype.define = function(key, val) {
      this.service.defines.push({
        key: key,
        val: val
      });
      return this;
    };

    ServiceBuilder.prototype.expose = function(key, val) {
      this.service.exposes.push({
        key: key,
        val: val
      });
      return this;
    };

    ServiceBuilder.prototype.cons = function(fn) {
      this.service.constructors.push(fn);
      return this;
    };

    ServiceBuilder.prototype.$private = {};

    ServiceBuilder.prototype.$private.angular = angular;

    ServiceBuilder.prototype.$private.bind = function(fn, thisWrapper) {
      return function() {
        return fn.apply(thisWrapper, arguments);
      };
    };

    ServiceBuilder.prototype.$private.addInject = function(injectKey, injectVal, result, thisWrapper) {
      result.$injects[injectKey] = injectVal;
      return Object.defineProperty(thisWrapper, injectKey, {
        get: function() {
          return result.$injects[injectKey];
        },
        enumerable: true,
        configurable: true
      });
    };

    ServiceBuilder.prototype.$private.addInjects = function(service, values, result, thisWrapper) {
      var index, inject, _i, _len, _ref, _results;
      _ref = service.injects;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        inject = _ref[index];
        _results.push(this.addInject(inject, values[index], result, thisWrapper));
      }
      return _results;
    };

    ServiceBuilder.prototype.$private.fireConstructor = function(service, constructor, thisWrapper) {
      return constructor.apply(thisWrapper, [service]);
    };

    ServiceBuilder.prototype.$private.fireConstructors = function(service, thisWrapper) {
      var con, _i, _len, _ref, _results;
      _ref = service.service.constructors;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        con = _ref[_i];
        _results.push(this.fireConstructor(service, con, thisWrapper));
      }
      return _results;
    };

    ServiceBuilder.prototype.$private.addDefine = function(defineKey, defineValue, result, thisWrapper) {
      if (typeof defineValue === 'function') {
        result.$private[defineKey] = this.bind(defineValue, thisWrapper);
      } else {
        result.$private[defineKey] = defineValue;
      }
      return Object.defineProperty(thisWrapper, defineKey, {
        get: function() {
          return result.$private[defineKey];
        },
        set: function(val) {
          return result.$private[defineKey] = val;
        },
        enumerable: true,
        configurable: true
      });
    };

    ServiceBuilder.prototype.$private.addDefines = function(service, result, thisWrapper) {
      var def, _i, _len, _ref, _results;
      _ref = service.defines;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        def = _ref[_i];
        _results.push(this.addDefine(def.key, def.val, result, thisWrapper));
      }
      return _results;
    };

    ServiceBuilder.prototype.$private.addExpose = function(exposeKey, exposeValue, result, thisWrapper) {
      if (typeof exposeValue === 'function') {
        result[exposeKey] = this.bind(exposeValue, thisWrapper);
      } else {
        result[exposeKey] = exposeValue;
      }
      return Object.defineProperty(thisWrapper, exposeKey, {
        get: function() {
          return result[exposeKey];
        },
        enumerable: true,
        configurable: true
      });
    };

    ServiceBuilder.prototype.$private.addExposes = function(service, result, thisWrapper) {
      var def, _i, _len, _ref, _results;
      _ref = service.exposes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        def = _ref[_i];
        _results.push(this.addExpose(def.key, def.val, result, thisWrapper));
      }
      return _results;
    };

    ServiceBuilder.prototype.build = function() {
      var serviceConstructor;
      serviceConstructor = (function(_this) {
        return function() {
          var result, thisWrapper;
          result = {
            $private: {},
            $injects: {}
          };
          thisWrapper = {};
          _this.$private.addInjects(_this.service, arguments, result, thisWrapper);
          _this.$private.fireConstructors(_this, thisWrapper);
          _this.$private.addDefines(_this.service, result, thisWrapper);
          _this.$private.addExposes(_this.service, result, thisWrapper);
          return result;
        };
      })(this);
      serviceConstructor.$inject = this.service.injects;
      return this.$private.angular.module(this.service.module, this.service.dependsOn).factory(this.service.name, serviceConstructor);
    };

    return ServiceBuilder;

  })();

  Builder = (function() {
    function Builder() {
      this.service = __bind(this.service, this);
    }

    Builder.prototype.service = function(callback) {
      var serviceBuilder;
      serviceBuilder = new this.$private.ServiceBuilder;
      callback(serviceBuilder);
      return serviceBuilder.build();
    };

    Builder.prototype.$private = {};

    Builder.prototype.$private.ServiceBuilder = ServiceBuilder;

    return Builder;

  })();

  builder = new Builder;

  if (angular) {
    angular.$build = builder;
  } else {
    this.$build = builder;
  }

  builder;

}).call(this);
