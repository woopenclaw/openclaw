#!/usr/bin/env python3
"""
doc2md.py — Convert documents to LLM-ready markdown using markitdown.

Usage:
    python3 doc2md.py <file_path> [--output OUT.md] [--llm | --auto-llm] [--preview N]

Arguments:
    file_path       Path to the document to convert
    --output PATH   Write markdown to PATH instead of stdout
    --llm           Use LLM-enhanced conversion immediately
    --auto-llm      Retry with LLM if normal conversion is empty or too short
    --preview N     Print only first N characters of output
"""

import argparse
import io
import re
import sys
from contextlib import redirect_stderr
from pathlib import Path


SUPPORTED_EXTENSIONS = {
    ".csv",
    ".doc",
    ".docx",
    ".epub",
    ".gif",
    ".htm",
    ".html",
    ".jpeg",
    ".jpg",
    ".json",
    ".mp3",
    ".pdf",
    ".png",
    ".ppt",
    ".pptx",
    ".wav",
    ".webp",
    ".xls",
    ".xlsx",
    ".xml",
}
LLM_RECOMMENDED_EXTENSIONS = {".gif", ".jpeg", ".jpg", ".mp3", ".png", ".wav", ".webp"}

DEFAULT_MAX_BYTES = 50 * 1024 * 1024
AUTO_LLM_MIN_CHARS = 200
DEFAULT_USE_LLM = True
MAX_PREVIEW_CHARS = 700

PDF_NOISE_PATTERNS = [
    r"These materials are © .*?strictly prohibited\.",
]

PDF_PREVIEW_START_MARKERS = [
    "Table of Contents",
    "INTRODUCTION",
    "CHAPTER 1",
    "Introduction",
]


class ConversionError(Exception):
    """Raised for user-facing conversion failures."""


def clean_markdown(markdown: str) -> str:
    """Normalize common markdown noise without changing document meaning."""
    markdown = markdown.replace("\r\n", "\n").replace("\r", "\n")
    markdown = markdown.replace("\f", "\n\n")
    markdown = markdown.replace("\u00a0", " ")
    markdown = "\n".join(line.rstrip() for line in markdown.split("\n"))
    markdown = re.sub(r"\n{4,}", "\n\n\n", markdown)
    return markdown.strip() + "\n"


def clean_pdf_markdown(markdown: str) -> str:
    """Remove common PDF extraction artifacts while keeping document content intact."""
    text = markdown
    for pattern in PDF_NOISE_PATTERNS:
        text = re.sub(pattern, "", text, flags=re.IGNORECASE | re.DOTALL)

    lines = text.splitlines()
    cleaned_lines = []
    previous_normalized = None
    for line in lines:
        normalized = re.sub(r"\s+", " ", line).strip()
        if normalized and normalized == previous_normalized:
            continue
        cleaned_lines.append(line)
        previous_normalized = normalized or previous_normalized

    text = "\n".join(cleaned_lines)
    text = re.sub(r"\n{4,}", "\n\n\n", text)
    return text.strip() + "\n"


def smart_preview(markdown: str, max_chars: int = MAX_PREVIEW_CHARS) -> str:
    """Prefer a meaningful excerpt over a raw first-N-characters slice."""
    text = markdown.strip()
    if len(text) <= max_chars:
        return text

    start = 0
    for marker in PDF_PREVIEW_START_MARKERS:
        idx = text.find(marker)
        if idx != -1:
            start = idx
            break

    snippet = text[start : start + max_chars].strip()
    if start > 0:
        snippet = "…\n" + snippet
    if start + max_chars < len(text):
        snippet += "\n…"
    return snippet


def build_converter(use_llm: bool, llm_model: str):
    try:
        from markitdown import MarkItDown
    except ImportError:
        raise ConversionError(
            "markitdown is not installed. Run: python3 -m pip install markitdown"
        ) from None

    if not use_llm:
        return MarkItDown()

    try:
        import openai
    except ImportError:
        raise ConversionError(
            "LLM mode requires the openai package. Run: python3 -m pip install openai"
        ) from None

    try:
        client = openai.OpenAI()
    except Exception as exc:
        raise ConversionError(f"Could not initialize OpenAI client for LLM mode: {exc}") from exc

    return MarkItDown(llm_client=client, llm_model=llm_model)


def validate_input(path: Path, max_bytes: int) -> None:
    if not path.exists():
        raise ConversionError(f"File not found: {path}")

    if not path.is_file():
        raise ConversionError(f"Not a file: {path}")

    if path.suffix.lower() not in SUPPORTED_EXTENSIONS:
        supported = ", ".join(sorted(SUPPORTED_EXTENSIONS))
        raise ConversionError(f"Unsupported file type '{path.suffix}'. Supported: {supported}")

    size = path.stat().st_size
    if size > max_bytes:
        mb = max_bytes // (1024 * 1024)
        raise ConversionError(f"File is too large for conversion (>{mb}MB)")


def convert_once(path: Path, use_llm: bool, llm_model: str) -> str:
    md = build_converter(use_llm=use_llm, llm_model=llm_model)
    try:
        stderr_buffer = io.StringIO()
        with redirect_stderr(stderr_buffer):
            result = md.convert(str(path))
    except Exception as exc:
        mode = "LLM" if use_llm else "standard"
        raise ConversionError(f"{mode} conversion failed: {exc}") from exc

    markdown = clean_markdown(result.text_content or "")
    if path.suffix.lower() == ".pdf":
        markdown = clean_pdf_markdown(markdown)
    return markdown


def convert(
    file_path: str,
    use_llm: bool = DEFAULT_USE_LLM,
    auto_llm: bool = False,
    llm_model: str = "gpt-4o",
    max_bytes: int = DEFAULT_MAX_BYTES,
) -> str:
    """Convert a document to markdown using markitdown."""
    path = Path(file_path)
    validate_input(path, max_bytes=max_bytes)

    markdown = convert_once(path, use_llm=use_llm, llm_model=llm_model)
    should_retry = auto_llm and not use_llm and (
        len(markdown.strip()) < AUTO_LLM_MIN_CHARS
        or path.suffix.lower() in LLM_RECOMMENDED_EXTENSIONS
    )
    if should_retry:
        print("Standard conversion was empty or very short; retrying with LLM mode.", file=sys.stderr)
        markdown = convert_once(path, use_llm=True, llm_model=llm_model)

    if not markdown.strip():
        raise ConversionError(
            "Conversion produced empty output. The file may be encrypted, corrupted, or image-only."
        )

    return markdown


def main():
    parser = argparse.ArgumentParser(
        description="Convert documents to LLM-ready markdown using markitdown"
    )
    parser.add_argument("file_path", help="Path to the document to convert")
    parser.add_argument(
        "--output",
        "-o",
        type=Path,
        default=None,
        help="Write markdown to this path instead of stdout",
    )
    llm_group = parser.add_mutually_exclusive_group()
    llm_group.add_argument(
        "--llm",
        dest="llm_mode",
        action="store_const",
        const="llm",
        help="Use LLM-enhanced conversion immediately (default)",
    )
    llm_group.add_argument(
        "--auto-llm",
        dest="llm_mode",
        action="store_const",
        const="auto",
        help="Retry with LLM mode if standard conversion is empty or very short",
    )
    llm_group.add_argument(
        "--no-llm",
        dest="llm_mode",
        action="store_const",
        const="none",
        help="Force standard conversion without LLM enhancement",
    )
    parser.set_defaults(llm_mode="llm")
    parser.add_argument(
        "--llm-model",
        default="gpt-4o",
        help="LLM model name to pass to markitdown (default: gpt-4o)",
    )
    parser.add_argument(
        "--max-bytes",
        type=int,
        default=DEFAULT_MAX_BYTES,
        help="Maximum input file size in bytes (default: 52428800)",
    )
    parser.add_argument(
        "--preview",
        type=int,
        metavar="N",
        default=None,
        help="Print only first N characters of output",
    )

    args = parser.parse_args()

    try:
        markdown = convert(
            args.file_path,
            use_llm=args.llm_mode == "llm",
            auto_llm=args.llm_mode == "auto",
            llm_model=args.llm_model,
            max_bytes=args.max_bytes,
        )
    except ConversionError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)

    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(markdown, encoding="utf-8")
        if args.preview is not None:
            print(smart_preview(markdown, args.preview), end="")
    else:
        if args.preview is not None:
            markdown = smart_preview(markdown, args.preview)
        print(markdown, end="")


if __name__ == "__main__":
    main()
