# Angular Builder
Small builder that encourages you to build services that are inherently testable. Its very easy in angular to build services that are very difficult to unit test. 

### Bad Service
```javascript
  (function(){
    function myCoolService(userService, productService, timeService, $q){
      function myPrivateMethod(arg){
        // this does stuff
      }
      function myPublicMethod(){
        // this does stuff too
        myPrivateMethod('foo');
      }
      return {
        myPublicMethod: myPublicMethod
      };
    }
    myCoolService.$inject = ['userService', 'productService', 'timeService', '$q']
    angular.module('me.myCoolService', ['ng', 'other.userService','other.productService', 'other.timeService']).factory('myCoolService', myCoolService);
  }())
```
### Problems
1. You can't test anything relating to the private method in jasmine. Its hidden in the context. So you are unable to write expectations that assert that its called, assert the kinds of arguments that are passed to it or return fake data.
2. Even if you put it in the returned {} if you ever call it directly by accident any spies are ignored.
3. Argument injections start to get unwieldy and difficult to follow at around the fourth one. Especially when you are keeping them in sync with $inject blocks later in the file.
4. Similar issues with the dependency block. The inline array doesn’t format well around the fourth element.

### Same service with Angular Builder
```javascript
angular.$build.service(function(service){
  service
    .name('myCoolService')
    .module('me.myCoolService')
    .dependsOn('ng').inject('$q')
    .dependsOn('other.userService').inject('userService')
    .dependsOn('other.productService').inject('productService')
    .dependsOn('other.timeService').inject('timeService')
    .define('myPrivateMethod', function(arg){
      // this does stuff
    })
    .expose('myPublicMethod', function(){
      // this does stuff
      this.myPrivateMethod('foo')
    });
});
```
### Advantages
1. Declarative syntax explicitly states what each piece of information is for. `service.name('myCoolService');`
2. No more managing $inject blocks. You have access to every injected item off of this. `this.$q`
3. All private methods are exposed on a $private object so you have the capability to stub or override their behavior in a test case. `service.$private.myPrivateMethod`
4. All methods private or public are accessible via this. `this.myPrivateMethod('foo');` Making it so you cannot accidently reference the raw method bypassing a spy. 

### How this came about
I have Been doing focused angular and ruby work for over a year and have begun to be realize that my rspec tests were much more complete compared to my jasmine tests. I started to think about how I could restructure my services to support better testing. This tiny library is the codification of these ideas. 
