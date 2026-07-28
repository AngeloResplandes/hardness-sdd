# Cycle naming

The canonical version of these rules. The phase skills carry their own condensed copy, because
a skill that reaches across into a sibling skill's folder breaks the moment someone installs
them somewhere other than side by side. **If you change a rule here, update the copies** in
`sdd-start` (naming + date) and in `sdd-refine`, `sdd-implement`, `sdd-validate`, `sdd-promote`
(cycle resolution).

The folder name is the cycle's permanent identity — it ends up in git history, in
`spec-delta.md`, and in the plan's frontmatter, so getting it right once is cheaper than
correcting it everywhere later.

## Shape

```
cycles/Q{quarter}{year}/{MMDD}-<slug>/
```

Example: `cycles/Q32026/0726-episodes-list-webcomponent/`

## The date

Get today's **real** date before creating anything:

- PowerShell: `Get-Date -Format 'yyyy-MM-dd'`
- bash: `date +%F`

Never guess it and never infer it from conversation context. A cycle dated wrong is
mis-filed permanently.

## Quarter

Derived from the month, not from a fiscal calendar:

| Months | Quarter |
|---|---|
| Jan–Mar | Q1 |
| Apr–Jun | Q2 |
| Jul–Sep | Q3 |
| Oct–Dec | Q4 |

## Slug

Kebab-case, describing the **capability**, not the ticket:

- `episodes-list-webcomponent` — good
- `JIRA-4412` — bad; meaningless in six months and to anyone outside the tracker
- `fix-bug` — bad; every cycle is a fix of something

If a ticket number matters, put it in `request.md` under References. The folder name is for
humans reading the repo two years from now.

## Resolving "the current cycle"

When a phase skill needs to know which cycle it is operating on:

1. If the user named one, use that.
2. Otherwise take the newest folder under `cycles/` — newest by folder name (the `Q{q}{yyyy}/{MMDD}`
   prefix sorts chronologically), not by filesystem mtime, which changes whenever a file is
   touched.
3. If `cycles/` has more than one candidate from the same day and the user did not say
   which, ask. Guessing wrong here means writing a plan into someone else's cycle.
