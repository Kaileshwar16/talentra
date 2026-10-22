#!/usr/bin/env python3
"""Export the fifteen Stage 1 Markdown documents to genuine Excel 97-2003 files."""

from __future__ import annotations

import argparse
import html
import re
import shutil
import subprocess
import tempfile
import zipfile
from pathlib import Path

import xlsxwriter


ROOT = Path(__file__).resolve().parent
PHASES = (
    "01-requirements",
    "02-stakeholders",
    "03-features",
    "04-nfr",
    "05-workflows",
)
DOCUMENTS = (
    "output-schema.md",
    "schema-rating-scorecard.md",
    "output-document.md",
)
OUTPUT = ROOT / "spreadsheets"


def plain(value: str) -> str:
    """Keep readable link labels and text while removing Markdown syntax."""
    value = re.sub(r"\[([^]]+)\]\([^)]+\)", r"\1", value)
    value = re.sub(r"(?<!\w)(\*\*|__)(.*?)(\*\*|__)(?!\w)", r"\2", value)
    value = re.sub(r"`([^`]+)`", r"\1", value)
    return html.unescape(value.replace("\\|", "|").strip())


def split_row(line: str) -> list[str]:
    return [plain(cell) for cell in re.split(r"(?<!\\)\|", line.strip().strip("|"))]


def is_rule(line: str) -> bool:
    cells = split_row(line)
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", c.strip()) for c in cells)


def parse_document(source: Path) -> tuple[str, list[tuple], list[tuple]]:
    lines = source.read_text(encoding="utf-8").splitlines()
    title = plain(lines[0].lstrip("# "))
    items: list[tuple] = []
    tables: list[tuple] = []
    current_section = "Introduction"
    i = 1
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        heading = re.match(r"^(#{2,6})\s+(.+)$", line)
        if heading:
            current_section = plain(heading.group(2))
            items.append(("heading", len(heading.group(1)), current_section))
            i += 1
            continue
        if line.startswith("```"):
            kind = line[3:].strip() or "Code"
            block = []
            i += 1
            while i < len(lines) and not lines[i].startswith("```"):
                block.append(lines[i])
                i += 1
            items.append(("code", current_section, kind, block))
            i += 1
            continue
        if line.startswith("|") and i + 1 < len(lines) and is_rule(lines[i + 1]):
            header = split_row(lines[i])
            rows = []
            i += 2
            while i < len(lines) and lines[i].strip().startswith("|"):
                cells = split_row(lines[i])
                rows.append((cells + [""] * len(header))[: len(header)])
                i += 1
            tables.append((current_section, header, rows))
            items.append(("table", len(tables) - 1, current_section, len(rows)))
            continue
        paragraph = [line]
        i += 1
        while i < len(lines) and lines[i].strip() and not re.match(r"^#{2,6}\s+", lines[i]) and not lines[i].startswith("```") and not lines[i].strip().startswith("|"):
            paragraph.append(lines[i].strip())
            i += 1
        items.append(("text", plain(" ".join(paragraph))))
    return title, items, tables


def unique_sheet_name(section: str, used: set[str]) -> str:
    base = re.sub(r"[\[\]:*?/\\]", "", section).strip(" '")[:27] or "Table"
    name = base
    number = 2
    while name.casefold() in used:
        suffix = f" {number}"
        name = base[: 31 - len(suffix)] + suffix
        number += 1
    used.add(name.casefold())
    return name


def row_height(value: str, width: int = 105) -> int:
    # A conservative estimate; wrapping remains enabled if Calc uses different fonts.
    lines = sum(max(1, (len(part) + width - 1) // width) for part in value.split("\n"))
    return min(210, max(25, 17 * lines + 8))


def make_workbook(source: Path, target: Path) -> tuple[int, int]:
    title, items, tables = parse_document(source)
    workbook = xlsxwriter.Workbook(str(target))
    workbook.set_properties({"title": title, "subject": "Talentra Stage 1 discovery", "comments": f"Exported from {source.relative_to(ROOT)}"})
    navy, blue, pale, muted = "#17324D", "#166C9C", "#EAF3F8", "#536779"
    title_fmt = workbook.add_format({"bold": True, "font_size": 17, "font_color": "#FFFFFF", "bg_color": navy, "valign": "vcenter"})
    meta_fmt = workbook.add_format({"font_size": 10, "font_color": muted, "italic": True})
    heading_fmt = workbook.add_format({"bold": True, "font_size": 12, "font_color": navy, "bg_color": pale, "valign": "vcenter"})
    subheading_fmt = workbook.add_format({"bold": True, "font_size": 11, "font_color": blue, "valign": "vcenter"})
    body_fmt = workbook.add_format({"text_wrap": True, "valign": "top", "font_size": 10})
    link_fmt = workbook.add_format({"font_color": blue, "underline": 1, "text_wrap": True, "valign": "top"})
    table_head = workbook.add_format({"bold": True, "font_color": "#FFFFFF", "bg_color": navy, "text_wrap": True, "valign": "vcenter", "border": 1, "border_color": "#CFDEE8"})
    table_cell = workbook.add_format({"text_wrap": True, "valign": "top", "border": 1, "border_color": "#DBE5EC"})
    table_alt = workbook.add_format({"text_wrap": True, "valign": "top", "bg_color": "#F5F9FC", "border": 1, "border_color": "#DBE5EC"})

    overview = workbook.add_worksheet("Overview")
    overview.hide_gridlines(2)
    overview.set_zoom(90)
    overview.set_column("A:A", 3)
    overview.set_column("B:H", 17)
    overview.set_column("I:I", 3)
    overview.set_landscape()
    overview.fit_to_pages(1, 0)
    overview.set_margins(0.3, 0.3, 0.4, 0.4)
    overview.merge_range("B2:H3", title, title_fmt)
    overview.merge_range("B4:H4", f"Source: {source.relative_to(ROOT)}  |  Tables: {len(tables)}", meta_fmt)
    overview.freeze_panes(5, 0)
    used = {"overview"}
    sheet_names = [unique_sheet_name(section, used) for section, _, _ in tables]
    row = 5
    diagram_blocks = []
    for item in items:
        kind = item[0]
        if kind == "heading":
            _, level, label = item
            fmt = heading_fmt if level == 2 else subheading_fmt
            overview.merge_range(row, 1, row, 7, label, fmt)
            overview.set_row(row, 28 if level == 2 else 24)
            row += 2 if level == 2 else 1
        elif kind == "text":
            value = item[1]
            overview.merge_range(row, 1, row, 7, value, body_fmt)
            overview.set_row(row, row_height(value))
            row += 2
        elif kind == "table":
            _, index, section, count = item
            label = f"Open table: {section} ({count} rows)"
            overview.merge_range(row, 1, row, 7, "", link_fmt)
            overview.write_url(row, 1, f"internal:'{sheet_names[index]}'!A1", link_fmt, label)
            overview.set_row(row, 25)
            row += 2
        elif kind == "code":
            _, section, language, lines = item
            diagram_blocks.append((section, language, lines))
            label = f"{section}: diagram source is on the Diagrams sheet"
            overview.merge_range(row, 1, row, 7, label, meta_fmt)
            overview.set_row(row, 25)
            row += 2

    for index, (section, header, records) in enumerate(tables):
        sheet = workbook.add_worksheet(sheet_names[index])
        sheet.hide_gridlines(2)
        sheet.set_zoom(85)
        sheet.set_landscape()
        sheet.fit_to_pages(1, 0)
        sheet.set_margins(0.25, 0.25, 0.4, 0.4)
        sheet.freeze_panes(4, 1)
        last_col = len(header) - 1
        sheet.merge_range(0, 0, 1, last_col, section, title_fmt) if last_col > 0 else sheet.write(0, 0, section, title_fmt)
        sheet.write_url(2, 0, "internal:'Overview'!B2", link_fmt, "← Overview")
        widths = []
        for col, heading in enumerate(header):
            values = [heading] + [record[col] for record in records]
            max_len = max((len(v) for v in values), default=12)
            width = max(14, min(52, max_len + 3))
            if col == 0:
                width = max(17, min(36, width))
            widths.append(width)
            sheet.set_column(col, col, width)
            sheet.write(3, col, heading, table_head)
        sheet.set_row(3, 37)
        for ridx, record in enumerate(records, 4):
            max_lines = 1
            for col, value in enumerate(record):
                sheet.write_string(ridx, col, value, table_cell if ridx % 2 == 0 else table_alt)
                max_lines = max(max_lines, (len(value) + int(widths[col]) - 1) // int(widths[col]))
            sheet.set_row(ridx, min(175, max(25, 17 * max_lines + 8)))
        if records:
            sheet.autofilter(3, 0, 3 + len(records), last_col)
        sheet.repeat_rows(0, 3)

    if diagram_blocks:
        diagrams = workbook.add_worksheet("Diagrams")
        diagrams.hide_gridlines(2)
        diagrams.set_column("A:A", 33)
        diagrams.set_column("B:B", 20)
        diagrams.set_column("C:C", 100)
        diagrams.write_row(0, 0, ["Section", "Diagram type", "Diagram line"], table_head)
        diagram_row = 1
        for section, language, lines in diagram_blocks:
            for line in lines:
                diagrams.write_row(diagram_row, 0, [section, language, line], table_cell)
                diagram_row += 1
        diagrams.freeze_panes(1, 0)
        diagrams.autofilter(0, 0, diagram_row - 1, 2)
    workbook.close()
    return len(tables), len(diagram_blocks)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    sources = [ROOT / phase / doc for phase in PHASES for doc in DOCUMENTS]
    missing = [source for source in sources if not source.is_file()]
    if missing:
        raise SystemExit("Missing source documents: " + ", ".join(map(str, missing)))
    if shutil.which("libreoffice") is None:
        raise SystemExit("LibreOffice is required to create genuine .xls files")
    summary = []
    with tempfile.TemporaryDirectory(prefix="talentra-stage1-") as tmp:
        intermediate = Path(tmp) / "xlsx"
        intermediate.mkdir()
        for source in sources:
            stem = f"{source.parent.name}-{source.stem}"
            table_count, diagram_count = make_workbook(source, intermediate / f"{stem}.xlsx")
            summary.append((source, stem, table_count, diagram_count))
        command = [
            "libreoffice", f"-env:UserInstallation={(Path(tmp) / 'lo-profile').as_uri()}",
            "--headless", "--convert-to", "xls:MS Excel 97", "--outdir", str(output),
            *[str(intermediate / f"{stem}.xlsx") for _, stem, _, _ in summary],
        ]
        result = subprocess.run(command, text=True, capture_output=True, check=False, timeout=180)
        if result.returncode:
            raise SystemExit(f"LibreOffice conversion failed ({result.returncode}): {result.stdout}\n{result.stderr}")
    for _, stem, _, _ in summary:
        target = output / f"{stem}.xls"
        if not target.exists() or target.read_bytes()[:8] != bytes.fromhex("d0cf11e0a1b11ae1"):
            raise SystemExit(f"Excel 97-2003 format verification failed: {target}")
    index = [
        "# Stage 1 spreadsheets",
        "",
        "Each Excel 97–2003 workbook corresponds to one source document. Open Overview first; its links lead to filterable table sheets. Mermaid diagram source is retained on a Diagrams sheet where present.",
        "",
        "| Phase | Document | Excel workbook | Tables |",
        "| --- | --- | --- | ---: |",
    ]
    for source, stem, table_count, _ in summary:
        index.append(f"| {source.parent.name} | [{source.name}](../{source.parent.name}/{source.name}) | [{stem}.xls]({stem}.xls) | {table_count} |")
    index.extend(["", "Regenerate with `python3 lifecycle/01-discover/export_spreadsheets.py` from the repository root.", ""])
    (output / "README.md").write_text("\n".join(index), encoding="utf-8")
    with zipfile.ZipFile(output / "stage1-spreadsheets.zip", "w", zipfile.ZIP_DEFLATED) as archive:
        for _, stem, _, _ in summary:
            archive.write(output / f"{stem}.xls", f"{stem}.xls")
    print(f"Created {len(summary)} Excel 97-2003 workbooks in {output}")
    for source, stem, table_count, diagram_count in summary:
        print(f"  {stem}.xls: {table_count} table sheets, {diagram_count} diagram blocks")


if __name__ == "__main__":
    main()
