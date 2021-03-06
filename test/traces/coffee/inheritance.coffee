class Animal
  constructor: (@name) ->

  move: (meters) ->
    @name + ' moved ' + meters + 'm'

class Snake extends Animal
  move: ->
    super(5) + ' by slithering'

sam = new Snake 'Sam'
sam.move()

# Trace:
#   1:  before  Animal=<function>
#   1:  after   Animal=<function>
#   2:  before
#   2:  after
#   4:  before
#   4:  after
#   7:  before  Snake=<function> Animal=<function>
#   7:  after   Snake=<function> Animal=<function>
#   8:  before
#   8:  after
#   11: before  sam=/
#     2: enter   @name='Sam'
#     2: leave   return=/
#   11: after   sam=<object> Snake()=<object>
#   12: before  sam=<object>
#     8: enter
#     9: before
#       4: enter   meters=5
#       5: before  @name='Sam' meters=5
#       5: after   @name='Sam' meters=5
#       4: leave   return='Sam moved 5m'
#     9: after   super()='Sam moved 5m'
#     8: leave   return='Sam moved 5m by slithering'
#   12: after   sam=<object> move()='Sam moved 5m by slithering'

