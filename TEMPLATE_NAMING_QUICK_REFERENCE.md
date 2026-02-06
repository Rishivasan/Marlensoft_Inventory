# Template Naming - Quick Reference

## Template Name Format
```
{Code} - {Product} - {MSI} - {Material}
```

## Validation Type Codes
| Type | Code |
|------|------|
| Incoming Goods Validation | **IG** |
| In-progress Validation | **IP** |
| Final Inspection | **FI** |

## Examples
```
IG - Circuit Breaker - MSI-001 - Steel Sheet
IP - Power Supply - MSI-010 - Sensor Chip
FI - Voltage Regulator - MSI-020 - Circuit Board
```

## Required Fields
All three fields must be selected before creating a template:
- ✅ Validation Type
- ✅ Final Product
- ✅ Material/Component

## Testing
```powershell
# Test the template naming
.\test_template_naming.ps1

# Test templates API
.\test_templates_api.ps1
```

## Files Changed
1. `Frontend/inventory/lib/services/quality_service.dart`
   - Added `getTemplates()` method

2. `Frontend/inventory/lib/screens/qc_template_screen.dart`
   - Added validation type code mapping
   - Updated material loading to include MSI codes
   - Implemented auto-generated template names
   - Added material/component validation
   - Removed hardcoded templates

## Key Features
✅ Templates load from database
✅ Names auto-generated from form data
✅ MSI codes included in template names
✅ Validation type codes (IG/IP/FI)
✅ All fields validated before creation
✅ Real-time template list updates
