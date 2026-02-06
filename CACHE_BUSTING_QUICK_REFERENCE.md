# Cache-Busting Quick Reference Guide

## Problem Statement
New items don't appear immediately after adding them to the database. They only show up after restarting the application.

## Root Cause
HTTP caching - Browser/HTTP client caches GET requests and returns stale data.

## Solution
Add cache-busting headers to disable HTTP caching for data endpoints.

---

## Quick Fix Checklist

### Frontend (Dart/Flutter)
- [x] Add cache headers to Dio client configuration
- [x] File: `Frontend/inventory/lib/core/api/dio_client.dart`

### Backend (C#/.NET)
- [x] Add cache headers to GET endpoints
- [x] File: `Backend/InventoryManagement/Controllers/MasterRegisterController.cs`
- [x] File: `Backend/InventoryManagement/Controllers/ItemDetailsV2Controller.cs`

---

## Code Snippets

### Frontend: Dio Client Setup
```dart
// File: dio_client.dart
BaseOptions(
  baseUrl: "http://localhost:5069",
  headers: {
    "Content-Type": "application/json",
    "Cache-Control": "no-cache, no-store, must-revalidate",
    "Pragma": "no-cache",
    "Expires": "0",
  },
)
```

### Backend: Controller Response Headers
```csharp
// Add to any GET endpoint that returns data
Response.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate");
Response.Headers.Add("Pragma", "no-cache");
Response.Headers.Add("Expires", "0");
```

---

## When to Use Cache-Busting

### ✅ Use Cache-Busting For:
- Master list endpoints (GET /api/enhanced-master-list)
- Paginated data endpoints
- Item details endpoints
- Any endpoint that returns frequently changing data
- CRUD operation result endpoints

### ❌ Don't Use Cache-Busting For:
- Static assets (images, CSS, JS files)
- Configuration files that rarely change
- Public API documentation
- Health check endpoints
- Metrics endpoints

---

## Testing Cache-Busting

### Browser Developer Tools
1. Open DevTools (F12)
2. Go to Network tab
3. Perform action that fetches data
4. Check request/response headers
5. Verify cache headers are present

### Expected Headers
```
Request Headers:
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0

Response Headers:
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0
```

---

## Common Issues & Solutions

### Issue 1: Headers Not Working
**Symptom**: Cache headers present but data still cached
**Solution**: 
- Clear browser cache manually (Ctrl+Shift+Delete)
- Restart browser completely
- Check if proxy/CDN is caching

### Issue 2: Performance Concerns
**Symptom**: Too many database queries
**Solution**:
- Implement server-side caching with TTL
- Use Redis/Memcached for frequently accessed data
- Add ETag support for conditional requests

### Issue 3: Mobile App Caching
**Symptom**: Mobile app still caches data
**Solution**:
- Verify Dio client configuration
- Check platform-specific cache settings
- Clear app data/cache on device

---

## Alternative Approaches

### 1. Query String Cache Busting
```dart
// Add timestamp to URL
final url = "/api/enhanced-master-list?_t=${DateTime.now().millisecondsSinceEpoch}";
```

### 2. ETag-Based Caching
```csharp
// Backend generates ETag
Response.Headers.Add("ETag", GenerateETag(data));

// Frontend sends If-None-Match
// Backend returns 304 Not Modified if data unchanged
```

### 3. WebSocket Real-Time Updates
```dart
// Subscribe to data changes
websocket.on('data-updated', (data) {
  updateUI(data);
});
```

### 4. Optimistic UI Updates
```dart
// Update UI immediately, sync with server in background
addItemToList(newItem);
await syncWithServer(newItem);
```

---

## Performance Impact

### Network Traffic
- **Before**: 1 request (cached), 0 KB transferred
- **After**: 1 request (fresh), ~50-500 KB transferred
- **Impact**: Minimal for small datasets

### Response Time
- **Before**: <10ms (from cache)
- **After**: 50-200ms (from database)
- **Impact**: Acceptable for data freshness

### Database Load
- **Before**: 1 query per session
- **After**: 1 query per refresh
- **Impact**: Minimal with proper indexing

---

## Production Considerations

### 1. Implement Smart Caching
```csharp
// Cache with short TTL (e.g., 30 seconds)
[ResponseCache(Duration = 30, Location = ResponseCacheLocation.Client)]
public async Task<IActionResult> GetData()
```

### 2. Use Cache Invalidation
```csharp
// Invalidate cache when data changes
await _cache.RemoveAsync("master-list");
```

### 3. Add Rate Limiting
```csharp
// Prevent excessive requests
[RateLimit(MaxRequests = 100, TimeWindow = 60)]
public async Task<IActionResult> GetData()
```

### 4. Monitor Performance
```csharp
// Log slow queries
if (queryTime > 1000ms) {
  _logger.LogWarning($"Slow query: {queryTime}ms");
}
```

---

## Related Documentation
- [IMMEDIATE_DATA_REFRESH_FIX.md](./IMMEDIATE_DATA_REFRESH_FIX.md) - Detailed fix explanation
- [HTTP_CACHING_FIX_DIAGRAM.md](./HTTP_CACHING_FIX_DIAGRAM.md) - Visual diagrams
- [test_immediate_refresh.md](./test_immediate_refresh.md) - Test plan

---

## Summary

**Problem**: HTTP caching prevents fresh data from appearing
**Solution**: Add cache-busting headers to both frontend and backend
**Result**: New items appear immediately without restart
**Trade-off**: Slightly increased network traffic for better UX
