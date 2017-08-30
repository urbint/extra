
0.1.0 / 2017-08-30
==================

Initial external release of `extra`, extracted from our internal umbrella app

  * build(circleci): Cache the `_build` folder on circleci
  * build(dialyzer): Use :transitive for `plt_add_deps`
  * build(circleci): Add config for CircleCI
  * fix(mix): point mix.exs at non-umbrella files
  * docs(): simplify README
  * fix(mix-apps): Don't try to run Cortex on Drone
  * deps(cortex): Update cortex to 0.2.1
  * feat(): Add `Enum.Extra.rename_keys`
  * feat(): Add a Monoid protocol
  * feat(extra:keyword): Adds `get_keys/2` function
  * feat(extra:keyword): Adds `fetch_keys!/*` fn
  * deps(shorter-maps): Adds ShorterMaps dependency
  * feat(extra:struct): Creates `keys/1` convenience fn
  * fix(struct): disable credo nesting warning
  * feat(extra:struct): Adds `merge/2` for structs
  * fix(extra:string): Titlecase supports dashes
  * feat(extra:struct): Adds `drop/2` convenience fn
  * feat(extra:map): Adds `assert_keys!` and `has_keys?`
  * feat(extra:map): Adds `take_non_nil` fn
  * feat(extra:enum): add `unique?/1`
  * feat(extra:enum): add `map_if/3`
  * chore(core): upgrade to Elixir 1.5.1
  * chore(): remove trailing whitespace from all files
  * feat(extra:tuple): add `unwrap_ok!/1` and `wrap_with/2,` and `unwrap_ok_with_default/2`
  * feat(extra:enum): add `reduce_or_error/3`
  * fix(enum:extra): `map_or_error/3` adherering more closely to enum.map usage
  * test(extra:stream): Covers `Stream.Extra.unwrap_oks!/1`
  * feat(extra:stream): Impls `unwrap_oks!/1`
  * chore(extra:stream): Updates `unwrap_oks/1` docs and impl
  * deps(extra): Adds cortex to Extra
  * fix(extra:module): ignore credo raise inside rescue warning
  * refactor(extra:enum): Calls `Enum.to_list/1` for more assertive impl
  * chore(dialyzer): fixing all of our broken typespecs
  * chore(extra:process): doc changes, typo fixes
  * feat(extra:process): add `nearest/2` function
  * refactor(tests): Moves default test dir to env var
  * refactor(extra:behaviour): Adds missing functions to error msg
  * refactor(extra:keyword): Removes unnecessary `default/3` in favor of `get/3`
  * docs(extra:keyword): Fixes incorrect spec
  * feat(extra:file): Adds `ensure_dir/1`
  * fix(ex_unit:extra): dont rely on Core.Config
  * chore(): remove trailing whitespace
  * feat(extra): implement `Process.Extra.exit/2`
  * refactor(Keyword,Map.Extra): `assert_key!/3` `:nil_ok` => `:allow_nil_value` and default changed
  * fix(keyword:extra): `assert_key!/3` ensures checked key is not nil by default
  * feat(map:extra): optional `nil_ok:` boolean defaults to false
  * feat(extra:keyword): Adds default function to remove default value boilerplate
  * chore(extra:keyword,map): Enhances error message to include key
  * chore(extra:map): Drops t in favor of map in specs
  * chore(extra:map): Drops unless expr in favor of case expr
  * chore(map:extra): Removes dead code from Map.Extra test
  * feat(map:extra): Adds `assert_key!` for Map type
  * feat(ex_unit:extra): `assert_receive_either/3` macro and test
  * feat(extra:flow): `unwrap_oks/2`
  * chore(list.extra): add docs for failure case of `List.Extra.pop_first/3`
  * refactor(): Use better error return for `List.Extra.pop_first`
  * feat(): add `List.Extra.pop_first`
  * feat(extra:module): `Module.Extra.assert_exists!(module)` impl and tests
  * feat(extra:behaviour): `Behaviour.Extra.assert_impl!(behaviour,` module) impl and tests
  * chore(): Formats docs to conform to standards
  * chore(): add typespecs for `Enum.Extra.index_by`
  * docs(Enum.Extra): add examples for `Enum.Extra.index_by/2`
  * chore(): fix grammar in test name
  * feat(enum:extra): Adds `index_by/2` helper function
  * refactor(extra:enum): `Enum.Extra.map_or_error/2` implemented, tests, docs
  * chore(): Use more descriptive test names in `Enum.ExtraTest`
  * feat(extra:map): impls `Map.each_or_error/2`
  * chore(): remove trailing whitespace in `String.Extra`
  * chore(errors): fix error message on `Keyword.Extra.assert_key!/3`
  * feat(extra:enum): add `each_or_error/2` fn
  * refactor(keyword:extra): Removes unnecessary default function - using `get/3` instead
  * feat(keyword:extra): Adds `default/3` function for working with opts
  * feat(extra): port over `Stream.Extra`
  * feat(extra): port over `Keyword.Extra` module and tests
  * feat(extra): port `String.Extra` from umbrella. Simplify API
