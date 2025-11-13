#!/usr/bin/env python3
"""Helper to parse tilefirst-opt style help text for Zsh completions.

This script executes the configured optimizer command with ``--help``,
parses the textual option listing, and emits structured data for the
Zsh completion wrapper.  Results are cached on disk and invalidated when
the optimizer binary changes.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional


ENTRY_SEP = "\0"
FIELD_SEP = "\x1f"
DEFAULT_COMMAND = "tilefirst-opt"
CACHE_BASENAME = "mlir_opt_comp_cache.json"


@dataclass
class Choice:
    value: str
    description: str


@dataclass
class OptionRecord:
    name: str
    insert_text: str
    style: str  # flag | attached | separate
    description: str
    value_hint: str = ""
    choices: List[Choice] = field(default_factory=list)


def sanitize(text: str) -> str:
    text = text.strip()
    text = re.sub(r"\s+", " ", text)
    return text.replace(FIELD_SEP, " ")


def find_command(cmd: str) -> str:
    if os.path.isabs(cmd) and os.access(cmd, os.X_OK):
        return cmd
    resolved = shutil.which(cmd)
    if resolved:
        return resolved
    raise FileNotFoundError(f"Unable to locate command '{cmd}'")


def cache_path() -> Path:
    base = os.environ.get("XDG_CACHE_HOME", os.path.join(Path.home(), ".cache"))
    return Path(base) / CACHE_BASENAME


def load_cache(path: Path) -> Optional[Dict[str, Any]]:
    try:
        with path.open("r", encoding="utf-8") as fh:
            return json.load(fh)
    except Exception:
        return None


def save_cache(path: Path, payload: dict) -> None:
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        tmp_path = path.with_suffix(".tmp")
        with tmp_path.open("w", encoding="utf-8") as fh:
            json.dump(payload, fh)
        tmp_path.replace(path)
    except Exception:
        pass


def run_help(binary: str) -> str:
    try:
        completed = subprocess.run(
            [binary, "--help"],
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError as exc:
        raise FileNotFoundError(f"Command '{binary}' not found") from exc
    except subprocess.CalledProcessError as exc:
        raise RuntimeError(
            f"Failed to execute '{binary} --help' (exit code {exc.returncode})"
        ) from exc
    return completed.stdout


def parse_help(text: str) -> List[OptionRecord]:
    options: List[OptionRecord] = []
    option_index: Dict[str, OptionRecord] = {}
    current: Optional[OptionRecord] = None
    last_type: Optional[str] = None

    lines = text.splitlines()
    for raw_line in lines:
        stripped = raw_line.lstrip()
        if not stripped:
            last_type = "blank"
            continue

        if stripped.startswith("="):
            if current is None:
                continue
            value_part, _, desc_part = stripped.partition("-")
            value = sanitize(value_part.lstrip("=") )
            desc = sanitize(desc_part)
            if value:
                current.choices.append(Choice(value=value, description=desc))
            last_type = "choice"
            continue

        if not stripped.startswith("-"):
            current = None
            last_type = "other"
            continue

        before_desc, sep, after_desc = stripped.partition(" - ")
        if not sep:
            current = None
            last_type = "other"
            continue

        option_part = before_desc.strip()
        description = sanitize(after_desc)
        if not option_part:
            continue

        tokens = option_part.split()
        token = tokens[0]
        remainder = option_part[len(token):].strip()

        style = "flag"
        insert_text = token
        name = token
        value_hint = ""

        if "=" in token:
            name, _, tail = token.partition("=")
            name = name.rstrip("[")
            style = "attached"
            insert_text = f"{name}="
            tail = tail.rstrip("]")
            if tail:
                value_hint = tail
            elif remainder.startswith("<"):
                value_hint = remainder.split()[0]
        elif remainder.startswith("<"):
            style = "separate"
            insert_text = name
            value_hint = remainder.split()[0]

        name = name.rstrip(",")
        if not name:
            continue

        if name in option_index:
            current = option_index[name]
            if description and not current.description:
                current.description = description
            last_type = "option"
            continue

        record = OptionRecord(
            name=name,
            insert_text=insert_text,
            style=style,
            description=description,
            value_hint=value_hint,
        )
        if name.startswith("--affine") or name=="--mode":
          option_index[name] = record
          options.append(record)
        current = record
        last_type = "option"
        continue

    return options


def build_payload(binary: str) -> Dict[str, Any]:
    help_text = run_help(binary)
    options = parse_help(help_text)
    return {
        "options": [
            {
                "name": opt.name,
                "insert_text": opt.insert_text,
                "style": opt.style,
                "description": opt.description,
                "value_hint": opt.value_hint,
                "choices": [
                    {"value": choice.value, "description": choice.description}
                    for choice in opt.choices
                ],
            }
            for opt in options
        ]
    }


def get_data(binary: str, use_cache: bool = True) -> Dict[str, Any]:
    cache_file = cache_path()
    cache = load_cache(cache_file) if use_cache else None
    mtime = None
    try:
        mtime = os.path.getmtime(binary)
    except OSError:
        mtime = None

    if (
        cache
        and cache.get("binary") == binary
        and cache.get("mtime") == mtime
        and "payload" in cache
    ):
        return cache["payload"]

    payload = build_payload(binary)

    if use_cache:
        save_cache(
            cache_file,
            {
                "binary": binary,
                "mtime": mtime,
                "payload": payload,
            },
        )

    return payload


def emit_entries(entries: Iterable[List[str]]):
    chunks = [FIELD_SEP.join(parts) for parts in entries]
    sys.stdout.write(ENTRY_SEP.join(chunks))


def cmd_list_options(data: dict):
    entries = []
    for opt in data.get("options", []):
        desc = opt.get("description") or opt["name"]
        value_hint = opt.get("value_hint", "")
        entries.append(
            [
                opt["name"],
                opt["insert_text"],
                opt["style"],
                desc,
                value_hint,
            ]
        )
    emit_entries(entries)


def cmd_list_values(data: dict, option_name: str):
    for opt in data.get("options", []):
        if opt["name"] == option_name:
            entries = [
                [choice["value"], choice.get("description", "")]
                for choice in opt.get("choices", [])
            ]
            emit_entries(entries)
            return
    emit_entries([])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "mode",
        choices=["list-options", "list-values", "clean-cache"],
    )
    parser.add_argument("option", nargs="?")
    parser.add_argument("--cmd", dest="cmd")
    parser.add_argument("--no-cache", action="store_true")
    return parser.parse_args()


def cmd_clean_cache() -> int:
    path = cache_path()
    try:
        path.unlink()
        return 0
    except FileNotFoundError:
        return 0
    except OSError as exc:
        print(f"failed to remove cache: {exc}", file=sys.stderr)
        return 1


def main() -> int:
    args = parse_args()
    if args.mode == "clean-cache":
        return cmd_clean_cache()

    command = (
        args.cmd
        or os.environ.get("MLIR_OPT_COMP_CMD")
        or DEFAULT_COMMAND
    )
    try:
        binary = find_command(command)
    except FileNotFoundError:
        return 0

    try:
        data = get_data(binary, use_cache=not args.no_cache)
    except Exception as exc:
        print(exc, file=sys.stderr)
        return 1

    if args.mode == "list-options":
        cmd_list_options(data)
    elif args.mode == "list-values":
        if not args.option:
            return 1
        cmd_list_values(data, args.option)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
