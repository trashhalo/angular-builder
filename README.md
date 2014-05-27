# Angular Builder
Small builder that encourages you to build services that are inherently testable. Its very easy in angular to build services that are very difficult to unit test. 

##### Bad Service
```javascript
  (function(){
    function myCoolService(userService, productService, timeService, $q){
      function myPrivateMethod(arg){
        // this does stuff
      }
      function myPublicMethod(){
        // this does stuff too
        myPrivateMethod(“foo”);
      }
      return {
        myPublicMethod: myPublicMethod
      };
    }
    myCoolService.$inject = ['userService', 'productService', 'timeService', '$q']
    angular.module('me.myCoolService', ['ng', 'other.userService','other.productService', 'other.timeService']).factory('myCoolService', myCoolService);
  }())
```
##### Problems
1. You can't test anything relating to the private method in jasmine. Its hidden in the context. So you are unable to write expectations that assert that its called, assert the kinds of arguments that are passed to it or return fake data.
2. Even if you put it in the returned {} if you ever call it directly by accident any spies are ignored.
3. Argument injections start to get unwieldy and difficult to follow at around the fourth one. Especially when you are keeping them in sync with $inject blocks later in the file.
4. Similar issues with the dependency block. The inline array doesn’t format well around the fourth element.

##### Same service with Angular Builder
```javascript
angular.$build.service(function(service){
  service.name('myCoolService');
  service.module('me.myCoolService');
  
  service.dependsOn('ng');
  service.dependsOn('other.userService');
  service.dependsOn('other.productService');
  service.dependsOn('other.timeService');
  
  service.inject('userService');
  service.inject('productService');
  service.inject('timeService');
  service.inject('$q');
  
  service.define('myPrivateMethod', function(arg){
    // this does stuff
  });
  
  service.expose('myPublicMethod', function(){
    // this does stuff
    this.myPrivateMethod('foo');
  });
});
```
##### Advantages
1. Declarative syntax explicitly states what each piece of information is for. `service.name('myCoolService');`
2. No more managing $inject blocks. You have access to every injected item off of this. `this.$q`
3. All private methods are exposed on a $private object so you have the capability to sub or override their behavior in a test case. `service.$private.myPrivateMethod`
4. All methods private or public are accessible via this. `this.myPrivateMethod('foo');` Making it so you cannot accidently reference the raw method bypassing a spy. 

#### How this came about
Been doing focused angular and ruby work for over a year and have begun to be realize that my rspec tests were much more complete compared to my jasmine tests. I started to think about how I could restructure my services to support better testing. This tiny library is the codification of these ideas. 