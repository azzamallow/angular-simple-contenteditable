angular-simple-contenteditable
==============================

A simple contenteditable directive which binds to an ng-model. Features include:

* Two way binding with ng-model
* Sanitises model, no markup in the model, line breaks replaced with /n
* Support for multiline and single line element
* Placeholder text support

browser support
---------------

angular-simple-contenteditable currently supports Google Chrome. Other browsers may work but not been verified yet.

install
-------

```
bower install angular-simple-contenteditable
```

usage
-----

Make sure you include the module in your application config

```
angular.module('myApp', [
  'contenteditable',
  ...
]);
```

Add the directive to any HTML element

```
<div ng-model="myModel" contenteditable="true"></div>
```

By default when you press enter the element will lose focus. If you would like a cariage return instead do:

```
<div ng-model="myModel" contenteditable="true" multiline="true"></div>
```

Placeholder text can also be provided

```
<div ng-model="myModel" contenteditable="true" placeholder="My placeholder text"></div>
```

Content will be automatically sanitised, all markup is removed and only the line breaks will remain

```
<div ng-model="myModel" contenteditable="true" placeholder="My placeholder text">
  Here is some text<br>
  <br>
  And text on another line
</div>
```

Will set the model to:

```
$scope.myModel === 'Here is some text\n\nAnd text on another line'; // true
```
