# Corners
[URF, UFL, ULB, UBR, DFR, DLF, DBL, DRB] = [0..7]

# Edges
[UR, UF, UL, UB, DR, DF, DL, DB, FR, FL, BL, BR] = [0..11]


class Cube
  constructor: (other) ->
    if other?
      @init(other)
    else
      @identity()

    # For moves to avoid allocating new objects each time
    @newCp = (0 for x in [0..7])
    @newEp = (0 for x in [0..11])
    @newCo = (0 for x in [0..7])
    @newEo = (0 for x in [0..11])

  init: (state) ->
    @cp = state.cp.slice(0)
    @co = state.co.slice(0)
    @ep = state.ep.slice(0)
    @eo = state.eo.slice(0)

  identity: ->
    # Initialize to the identity cube
    @cp = [0..7]
    @co = (0 for x in [0..7])
    @ep = [0..11]
    @eo = (0 for x in [0..11])

  toJSON: ->
    cp: @cp
    co: @co
    ep: @ep
    eo: @eo

  clone: ->
    new Cube(@toJSON())

  randomize: do ->
    randint = (min, max) ->
      min + (Math.random() * (max - min + 1) | 0)

    mixPerm = (arr) ->
      max = arr.length - 1
      for i in [0..max - 2]
        r = randint(i, max)

        # Ensure an even number of swaps
        if i != r
          [arr[i], arr[r]] = [arr[r], arr[i]]
          [arr[max], arr[max - 1]] = [arr[max - 1], arr[max]]

    randOri = (arr, max) ->
      ori = 0
      for i in [0..arr.length - 2]
          ori += (arr[i] = randint(0, max - 1))

      # Set the orientation of the last cubie so that the cube is
      # valid
      arr[arr.length - 1] = (max - ori % max) % max

    result = ->
      mixPerm(@cp)
      mixPerm(@ep)
      randOri(@co, 3)
      randOri(@eo, 2)
      this

    result

  # A class method returning a new random cube
  @random: ->
    (new Cube).randomize()

  isSolved: ->
    for c in [0..7]
      return false if @cp[c] != c
      return false if @co[c] != 0

    for e in [0..11]
      return false if @ep[e] != e
      return false if @eo[e] != 0

    true

  # Multiply this Cube with another Cube, restricted to corners.
  cornerMultiply: (other) ->
    for to in [0..7]
      from = other.cp[to]
      @newCp[to] = @cp[from]
      @newCo[to] = (@co[from] + other.co[to]) % 3

    [@cp, @newCp] = [@newCp, @cp]
    [@co, @newCo] = [@newCo, @co]
    @

  # Multiply this Cube with another Cube, restricted to edges
  edgeMultiply: (other) ->
    for to in [0..11]
      from = other.ep[to]
      @newEp[to] = @ep[from]
      @newEo[to] = (@eo[from] + other.eo[to]) % 2

    [@ep, @newEp] = [@newEp, @ep]
    [@eo, @newEo] = [@newEo, @eo]
    @

  # Multiply this cube with another Cube
  multiply: (other) ->
    @cornerMultiply(other)
    @edgeMultiply(other)
    @

  @moves: [
    # U
    {
      cp: [UBR, URF, UFL, ULB, DFR, DLF, DBL, DRB]
      co: [0, 0, 0, 0, 0, 0, 0, 0]
      ep: [UB, UR, UF, UL, DR, DF, DL, DB, FR, FL, BL, BR]
      eo: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    # R
    {
      cp: [DFR, UFL, ULB, URF, DRB, DLF, DBL, UBR]
      co: [2, 0, 0, 1, 1, 0, 0, 2]
      ep: [FR, UF, UL, UB, BR, DF, DL, DB, DR, FL, BL, UR]
      eo: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    # F
    {
      cp: [UFL, DLF, ULB, UBR, URF, DFR, DBL, DRB]
      co: [1, 2, 0, 0, 2, 1, 0, 0]
      ep: [UR, FL, UL, UB, DR, FR, DL, DB, UF, DF, BL, BR]
      eo: [0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0]
    }

    # D
    {
      cp: [URF, UFL, ULB, UBR, DLF, DBL, DRB, DFR]
      co: [0, 0, 0, 0, 0, 0, 0, 0]
      ep: [UR, UF, UL, UB, DF, DL, DB, DR, FR, FL, BL, BR]
      eo: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    # L
    {
      cp: [URF, ULB, DBL, UBR, DFR, UFL, DLF, DRB]
      co: [0, 1, 2, 0, 0, 2, 1, 0]
      ep: [UR, UF, BL, UB, DR, DF, FL, DB, FR, UL, DL, BR]
      eo: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }

    # B
    {
      cp: [URF, UFL, UBR, DRB, DFR, DLF, ULB, DBL]
      co: [0, 0, 1, 2, 0, 0, 2, 1]
      ep: [UR, UF, UL, BR, DR, DF, DL, BL, FR, FL, UB, DB]
      eo: [0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1]
    }
  ]

  faceNums =
    U: 0
    F: 1
    L: 2
    D: 3
    B: 4
    R: 5

  faceNames =
    0: 'U'
    1: 'F'
    2: 'L'
    3: 'D'
    4: 'B'
    5: 'R'

  parseAlg = (arg) ->
    if typeof arg is 'string'
      # String
      for part in arg.split(/\s+/)
        if part.length is 0
          # First and last can be empty
          continue

        if part.length > 2
          throw 'Invalid move: ' + part

        move = faceNums[part[0]]
        if move is undefined
          throw 'Invalid move: ' + part

        if part.length == 1
          power = 0
        else
          if part[1] == '2'
            power = 1
          else if part[1] == "'"
            power = 2
          else
            throw 'Invalid move: ' + part

        move * 3 + power

    else if arg.length?
      # Already an array
      arg

    else
      # A single move
      [arg]

  move: (arg) ->
    for move in parseAlg(arg)
      face = move / 3 | 0
      power = move % 3
      @multiply(Cube.moves[face]) for x in [0..power]

    this

  @inverse: (arg) ->
    result = for move in parseAlg(arg)
      face = move / 3 | 0
      power = move % 3
      face * 3 + -(power - 1) + 1

    result.reverse()

    if typeof arg is 'string'
      str = ''
      for move in result
        face = move / 3 | 0
        power = move % 3
        str += faceNames[face]
        if power == 1
          str += '2'
        else if power == 2
          str += "'"
        str += ' '
      str.substring(0, str.length - 1)

    else if arg.length?
      result

    else
      result[0]


## Globals

if module?
  module.exports = Cube
else
  @Cube = Cube