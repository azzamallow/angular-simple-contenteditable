'use strict'

describe 'Directive: contenteditable', ->
  scope   = {}
  element = null

  beforeEach module 'contenteditable'

  beforeEach inject ($rootScope) ->
    scope = $rootScope.$new()
    element = angular.element '<div ng-model="myModelToBindTo" contenteditable="true"></div>'

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