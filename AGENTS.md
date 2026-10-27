# Repository workflow

- After changes have been fully tested, commit and push them without asking for
  an additional confirmation so the user can rebuild and test them immediately.
- When changes affect the `splice` input, update, test, commit, and push the
  Flake lock file.
- Do not push changes that have not passed the relevant checks; report blockers
  instead.
