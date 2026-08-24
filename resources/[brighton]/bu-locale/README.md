# bu-locale — Russian locale pack

Russian labels for QBCore items and jobs, applied in memory without touching the framework files at runtime.

## What it does

- Overrides `QBCore.Shared.Items` and `QBCore.Shared.Jobs` labels with natural Russian names.
- Covers the extra Brighton Union items (licenses, letter, gathered resources) and the eight custom jobs.

## Deployment note

The recommended setup is to install the static localization files with `install-locale.ps1` (see `locale-pack/`), which also patches the QBCore shared scripts, phone, banking and loading screen files used by the other systems. This resource is the runtime overlay layer on top of that.
