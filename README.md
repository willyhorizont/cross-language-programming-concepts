# cross-language-programming-concepts

Cross-language implementations of common programming concepts, data structures, algorithms, and patterns.

## Requirements

- Docker Engine
- Git
- Visual Studio Code (optional)

---

# R

## Build

```bash
chmod +x docker/r/setup.sh
chmod +x runner/r/run.sh

./docker/r/setup.sh
```

## Run

```bash
bash ./runner/r/run.sh filename.r
```

---

# Go

## Build

```bash
chmod +x docker/go/setup.sh
chmod +x runner/go/run.sh

./docker/go/setup.sh
```

## Run

```bash
bash ./runner/go/run.sh filename.go
```

---

# JavaScript

## Build

```bash
chmod +x docker/javascript/setup.sh
chmod +x runner/javascript/run.sh

./docker/javascript/setup.sh
./runner/javascript/install.sh
```

## Run

```bash
bash ./runner/javascript/run.sh filename.js
```