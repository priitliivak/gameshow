
angular.module 'gameshow'
  .directive 'markdown', () ->
    restrict: 'A'
    scope:
      markdown: '='

    # replace content
    controller: ( $scope, $element ) ->

      # set blocks of code format
      _highlight_code = ( html ) ->

        # replace code blocks
        html = html.replace `/\[\/code]/g`, '</pre>'
        html = html.replace `/\[code(:[^\]]*)?\]/g`, ( match ) ->
          language = match.replace `/\[code:?/gi`, ''
            .replace `/\].*$/gi`, ''
          '<pre class="code '+ "#{language}" +'" >'


      # watch for changes
      $scope.$watch 'markdown', ( value ) ->
        html = value or ''

        # create markup
        html = _highlight_code html

        # convert to markdown
        converter = new Markdown.Converter
        html = $ "<div> #{ converter.makeHtml html }</div>"

        # format code blocks
        html.find 'pre.code'
          .each () ->
            element = $ this
            element.text element.html().replace /\&gt;/i, '>'
            hljs.highlightBlock element[0]


        # update the content
        $element.empty()
        $element.append html
