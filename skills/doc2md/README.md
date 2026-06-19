# 🦞 openclaw-doc2md

An [OpenClaw](https://openclaw.ai) skill that converts documents to LLM-ready markdown — automatically triggered when you send any file attachment to your agent via Telegram.

---

## What it does

Drop any file into your Telegram chat with your OpenClaw agent. The skill:

1. Detects the incoming file attachment
2. Converts it to clean markdown using [markitdown](https://github.com/microsoft/markitdown)
3. Cleans up common PDF artifacts like form-feed characters and repetitive boilerplate
4. Sends the `.md` file back as an attachment
5. Shows a cleaner inline preview in chat
6. Cleans up temp files

The intended chat reply style is intentionally tight:

```text
✅ Converted: filename.pdf
📄 Format: PDF → Markdown

Preview:
<first meaningful excerpt>
```

No command needed. Just send the file.

---

## Supported Formats

| Category | Formats |
|----------|---------|
| Documents | PDF, DOCX, DOC, PPTX, PPT, XLSX, XLS, EPUB |
| Data | CSV, JSON, XML |
| Web | HTML, HTM |
| Images | JPG, PNG, GIF, WebP (LLM mode) |
| Audio | WAV, MP3 (speech-to-text via LLM mode) |

Full format quality guide in [`references/supported-formats.md`](references/supported-formats.md).

---

## LLM Mode

For image-heavy PDFs, scanned documents, or image files, the skill can optionally use an OpenAI-compatible LLM to enhance extraction:

- **Default mode:** LLM-enhanced conversion is enabled by default in this install
- **Standard-only mode:** use `--no-llm` when you want a local-only pass
- **Auto-retry mode:** use `--auto-llm` when you want standard first, LLM second

LLM mode may send document contents to the configured provider and may incur cost. It requires the `openai` package and an active API key in the environment.

---

## Installation

### 1. Install dependencies

```bash
pip install -r requirements.txt
```

For isolated installs, prefer a virtual environment:

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
```

### 2. Copy the skill folder into your workspace

```
skills/
  doc2md/
    SKILL.md
    doc2md.py
    references/
      supported-formats.md
```

The skill instructions use OpenClaw's `{baseDir}` placeholder, so no hardcoded local paths are required.

---

## File Structure

```
.
├── SKILL.md                        # Agent instructions and skill config
├── doc2md.py                       # Conversion script
└── references/
    └── supported-formats.md        # Full format support reference
```

---

## How it works

The skill uses [markitdown](https://github.com/microsoft/markitdown) — an MIT-licensed Microsoft library that converts 15+ document formats to markdown without requiring an API.

```
Telegram file → temp download → markitdown → .md file → back to chat
```

For LLM mode, markitdown uses the configured OpenAI-compatible model to interpret images, diagrams, and scanned pages.

---

## Dependencies

- Python 3.10+
- `markitdown[pdf]` (Microsoft, MIT license; includes PDF parser dependencies)
- `openai` (for LLM-enhanced conversion)
- OpenClaw

---

## License

MIT
