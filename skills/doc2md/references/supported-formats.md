# Supported Formats — markitdown

Full list of formats markitdown can convert, with notes on quality and LLM assistance.

## Document Formats

| Format | Extension(s) | Quality | LLM Needed? | Notes |
|--------|-------------|---------|-------------|-------|
| PDF | `.pdf` | ⭐⭐⭐⭐ | Sometimes | Excellent for text-based PDFs. Use `--llm` for scanned/image-only PDFs |
| Word | `.docx`, `.doc` | ⭐⭐⭐⭐⭐ | No | Excellent. Preserves headings, lists, tables |
| PowerPoint | `.pptx`, `.ppt` | ⭐⭐⭐⭐ | No | Extracts slide text and speaker notes |
| Excel | `.xlsx`, `.xls` | ⭐⭐⭐⭐ | No | Converts sheets to markdown tables |
| CSV | `.csv` | ⭐⭐⭐⭐⭐ | No | Clean table output |
| HTML | `.html`, `.htm` | ⭐⭐⭐⭐⭐ | No | Strips tags, preserves structure |
| EPUB | `.epub` | ⭐⭐⭐⭐ | No | Good for ebooks |
| XML | `.xml` | ⭐⭐⭐ | No | Structured data extraction |
| JSON | `.json` | ⭐⭐⭐⭐ | No | Formatted as code block |

## Image Formats

| Format | Extension(s) | Quality | LLM Needed? | Notes |
|--------|-------------|---------|-------------|-------|
| JPEG | `.jpg`, `.jpeg` | ⭐⭐⭐ | **Yes** | LLM describes image content |
| PNG | `.png` | ⭐⭐⭐ | **Yes** | LLM describes image content |
| GIF | `.gif` | ⭐⭐ | **Yes** | LLM describes first frame |
| WebP | `.webp` | ⭐⭐⭐ | **Yes** | LLM describes image content |

*Without `--llm`, images produce only EXIF metadata (file size, dimensions, camera info).*

## Audio Formats

| Format | Extension(s) | Quality | LLM Needed? | Notes |
|--------|-------------|---------|-------------|-------|
| WAV | `.wav` | ⭐⭐⭐⭐ | **Yes (speech-to-text)** | Transcribes audio to text |
| MP3 | `.mp3` | ⭐⭐⭐⭐ | **Yes (speech-to-text)** | Transcribes audio to text |

## Web / Special

| Format | Extension(s) | Quality | LLM Needed? | Notes |
|--------|-------------|---------|-------------|-------|
| URLs | `http://`, `https://` | ⭐⭐⭐⭐ | No | Fetches and converts web pages |
| YouTube | YouTube URLs | ⭐⭐⭐⭐ | No | Extracts transcript + metadata |

## When `--llm` Helps Most

1. **Scanned PDFs** — Image-only scans with no selectable text → LLM reads the images
2. **Complex PDF layouts** — Multi-column academic papers, forms with boxes → LLM interprets structure
3. **Image files** — Any `.jpg`/`.png` → LLM describes what's in the image
4. **Mixed PDFs** — Combination of text + charts/diagrams → LLM fills in the visual elements

## Not Supported

- `.zip` / archive files (extract first)
- `.mp4` / video files (extract audio first with ffmpeg, then use audio conversion)
- Encrypted/password-protected files (decrypt first)
- Proprietary formats: `.pages`, `.numbers`, `.key` (export to PDF/DOCX first from macOS)
