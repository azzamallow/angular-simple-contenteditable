'use strict'

describe 'Directive: contenteditable', ->
  scope   = {}
  element = null

  beforeEach module 'contenteditable'

  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()
    element = angular.element '<div ng-model="myModelToBindTo" contenteditable="true"></div>'

  describe 'when keydown is applied to the element', ->
    describe 'and enter is pressed', ->
      event = null

      beforeEach inject ($compile) ->
        element = $compile(element) scope
        event = $.Event 'keydown', which: 13
        $('body').append element
        element.trigger event

      afterEach ->
        element.remove()

      it 'should prevent the default action', ->
        expect(event.isDefaultPrevented()).toBeTruthy()

    describe 'and enter is not pressed', ->
      event = null

      beforeEach inject ($compile) ->
        element = $compile(element) scope
        event = $.Event 'keydown', which: 14
        $('body').append element
        element.trigger event

      afterEach ->
        element.remove()

      it 'should not prevent the default action', ->
        expect(event.isDefaultPrevented()).toBeFalsy()

    describe 'for single line', ->
      beforeEach ->
        element.attr 'multiline', undefined
        element.html 'hello<br>text'

      describe 'and enter is pressed', ->
        beforeEach inject ($compile) ->
          element = $compile(element) scope
          $('body').append element
          element.trigger $.Event('keydown', which: 13)

        afterEach ->
          element.remove()

        it 'should not insert a break', ->
          expect(element.html()).toEqual 'hello<br>text'

    describe 'for multiline', ->
      beforeEach ->
        element.attr 'multiline', 'true'
        element.html 'hello<br>text'

      describe 'and enter is pressed', ->
        selection = null

        beforeEach inject ($compile, $window, $document) ->
          element = $compile(element) scope
          $('body').append element
          element.trigger 'focus' # cursor at start of element 
          element.trigger $.Event('keydown', which: 13)

        afterEach ->
          element.remove()

        it 'should insert a break', ->
          expect(element.html()).toEqual '<br>hello<br>text'

  describe 'when keyup is applied to the element', ->
    it 'should replace all <br> with line breaks', inject ($compile) ->
      element = $compile(element) scope
      element.html 'I have entered text<br>s'
      element.triggerHandler 'keyup'
      expect(scope.myModelToBindTo).toEqual 'I have entered text\\ns'

    it 'should remove all other element tags', inject ($compile) ->
      element = $compile(element) scope
      element.html 'I have entered text<br>s with <a>other</a> <div>stuff</div>'
      element.triggerHandler 'keyup'
      expect(scope.myModelToBindTo).toEqual 'I have entered text\\ns with other stuff'

    it 'should remove non printable chars', inject ($compile) ->
      element = $compile(element) scope
      element.html '&#8203;' + 'I have entered text'
      element.triggerHandler 'keyup'
      expect(scope.myModelToBindTo).toEqual 'I have entered text'

    it 'should re-render the value back on to the page to ensure markup is clean', inject ($compile) ->
      element = $compile(element) scope
      element.html 'I have entered text<br>s with <a>other</a> <div>stuff</div>'
      element.triggerHandler 'keyup'
      visibleHtml = element.html().replace /[^ -~]/g, ''
      expect(visibleHtml).toEqual 'I have entered text<br>s with other stuff'

    describe 'when enter is pressed', ->
      beforeEach ->
        $('body').append element
        element.trigger 'focus'
        expect(document.activeElement).toEqual element.get(0)

      afterEach ->
        element.remove()

      describe 'for multiline', ->
        beforeEach inject ($compile) ->
          element.attr 'multiline', 'true'
          element = $compile(element) scope
          element.trigger $.Event('keyup', which: 13)

        it 'should not trigger a blur event', ->
          expect(document.activeElement).toEqual element.get(0)

      describe 'for single line', ->
        beforeEach inject ($compile) ->
          element.attr 'multiline', undefined
          element = $compile(element) scope
          element.trigger $.Event('keyup', which: 13)

        it 'should trigger a blur event', ->
          expect(document.activeElement).not.toEqual element.get(0)

  describe 'when there is a model value', ->
    beforeEach inject ($compile) ->
      element = $compile(element) scope
      scope.myModelToBindTo = 'I have entered text'
      scope.$digest()
    
    it 'should place the text in the element', ->
      visibleText = element.text().replace /[^ -~]/g, ''
      expect(visibleText).toEqual 'I have entered text'

    describe 'when focus is applied to the element', ->
      beforeEach ->
        element.triggerHandler 'focus'

      it 'should still have the text in the element', ->
        visibleText = element.text().replace /[^ -~]/g, ''
        expect(visibleText).toEqual 'I have entered text'

    describe 'when blur is applied to the element', ->
      beforeEach ->
        element.html '&#8203;' + 'this is new text'
        element.triggerHandler 'blur'

      it 'should update the view value, removing invisble chars', ->
        expect(scope.myModelToBindTo).toEqual 'this is new text'

      it 'should render the view value', ->
        expect(element.text()).not.toEqual 'this is new text'
        text = element.text().replace /[^ -~]/g, ''
        expect(text).toEqual 'this is new text'

    describe 'when the contenteditable is multiline enabled', ->
      beforeEach inject ($compile) ->
        element.attr 'multiline', 'true'
        scope.myModelToBindTo = '\\n\\nI have entered text\\n\\n'
        element = $compile(element) scope

      describe 'when blur is applied to the element', ->
        beforeEach ->
          element.triggerHandler 'blur'

        it 'should remove leading and trailing line breaks', ->
          expect(scope.myModelToBindTo).toEqual 'I have entered text'

  describe 'when there is placeholder text', ->
    beforeEach inject ($compile) ->
      element.attr 'placeholder', 'Placeholder text'
      element = $compile(element) scope

    describe 'and there is no model value', ->
      beforeEach ->
        scope.myModelToBindTo = null
        scope.$digest()

      it 'should place the text in the element', ->
        expect(element.text()).toEqual 'Placeholder text'

      it 'should have a placeholder css class', ->
        expect(element.hasClass('has-placeholder')).toBeTruthy()

      describe 'when focus is applied to the element', ->
        beforeEach ->
          element.triggerHandler 'focus'

        it 'should insert silent character so the field does not disappear', ->
          text = element.text()
          expect(text.length).toEqual 1
          expect(text).not.toEqual ''
          text = text.replace /[^ -~]/g, '' # Replace all hidden chars
          expect(text).toEqual ''

        it 'should remove the text from the element', ->
          visibleText = element.text().replace /[^ -~]/g, ''
          expect(visibleText).toEqual ''

        it 'should remove the placeholder css class', ->
          expect(element.hasClass('has-placeholder')).toBeFalsy()

    describe 'and there is a single line model value', ->
      beforeEach ->
        scope.myModelToBindTo = 'I have entered text'
        scope.$digest()

      it 'should place the text in the element', ->
        visibleText = element.text().replace /[^ -~]/g, ''
        expect(visibleText).toEqual 'I have entered text'

    describe 'and there is a mutliline model value', ->
      beforeEach ->
        scope.myModelToBindTo = 'I have entered text\\nWhich is multilined'
        scope.$digest()

      it 'should place the text in the element', ->
        visibleHtml = element.html().replace /[^ -~]/g, ''
        expect(visibleHtml).toEqual 'I have entered text<br>Which is multilined'