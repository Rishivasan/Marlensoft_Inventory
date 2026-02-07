# Drag-and-Drop Control Points Reordering

## Feature
Users can now reorder control points by dragging them using the existing 6-dot icon (⋮⋮) on the left side.

## Behavior

### For Untitled Template (Before Saving)
✅ **Drag-and-drop ENABLED**
- Grab the 6-dot icon and drag to reorder
- Control points can be moved up or down
- Order is saved when you click "Add new template"

### For Existing Templates (After Saving)
❌ **Drag-and-drop DISABLED**
- 6-dot icon is greyed out
- Control points cannot be reordered
- This prevents accidental changes to saved templates

## Implementation

### ReorderableListView for Untitled Template
```dart
ReorderableListView.builder(
  itemCount: controlPoints.length,
  onReorder: (oldIndex, newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      // Reorder in display list
      final item = controlPoints.removeAt(oldIndex);
      controlPoints.insert(newIndex, item);
      
      // Also reorder in temp list
      final tempItem = tempControlPoints.removeAt(oldIndex);
      tempControlPoints.insert(newIndex, tempItem);
    });
  },
  itemBuilder: (context, index) {
    return Container(
      key: ValueKey(point['id']), // Required!
      // ... rest of the UI
    );
  },
)
```

### Regular ListView for Existing Templates
```dart
ListView.builder(
  itemCount: controlPoints.length,
  itemBuilder: (context, index) {
    return Container(
      // No key needed
      // Drag icon is greyed out
      Icon(Icons.drag_indicator, color: Color(0xFFE5E7EB))
    );
  },
)
```

## User Experience

### Creating New Template
```
1. Click "Add new template"
2. Add control points:
   - Width Check
   - Photo
   - Visual Inspection
3. Drag "Photo" to top using 6-dot icon
4. New order:
   - Photo
   - Width Check
   - Visual Inspection
5. Click "Add new template"
6. Order is saved!
```

### Viewing Existing Template
```
1. Click on existing template
2. Control points display
3. 6-dot icon is greyed out
4. Cannot drag to reorder
5. This protects saved templates
```

## Visual Indicators

### Untitled Template (Draggable)
- 6-dot icon: **Grey** (#9CA3AF) - Active
- Cursor: Changes to grab/grabbing when hovering
- Can be dragged

### Existing Template (Not Draggable)
- 6-dot icon: **Light Grey** (#E5E7EB) - Disabled
- Cursor: Normal
- Cannot be dragged

## Technical Details

### Key Requirements
1. **ValueKey**: Each item must have a unique key
   ```dart
   key: ValueKey(point['id'])
   ```

2. **onReorder Callback**: Handles the reordering logic
   ```dart
   onReorder: (oldIndex, newIndex) {
     // Adjust newIndex if moving down
     if (newIndex > oldIndex) {
       newIndex -= 1;
     }
     // Move item
   }
   ```

3. **Sync Both Lists**: Update both `controlPoints` and `tempControlPoints`

### Why Two Lists?
- `controlPoints`: For display (normalized format)
- `tempControlPoints`: For API submission (original format)
- Both must stay in sync when reordering

## Files Modified

1. **Frontend/inventory/lib/screens/qc_template_screen.dart**
   - Replaced ListView with conditional rendering
   - Added ReorderableListView for untitled template
   - Kept regular ListView for existing templates
   - Added onReorder callback
   - Added ValueKey to items

## Testing

### Test 1: Drag-and-Drop on Untitled Template
1. Click "Add new template"
2. Add 3 control points
3. Grab 6-dot icon on second item
4. Drag to first position
5. ✅ Order should change
6. ✅ Numbers should update

### Test 2: Cannot Drag on Existing Template
1. Click on existing template
2. Try to drag control points
3. ✅ Should not be draggable
4. ✅ 6-dot icon should be greyed out

### Test 3: Order Persists After Save
1. Create new template
2. Add and reorder control points
3. Click "Add new template"
4. Click on newly created template
5. ✅ Order should be preserved

## Known Limitations

1. **No Drag on Existing Templates**: By design, to prevent accidental changes
2. **Order Not Saved to Database**: Currently, the order is based on insertion order
3. **No Visual Feedback**: No drag preview or drop indicator (Flutter default behavior)

## Future Enhancements

### Possible Improvements
1. **Enable Reordering for Existing Templates**: Add "Edit Mode" button
2. **Save Order to Database**: Add `DisplayOrder` column
3. **Visual Drag Feedback**: Custom drag preview
4. **Undo/Redo**: Allow undoing reorder actions
5. **Drag Between Templates**: Move control points between templates

## Troubleshooting

### Drag Not Working
- Check if you're on untitled template (selectedTemplateId == -1)
- Verify ValueKey is unique for each item
- Check Flutter console for errors

### Order Not Saved
- Verify both lists are updated in onReorder
- Check if tempControlPoints is synced
- Ensure order is preserved when creating template

### Items Jump Around
- This is normal Flutter behavior
- The newIndex adjustment handles this:
  ```dart
  if (newIndex > oldIndex) {
    newIndex -= 1;
  }
  ```

## Success Indicators

✅ Can drag control points on untitled template
✅ Cannot drag on existing templates
✅ 6-dot icon shows correct color (grey vs light grey)
✅ Order is preserved after saving
✅ Both lists stay in sync

## Hot Reload

After code changes:
```bash
# In Flutter terminal, press 'r'
# Or restart the app
```

Try dragging control points on an untitled template!
