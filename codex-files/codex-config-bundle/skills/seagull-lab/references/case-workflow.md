# Case Workflow

Suggested layout:

```text
case/
  case.json
  manifest.json
  notes.md
  artifacts/original/
  work/
  scripts/
  evidence/
  output/
```

Record the objective, target profile, artifact sources, environment, tool versions, and time zone. Use one command log for exact reproducibility. Assign a purpose to every generated file.

For local services or VMs, record image/container identifiers, ports, credentials created for the case, snapshot names, start commands, health checks, and cleanup commands.

Promote only verified results into `output/`; keep exploratory files in `work/`.
