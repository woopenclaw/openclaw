---
name: doc2md
description: Convert Telegram document attachments to clean Markdown using markitdown, defaulting to LLM-enhanced conversion, then reply with a .md file and a short, clean preview. Use when a user sends a supported document or media attachment and wants it converted to markdown.
metadata: {"openclaw":{"requires":{"bins":["python3"]}}}
---

# doc2md — Document to Markdown Converter

Convert supported document attachments into clean, LLM-ready markdown. No command is needed; detect the incoming file and run the pipeline. This install defaults to LLM-enhanced conversion.

## Trigger

**Activate this skill when:**
- An incoming Telegram message has a document/file attachment
- The file extension is: `.pdf`, `.docx`, `.doc`, `.xlsx`, `.xls`, `.pptx`, `.ppt`, `.html`, `.htm`, `.csv`, `.json`, `.xml`, `.epub`, `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.wav`, `.mp3`
- No explicit user command required — file attachment = auto-convert

**Do NOT activate for:**
- Text messages without attachments
- Voice messages (those are transcription, not doc2md)
- Already-markdown files (`.md`)

## Conversion Pipeline

### Step 1 — Download the file

Use the Telegram attachment path provided in the message context. OpenClaw normally downloads the file to a temporary path automatically.

```bash
# Use the attachment file path from the incoming message context.
```

### Step 2 — Convert with markitdown

Use the skill-local virtualenv so dependencies stay isolated from system Python.

Default command — LLM-enhanced conversion:

```bash
"{baseDir}/.venv/bin/python" "{baseDir}/doc2md.py" "<file_path>" --output "<output_file>" --preview 700
```

Optional fallback if you explicitly want standard non-LLM conversion:

```bash
"{baseDir}/.venv/bin/python" "{baseDir}/doc2md.py" "<file_path>" --no-llm --output "<output_file>" --preview 700
```

Optional retry mode:

```bash
"{baseDir}/.venv/bin/python" "{baseDir}/doc2md.py" "<file_path>" --auto-llm --output "<output_file>" --preview 700
```

**Get a preview only:**

```bash
"{baseDir}/.venv/bin/python" "{baseDir}/doc2md.py" "<file_path>" --preview 700
```

### Step 3 — Save the output

```bash
OUTPUT_FILE="/tmp/$(basename '<file_path>' | sed 's/\.[^.]*$//').md"
PREVIEW="$("{baseDir}/.venv/bin/python" "{baseDir}/doc2md.py" "<file_path>" --output "$OUTPUT_FILE" --preview 700)"
```

### Step 4 — Send back to User

1. **Send the .md file** as a document attachment (use `message` tool with `filePath`)
2. **Send a short inline preview** as a text message
3. Keep the preview clean and human-friendly:
   - do **not** dump raw first characters blindly
   - prefer the first meaningful section, heading, summary, or table of contents
   - for PDFs, avoid leading copyright/legal boilerplate when possible
   - if extraction still looks messy, say so briefly and offer a cleaned pass

Recommended reply shape:

```
✅ Converted: <original_filename>
📄 Format: <detected format>

Preview:
<clean excerpt>
```

Reply style rules:
- Send **one tidy text reply** plus the markdown file attachment
- Keep the text reply to **3 short blocks max**: status line, format line, preview block
- Do **not** include raw separators like `---` unless they add real clarity
- Do **not** mention internal flags, parser libraries, or tool names unless troubleshooting
- If the preview still looks noisy, say so plainly in one short sentence and still send the `.md` file
- Prefer this exact structure:

```text
✅ Converted: <original_filename>
📄 Format: <source type> → Markdown

Preview:
<clean excerpt>
```

If useful, add one brief note after the preview:

```text
Note: I skipped some PDF boilerplate at the start.
```

### Step 5 — Clean up

```bash
rm -f "$OUTPUT_FILE"
```

## Error Handling

| Situation | Response |
|-----------|----------|
| Unsupported format | "Sorry, I can't convert `.<ext>` files. Supported: PDF, Word, Excel, PowerPoint, HTML, images, and more." |
| Conversion produces empty output | "The conversion produced an empty result — the file may be encrypted, corrupted, or purely image-based. I can retry with a different mode if needed." |
| Dependencies missing | Recreate the skill venv and install requirements: `python3 -m venv "{baseDir}/.venv" && "{baseDir}/.venv/bin/pip" install -r "{baseDir}/requirements.txt"` |
| PDF conversion fails with missing parser deps | Ensure `requirements.txt` includes `markitdown[pdf]`, then reinstall the venv requirements |
| File too large (>50MB) | "That file is too large for conversion (>50MB). Try splitting it first." |
| Generic failure | "Conversion failed: `<error message>`. Let me know if you want to try a different approach." |

## LLM Mode — Local Default

This install defaults to LLM-enhanced conversion.

Notes:
- Document contents may be sent to the configured OpenAI-compatible provider and may incur cost
- Use `--no-llm` only when you explicitly want a local-only standard pass
- Use `--auto-llm` when you want a cheap first pass before escalating

## Example Interaction

```
User: [sends "Q1_Report.pdf"]

Agent: ✅ Converted: Q1_Report.pdf
     📄 Format: PDF (12 pages)

     ---
     # Q1 2026 Financial Report

     ## Executive Summary

     Revenue for Q1 2026 reached €4.2M, representing a 23% year-over-year
     increase compared to Q1 2025...

     [sends Q1_Report.md as file attachment]
```

## Notes

- The `.md` file is named after the original file (e.g. `report.pdf` → `report.md`)
- Always send BOTH the file attachment AND the inline preview
- Prefer one tidy reply, not a noisy multi-message back-and-forth, unless troubleshooting is needed
- Write the converted `.md` file to a temporary path and clean it up after sending
- Use the skill-local virtualenv at `{baseDir}/.venv/bin/python`
- If User sends multiple files in quick succession, process them sequentially
- For PDFs, expect possible front-matter noise; favor previews from meaningful content over legal boilerplate
