# BOM Master Navigation to QC Customization

## Navigation Setup

### Sidebar Configuration
- **BOM Master** is at index **2** in the sidebar
- **Icon**: `assets/images/link.svg`
- **Label**: "BOM Master"

### Navigation Logic (dashboard_body.dart)
```dart
case 2:
  ref.read(headerProvider.notifier).state = const HeaderModel(
    title: "Quality Check Customization",
    subtitle: "Configure quality control templates and inspection points for BOM Master",
  );
  // Navigate to QC Template Screen directly
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const QCTemplateScreen()),
  );
  break;
```

### Expected Behavior
1. User clicks on **BOM Master** icon in sidebar
2. Header updates to "Quality Check Customization"
3. App navigates to **QC Template Screen**
4. User can create/manage QC templates and control points

### QC Template Screen Features
- ✅ Create QC templates
- ✅ Add control points (Measure, Visual Inspection, Take a Picture)
- ✅ Dynamic form fields based on control point type
- ✅ File upload functionality
- ✅ Units from UnitMaster table

## Testing Steps
1. Open the Flutter app
2. Click on the **BOM Master** icon (3rd icon in sidebar)
3. Verify navigation to QC Template Screen
4. Test adding control points with different types
5. Verify form behavior changes based on selected type