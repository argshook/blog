# Elm Experiments

[Main.elm live](https://argshook.github.io/elm-experiments)

some things i do with elm when i should be outside.

## how

* `elm make Main.elm --output=elm.js`
* `uglifyjs elm.js --sequences --dead_code --conditionals --booleans --unused --if_return --join_vars --drop_console --compress --mangle --loops --hoist_funs --hoist_vars --cascade --collapse_vars --unsafe --comparisons -o elm.min.js`
* `python -m http.server`
* [localhost:8000](http://localhost:8000) should work


work with `elm reactor` for now
