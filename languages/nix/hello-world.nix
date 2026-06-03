let
  do = variadicArguments:
    builtins.foldl'
      (accumulator: currentValue:
      let
        result = currentValue accumulator;
      in
        builtins.deepSeq result result
      )
      { }
      variadicArguments;
in
do [
  (state:
  let
    newState = state // {
    };
  in
    builtins.trace "hello, world"
    newState
  )
]
