# ISIALAB Annotation Interface

This is a self-contained package to run the ISIALAB Annotation Interface, a Flask-based application for semantic similarity and stance annotation (VLDBench). It includes fine-tuned models (Sentence-BERT, Cross-Encoders) and integrates with Ollama for zero-shot capabilities.

## Requirements
1. Python 3.9+
2. Ollama (https://ollama.com/)

## Getting Started

**Mac/Linux:**
Open a terminal in this folder and run:
```bash
./start.sh
```

**Windows:**
Double-click `start.bat`

## Using the Tool
1. Once the application starts, it will be available at `http://127.0.0.1:5000` (or the port specified in your terminal).
2. You can upload your JSON annotation files via the interface.
3. The tool utilizes models from the `models/` directory for predicting semantic similarities.
4. Follow the annotation protocol detailed in `protocole.md` for consistent labeling (`supporting`, `against`, `undetermined`, `not_related`, `dismissed`).

## Data and Annotations
- Uploaded files are saved in the `uploads/` directory.
- Annotations are stored in a local SQLite database (`annotations.db`).
- Check `protocole.md` for detailed annotation rules and thresholds.
