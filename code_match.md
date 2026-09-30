# PROMPT.md

## Task

You are an early career faculty member, preparing for a campus interview. Using the supplied application materials, the job add, and the link to the personal website, draft the following: 1) a brief bio about you (5 to 10 sentences); 2) a brief description of your research talk (5-10 sentences); and a brief description of your teaching demo (3-8 sentences)?

## Context


- Project goal: Identify and plan remaining tasks to publish manuscript.
- Relevant files: HayesGavin_wd26.docx
- Job advertisement: https://hr.wwu.edu/careers-faculty?job=502910

## Desired outcome

Identify R scripts that were used to generate figures in the manuscript document. Match scripts with figure numbers. If code is missing, alert for which figures it is missing.

## Instructions for Claude

Follow the project rules in `CLAUDE.md`.

In addition:

1. Start by briefly restating the task in your own words.
2. Give a short plan before writing code.
3. Prefer the simplest correct solution.
4. Use clear, readable R code.
5. Keep changes small and easy to review.
6. Make the workflow reproducible from a fresh session.
7. Do not introduce new packages unless necessary.
8. If anything is ambiguous, ask a focused question before proceeding.
9. If there are multiple approaches, recommend the simplest one.
10. If you edit code, explain exactly what changed.

## Output format

Please respond in this order:

1. Brief interpretation of the task.
2. Plan.
3. Code or changes.
4. Notes on assumptions, risks, or alternatives.
5. Next steps, if needed.

## Files to inspect first

- `README.md`
- `CLAUDE.md`
- WWU_HayesResearch.docx
- WWU_HayesCover.docx
- WWU Job Prep.md
- krhayes.com

## Expected deliverables

- Matched figures with scripts
- List of figures for which code to generate is missing
- Specify input data file for each script.


## Notes

- Keep the answer concise unless more detail is necessary.
- Prefer clarity over cleverness.
- Preserve existing project structure unless a change is clearly better.
- When uncertain, state the uncertainty rather than guessing.
