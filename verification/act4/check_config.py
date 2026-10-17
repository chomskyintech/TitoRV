#!/usr/bin/env python3
"""Guard the TitoRV ACT4 candidate configuration's syntax and declared scope.

This is deliberately not an ACT4/UDB/Sail semantic validator.
"""
import json
from pathlib import Path
import sys

import yaml

root = Path(__file__).resolve().parent
errors = []

def require(condition, message):
    if not condition:
        errors.append(message)

try:
    framework = yaml.safe_load((root / "test_config.yaml").read_text())
    udb = yaml.safe_load((root / "titorv-rv32i.yaml").read_text())
    sail = json.loads((root / "sail.json").read_text())
except Exception as exc:
    print(f"ACT4 config syntax check failed: {exc}", file=sys.stderr)
    sys.exit(1)

require(framework.get("name") == "titorv-rv32i", "unexpected framework config name")
require(framework.get("udb_config") == "titorv-rv32i.yaml", "framework config must reference titorv-rv32i.yaml")
require(framework.get("linker_script") == "link.ld", "framework config must reference link.ld")
require(framework.get("dut_include_dir") == ".", "DUT include directory must be the ACT4 folder")
require(framework.get("include_priv_tests") is False, "privileged tests must remain disabled")
require(framework.get("harts", 1) == 1, "this RTL target is single-hart")

require(udb.get("$schema") == "config_schema.json#", "UDB schema marker missing")
require(udb.get("kind") == "architecture configuration", "UDB kind mismatch")
require(udb.get("type") == "fully configured", "UDB config must be fully configured")
require(udb.get("name") == "titorv-rv32i", "UDB config name mismatch")
extensions = udb.get("implemented_extensions", [])
require([ext.get("name") for ext in extensions] == ["I"], "candidate must declare only base I until more extensions are validated")
require(bool(extensions) and extensions[0].get("version") == "= 2.1", "unexpected base I extension version")
require(udb.get("params") == {}, "review the UDB params before expanding the candidate scope")

require(sail.get("$schema", "").endswith("/0.16/sail_riscv_config_schema.json"), "Sail config must target schema version 0.16")
require(sail.get("base", {}).get("xlen") == 32, "Sail XLEN must be 32")
require(sail.get("base", {}).get("E") is False, "Sail E profile must be disabled for RV32I")
for filename in ("link.ld", "rvmodel_macros.h", "termination_smoke.S"):
    require((root / filename).is_file(), f"missing required adapter file: {filename}")

if errors:
    print("ACT4 config sanity check failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("ACT4 config syntax/scope sanity checks passed.")
print("NOTE: This does not validate UDB semantics, Sail schema compatibility, ACT4 test selection, or DUT compliance.")
