# Parrotnest Dev-Kit

Automation toolkit for fast, repeatable local development workflows.

Built for the **Parrotnest V12 ("Parrot Cove Edition")** release, this Dev-Kit helps developers keep environments clean, builds consistent, and onboarding simple.

---

## Parrotnest V12 Context

**Parrotnest V12** is a modern real-time chat and collaboration platform designed for school communities, friend groups, and LAN environments.

The application stack includes:

- **Windows Desktop Host** (WinForms) for server lifecycle management
- **ASP.NET Core API** with SignalR for real-time communication
- **Web Client** built with PHP + Vanilla JavaScript
- **Desktop Installer** for streamlined deployment

This Dev-Kit exists to support day-to-day development of that ecosystem.

---

## Why This Dev-Kit Exists

- Standardize recurring dev tasks across the team
- Reduce setup friction between machines
- Provide one-command cleanup and rebuild workflows
- Keep local environments ready for testing Parrotnest V12 features

---

## Included Scripts

- **`dev-kit.ps1`** - Main orchestrator script (recommended entry point)
- **`build.ps1`** - Auto-detects project type and executes the proper build flow
- **`cleanup-db.ps1`** - Removes configured local database files
- **`reset-env.ps1`** - Full environment reset (database + build artifacts + logs)
- **`config.json`** - Central configuration file
- **`dev-kit.log`** - Runtime log file (generated automatically)

---

## Quick Start

From PowerShell, run commands from this folder:

```powershell
# Default action: build
.\dev-kit.ps1

# Database cleanup
.\dev-kit.ps1 -Action cleanup-db

# Full environment reset
.\dev-kit.ps1 -Action reset-env

# Full cycle: reset + build
.\dev-kit.ps1 -Action all
```

You can also run scripts directly:

```powershell
.\build.ps1
.\cleanup-db.ps1
.\reset-env.ps1
```

---

## Configuration (`config.json`)

Tune behavior without changing script code:

- **`projectName`** - Project display name
- **`version`** - Dev-Kit configuration version
- **`database.fileName`** - Database filename used for cleanup
- **`build.defaultConfiguration`** - Build configuration (for example: `Release`)
- **`build.outputFolder`** - Publish/build output path
- **`autoDetect`** - File patterns used to detect .NET, Node.js, Python, or Java projects
- **`logging`** - Logging enablement and log filename

---

## System Requirements

- **OS:** Windows 10 / 11
- **Shell:** Windows PowerShell 5.1+ or PowerShell 7+
- **Build tools:** Install only what your project requires:
  - `.NET SDK` for .NET projects
  - `npm` for Node.js projects
  - `pip` for Python projects
  - `mvn` or `gradle` for Java projects

---

## Logging and Error Handling

- Every script writes timestamped logs to console
- If enabled in config, logs are appended to `dev-kit.log`
- Errors are surfaced immediately and terminate execution with non-zero exit codes

---

## Typical Workflow for Parrotnest V12

```powershell
# 1) Clean local environment
.\dev-kit.ps1 -Action reset-env

# 2) Rebuild project artifacts
.\dev-kit.ps1 -Action build

# 3) Continue with runtime tests for V12 features
#    (for example: message editing, SignalR real-time flows, installer validation)
```

---

## Team

Developed with passion by the **JGS Team**:

- Adam Hnatko ("Hnato")
- Igor Kondraciuk ("Flubi3604")
- Jakub Fedorowicz ("John0G1thub")
