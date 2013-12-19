'use strict'

angular.module 'contenteditable', []

angular.module('contenteditable')
  .directive 'contenteditable', ($window, $document) ->

    # Inherit behaviour from ngModel
    require: 'ngModel',

    # link
    link: (scope, element, attrs, ctrl) ->
      # Insert a break element where the cursor is currently placed
      insertBreak = ->
        # Modern browsers
        if $window.getSelection
          br = $document[0].createElement 'br'

          # Get new range based on current selection
          selection = $window.getSelection()
          range     = selection.getRangeAt 0

          # Remove any text selected
          range.deleteContents()

          # Set the br
          range.insertNode    br
          range.setStartAfter br
          range.setEndAfter   br

          # Remove the current range
          selection.removeAllRanges()

          # Add the new range
          selection.addRange range

          # Get caret position relative to the element
          # cloneRange  = range.cloneRange();
          # cloneRange.selectNodeContents element[0]
          # cloneRange.setEnd range.endContainer, range.endOffset
          # currentOffset = cloneRange.toString().length;
          # elementLength = element.text().length

          # # Are we at the end of the element?
          # if currentOffset == elementLength

        # Fallback for older browsers
        else if $document[0].selection && $document[0].selection.createRange
          $document[0].selection.createRange().html = '<br>'

      # Handle events before a keystroke is shown
      element.bind 'keydown', (event) ->
        # pressing enter
        if event.which == 13
          event.preventDefault()
          insertBreak() if attrs.multiline?

      # Handle events once a keystroke is showing
      element.bind 'keyup', (event) ->
        # Replace brs with line breaks
        value = element.html().replace /<br>/g, '\\n'

        # Replace non printable chars
        value = value.replace /[^ -~]/g, ''

        # Remove all other elements that may have crept in
        value = value.replace /<[^>]*>/g, '' 

        # Bind from view to the model
        scope.$apply -> ctrl.$setViewValue value

        # Re-render the value back, unnecessary markup may need to be cleaned up
        ctrl.$render()

        # Lose focus when enter is pressed on single line
        if !attrs.multiline? && event.which == 13
          element.trigger 'blur'

      # Bind from the model back to the view
      ctrl.$render = ->
        if ctrl.$viewValue
          element.removeClass 'has-placeholder'

          # Replace line breaks with brs
          element.html '&#8203;' + ctrl.$viewValue.replace /\\n/g, '<br>'
        else
          # placeholder
          element.html attrs.placeholder
          element.addClass 'has-placeholder'

      element.bind 'focus', ->
        # When the placeholder is showing
        if element.text() == attrs.placeholder
          # Insert zero-width html character
          element.html '&#8203;'

          # Reset model
          ctrl.$setViewValue ''
          element.removeClass 'has-placeholder'

      element.bind 'blur', ->
        return if element.text() == attrs.placeholder

        value = element.text()
        value = ctrl.$viewValue if attrs.multiline?

        # Replace non printable chars
        value = value.replace /[^ -~]/g, ''

        # Trim leading and trailing breaks
        value = value.replace /^(\\n)*|(\\n)*$/g, ''

        # Update view value
        scope.$apply -> ctrl.$setViewValue value

        # render the value
        ctrl.$render()