"""Validate OpenAPI and the recorded, real HTTP curation response."""
import json
from pathlib import Path
from openapi_spec_validator import validate
from jsonschema import Draft4Validator

ROOT = Path(__file__).resolve().parents[1]
spec = json.loads((ROOT / "docs/openapi.json").read_text())
validate(spec)
schema = spec["paths"]["/home/curation"]["get"]["responses"]["200"]["content"]["application/json"]["schema"]
schema = {**schema, "components": spec["components"]}
payload = json.loads((ROOT / "docs/evidence/curation.json").read_text())
Draft4Validator(schema).validate(payload)
assert len(payload["data"]["collections"]) == 4
assert payload["data"]["current_exhibitions"][0]["hero_artwork"]["media"][0]["url"].endswith("/storage/demo/landscape.jpg")
print("PASS: OpenAPI 3.0.3 structure and live curation response contract")
