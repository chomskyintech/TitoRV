#!/usr/bin/env python3
"""Guard the TitoRV ACT4 candidate configuration's syntax and declared scope.

This is deliberately not an ACT4/UDB/Sail semantic validator.
"""
import json5
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
    sail = json5.loads((root / "sail.json").read_text())
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
require([ext.get("name") for ext in extensions] == ["I", "Sm"], "candidate must declare base I and machine-mode Sm environment")
require(bool(extensions) and extensions[0].get("version") == "= 2.1", "unexpected base I extension version")
require(len(extensions) > 1 and extensions[1].get("version") == "= 1.12.0", "unexpected Sm extension version")
params = udb.get("params", {})
require(params.get("MXLEN") == 32, "UDB MXLEN must be 32")
require(params.get("PHYS_ADDR_WIDTH") == 32, "UDB physical address width must be 32")
require(params.get("M_MODE_ENDIANNESS") == "little", "UDB machine mode must be little-endian")
require(params.get("NUM_PMP_ENTRIES") == 0, "UDB PMP entry count must match TitoRV configuration")
require(params.get("MTVEC_MODES") == [0], "only direct mtvec mode is configured")

require(sail.get("$schema", "").endswith("/0.16/sail_riscv_config_schema.json"), "Sail config must target schema version 0.16")
require(sail.get("base", {}).get("xlen") == 32, "Sail XLEN must be 32")
require(sail.get("base", {}).get("E") is False, "Sail E profile must be disabled for RV32I")
sail_base = sail.get("base", {})
require(sail_base.get("mcountinhibit", {}).get("supported") is False, "Sail must not model mcountinhibit as implemented")
require(sail_base.get("writable_hpm_counters", {}).get("value") == "0x0", "Sail must not enable HPM counters")
require(sail_base.get("mtvec", {}).get("direct", {}).get("supported") is True, "Sail must support direct mtvec mode")
require(sail_base.get("mtvec", {}).get("vectored", {}).get("supported") is False, "Sail must not enable vectored mtvec dispatch")
memory_regions = sail.get("memory", {}).get("regions", [])
def region_value(region, field):
    value = region.get(field, {})
    if isinstance(value, dict):
        return int(value.get("value", "0"), 0) if isinstance(value.get("value"), str) else value.get("value")
    return int(value, 0) if isinstance(value, str) else value

require(any(region_value(region, "base") == 0 and region_value(region, "size") == 0x10000 for region in memory_regions),
        "Sail RAM must match TitoRV's 64 KiB zero-based test memory")
require(any(region_value(region, "base") == 0x20000000 and region_value(region, "size") == 0x1000 for region in memory_regions),
        "Sail completion MMIO must match the harness at 0x20000000")
for filename in ("link.ld", "rvmodel_macros.h", "termination_smoke.S"):
    require((root / filename).is_file(), f"missing required adapter file: {filename}")

if errors:
    print("ACT4 config sanity check failed:")
    for error in errors:
        print(f"- {error}")
    sys.exit(1)

print("ACT4 config syntax/scope sanity checks passed.")
print("NOTE: This does not validate UDB semantics, Sail schema compatibility, ACT4 test selection, or DUT compliance.")
