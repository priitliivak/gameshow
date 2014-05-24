
# handles the projector view

angular.module 'gameshow'
  .controller 'DisplayController', ( $scope, $location, App, Game, Socket ) ->
    $scope.game = Game
    $scope.app = App


    # navigate to the next slide
    $scope.next = ->
      $scope.index = $scope.index + 1
      _update_section()


    # navigate to the previous slide
    $scope.previous = ->
      $scope.index = Math.max 0, $scope.index - 1
      _update_section()


    # picks a section
    $scope.select = ( section ) ->

      # don't bother if invalid
      return if not section or section.done

      # pick the section
      $scope.section = section
      $scope.index = 0

      # notify the server
      Socket.emit 'navigate:section',
        category: section.category
        section: section.key

      # update the view
      _update_section()


    # handles updating for slide content
    _update_section = ->

      # make sure a section is ready
      return unless $scope.section?

      # reused data
      index=
        slide: $scope.index
        question: $scope.index - $scope.section.slides.length

      # figure out where the view is at
      finished = index.question >= $scope.section.questions.length
      in_slides = index.slide < $scope.section.slides.length
      in_questions = index.question < $scope.section.questions.length

      # clear existing
      delete $scope.slide
      delete $scope.question

      # if this finished the $scope.section
      if finished
        Socket.emit 'navigate:clear'
        $scope.section.done = true
        delete $scope.section

      # check if a slide
      else if in_slides
        $scope.slide = $scope.section.slides[ index.slide ]

      # should this be a question?
      else if in_questions
        Socket.emit 'navigate:question', index: index.question
        $scope.question = $scope.section.questions[ index.question ]


    # displays a successful answer
    _show_answer = ( data ) ->



    # handle navigation requests
    Socket.on 'navigate:next', $scope.next
    Socket.on 'navigate:previous', $scope.previous
    Socket.on 'navigate:select', ( data ) -> $scope.select Game.data[ data.category ]?[ data.section ]

    # handle game state changes
    Socket.on 'game:answer', _show_answer


    # load and make sure data is found
    # only the display section should
    # get game data
    Game.load ( data ) -> $location.path '/' unless data

