# Repository workflow

- After changes have been fully tested, commit and push them without asking for
  an additional confirmation so the user can rebuild and test them immediately.
- When changes affect the `mywm-shell` or `mywm` inputs, update, test, commit,
  and push dependent Flake lock files in dependency order.
- Do not push changes that have not passed the relevant checks; report blockers
  instead.
