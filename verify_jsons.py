#!/usr/bin/env python3
"""
JSON Configuration Verification Script
Validates JSON files against schemas and ensures compliance.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Tuple
import jsonschema
from jsonschema import validate, ValidationError


class JSONVerifier:
    """Verifies JSON configuration files for schema compliance."""
    
    def __init__(self, config_dir: str = "config/json"):
        self.config_dir = Path(config_dir)
        self.errors: List[str] = []
        self.warnings: List[str] = []
        
    def load_json_file(self, filepath: Path) -> Tuple[Dict, bool]:
        """Load a JSON file and return its contents."""
        try:
            with open(filepath, 'r') as f:
                data = json.load(f)
            return data, True
        except json.JSONDecodeError as e:
            self.errors.append(f"❌ {filepath}: Invalid JSON - {str(e)}")
            return {}, False
        except Exception as e:
            self.errors.append(f"❌ {filepath}: Error reading file - {str(e)}")
            return {}, False
    
    def validate_schema(self, data: Dict, schema: Dict, filename: str) -> bool:
        """Validate JSON data against a schema."""
        try:
            validate(instance=data, schema=schema)
            return True
        except ValidationError as e:
            self.errors.append(f"❌ {filename}: Schema validation failed - {e.message}")
            return False
        except Exception as e:
            self.errors.append(f"❌ {filename}: Validation error - {str(e)}")
            return False
    
    def get_basic_schema(self, filename: str) -> Dict:
        """Return appropriate schema based on filename."""
        # Define basic schemas for common config files
        schemas = {
            "ports.json": {
                "type": "object",
                "properties": {
                    "approved_port": {"type": "integer", "minimum": 1024, "maximum": 65535},
                    "protocol": {"type": "string", "enum": ["tcp", "udp"]},
                    "description": {"type": "string"}
                },
                "required": ["approved_port"]
            },
            "default": {
                "type": "object"
            }
        }
        
        return schemas.get(filename, schemas["default"])
    
    def verify_all(self) -> bool:
        """Verify all JSON files in the configuration directory."""
        if not self.config_dir.exists():
            self.errors.append(f"❌ Configuration directory not found: {self.config_dir}")
            return False
        
        json_files = list(self.config_dir.glob("*.json"))
        
        if not json_files:
            self.warnings.append(f"⚠️  No JSON files found in {self.config_dir}")
            return True
        
        print(f"🔍 Verifying {len(json_files)} JSON file(s)...")
        
        all_valid = True
        for filepath in json_files:
            data, loaded = self.load_json_file(filepath)
            if not loaded:
                all_valid = False
                continue
            
            # Get schema and validate
            schema = self.get_basic_schema(filepath.name)
            if not self.validate_schema(data, schema, filepath.name):
                all_valid = False
            else:
                print(f"✅ {filepath.name}: Valid")
        
        return all_valid
    
    def print_results(self) -> None:
        """Print verification results."""
        if self.warnings:
            print("\nWarnings:")
            for warning in self.warnings:
                print(f"  {warning}")
        
        if self.errors:
            print("\nErrors:")
            for error in self.errors:
                print(f"  {error}")
        
        if not self.errors and not self.warnings:
            print("\n✅ All JSON files are valid!")
    
    def get_error_count(self) -> int:
        """Return the number of errors found."""
        return len(self.errors)


def main():
    """Main execution function."""
    config_dir = os.getenv("CONFIG_DIR", "config/json")
    
    verifier = JSONVerifier(config_dir)
    success = verifier.verify_all()
    verifier.print_results()
    
    if not success:
        print(f"\n❌ Verification failed with {verifier.get_error_count()} error(s)")
        sys.exit(1)
    else:
        print("\n✅ Verification completed successfully")
        sys.exit(0)


if __name__ == "__main__":
    main()
