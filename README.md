# Trading Analysis Engine (Core)

## 🛡️ Project Guardian (Quality Gate)
This project uses a strict **Zero-Warning Policy** and **Automated Standards Enforcement**.

### Manual Validation
Run the Guardian before submitting any code:
```bash
./scripts/project_guardian.sh
```

### Git Hook Installation (Recommended)
Automatically validate every push:
```bash
cp scripts/project_guardian.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

## 🏗️ Architecture
The project follows a strictly layered structure:
- `lib/services`: Pure synchronous business logic.
- `lib/repositories`: Asynchronous I/O and data persistence.
- `lib/controllers`: State management (Riverpod).
- `lib/ui`: Presentation layer.

See `docs/PROJECT_STANDARDS.md` for full engineering specifications.
