(function() {
  'use strict';
  angular.module('contenteditable', []);

  angular.module('contenteditable').directive('contenteditable', function($window, $document) {
    return {
      require: 'ngModel',
      link: function(scope, element, attrs, ctrl) {
        var insertBreak;
        insertBreak = function() {
          var br, range, selection;
          if ($window.getSelection) {
            br = $document[0].createElement('br');
            selection = $window.getSelection();
            range = selection.getRangeAt(0);
            range.deleteContents();
            range.insertNode(br);
            range.setStartAfter(br);
            range.setEndAfter(br);
            selection.removeAllRanges();
            return selection.addRange(range);
          } else if ($document[0].selection && $document[0].selection.createRange) {
            return $document[0].selection.createRange().html = '<br>';
          }
        };
        element.bind('keydown', function(event) {
          if (event.which === 13) {
            event.preventDefault();
            if (attrs.multiline != null) {
              return insertBreak();
            }
          }
        });
        element.bind('keyup', function(event) {
          var value;
          value = element.html().replace(/<br>/g, '\\n');
          value = value.replace(/[^ -~]/g, '');
          value = value.replace(/<[^>]*>/g, '');
          scope.$apply(function() {
            return ctrl.$setViewValue(value);
          });
          ctrl.$render();
          if ((attrs.multiline == null) && event.which === 13) {
            return element.trigger('blur');
          }
        });
        ctrl.$render = function() {
          if (ctrl.$viewValue) {
            element.removeClass('has-placeholder');
            return element.html('&#8203;' + ctrl.$viewValue.replace(/\\n/g, '<br>'));
          } else {
            element.html(attrs.placeholder);
            return element.addClass('has-placeholder');
          }
        };
        element.bind('focus', function() {
          if (element.text() === attrs.placeholder) {
            element.html('&#8203;');
            ctrl.$setViewValue('');
            return element.removeClass('has-placeholder');
          }
        });
        return element.bind('blur', function() {
          var value;
          if (element.text() === attrs.placeholder) {
            return;
          }
          value = element.text();
          if (attrs.multiline != null) {
            value = ctrl.$viewValue;
          }
          value = value.replace(/[^ -~]/g, '');
          value = value.replace(/^(\\n)*|(\\n)*$/g, '');
          scope.$apply(function() {
            return ctrl.$setViewValue(value);
          });
          return ctrl.$render();
        });
      }
    };
  });

}).call(this);
