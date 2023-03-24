# rain.math.fixedpoint

Docs at https://rainprotocol.github.io/rain.math.fixedpoint

## Goals

Ideally we'd not need this library as math primitives are probably best handled
in some upstream library.

What we need:

- 18 decimal fixed point math
- handle rounding directions explicitly
- rescale non-18 decimal fixed point values (e.g. ERC20 token amounts) to/from
  18 decimals so that we can do math on them
- avoid code bloat in an interpreter due to importing several libs with heavily
  overlapping scope
- open source license, but not forcing ppl to jump on the GPL crusade
- minimal surface area so we can gracefully deprecate this lib if all the above
  is provided elsewhere someday
- works on simple `uint256` values

Upstream candidates:

- Open Zeppelin
  - Has implementations that include rounding direction 👍
  - Audited code due to recent ERC4626 implementation 👍
  - Only includes math needed by the specs implemented, not general purpose 👎
- PRB math
  - General purpose fixed point math 👍
  - Where the scope overlaps OZ the logic is similar or identical 👍
  - No ability to specify rounding or to rescale outside 18 decimals 👎
  - Never audited 👎
- Others
  - Either wrong license or issues as pointed out on PRB math repo

Since we need math that isn't provided by Open Zeppelin, and we aren't going to
write it ourselves, PRB math seems to be the most reasonable foundation. At the
same time, Open Zeppelin may already be a dependency for other reasons, such as
some token implementation, so including both OZ and PRB in a single contract can
bloat code.

## Non-goals

None of this is supported/needed:

- Signed math
- Non-18 decimal fixed point math (other than rescaling)
- One size fits all solution

## Approach

- Provide a base repo (this one) that has zero dependencies, to focus on the
  logic required to rescale between decimals, that are lib agnostic.
- Provide supporting repos to normalise Open Zeppelin and PRB math
  - OZ includes `muldiv` but doesn't have an opinion on decimals, so caller is
    forced to provide "one" at every step and mentally balance multiplication
    and division
  - PRB is opinionated with sane defaults for 18 decimal math but provides no
    rounding or rescaling support

Downstream consumers are advised to select _one_ of either OZ or PRB to compile
into their contracts, using the relevant supporting libs only, to minimise
dependencies and potential code bloat, or even inconsistent behaviours between
libs.