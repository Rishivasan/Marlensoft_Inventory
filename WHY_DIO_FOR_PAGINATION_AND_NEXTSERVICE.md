# WHY WE USE DIO FOR PAGINATION AND NEXT SERVICE DATE

## Quick Answer

**Dio is the HTTP client library that makes API calls to the backend.** We use it for pagination and next service date because these features require communication between the Flutter frontend and the ASP.NET Core backend.

---

## What is Dio?

**Dio** is a powerful HTTP client for Dart/Flutter that handles:
- Making HTTP requests (GET, POST, PUT, DELETE)
- Sending and receiving JSON data
- Managing timeouts and retries
- Intercepting requests/responses
- Error handling

Think of Dio as the **messenger** between your Flutter app and the backend server.

---

## The Communication Flow

```
┌─────────────────────────────────────────────────────────────┐
│  FLUTTER FRONTEND                                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  User clicks "Next Page" button                        │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  PaginationProvider updates state                      │ │
│  │  currentPage = 2                                       │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  MasterListService needs to fetch data from backend   │ │
│  │  HOW? → Use Dio to make HTTP request!                 │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  DIO MAKES HTTP REQUEST                                │ │
│  │  GET http://localhost:5062/api/enhanced-master-list/   │ │
│  │      paginated?pageNumber=2&pageSize=10                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↓ HTTP Request over network
┌─────────────────────────────────────────────────────────────┐
│  ASP.NET CORE BACKEND                                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  MasterRegisterController receives request            │ │
│  │  Queries database for page 2 data                     │ │
│  │  Returns JSON response                                 │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                          ↓ HTTP Response with JSON
┌─────────────────────────────────────────────────────────────┐
│  FLUTTER FRONTEND                                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  DIO RECEIVES RESPONSE                                 │ │
│  │  Parses JSON to Dart objects                          │ │
│  │  Returns data to MasterListService                    │ │
│  └────────────────────────────────────────────────────────┘ │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  UI displays page 2 data                              │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Why Dio Specifically?

### Alternative Options (and why we didn't use them):

#### 1. ❌ Built-in `http` package
```dart
// Using http package (basic)
import 'package:http/http.dart' as http;

final response = await http.get(Uri.parse('http://localhost:5062/api/data'));
```

**Why NOT use this?**
- ❌ More verbose code
- ❌ Manual JSON parsing
- ❌ No interceptors
- ❌ No automatic retry
- ❌ Less features

#### 2. ❌ GraphQL clients
```dart
// Using GraphQL
import 'package:graphql_flutter/graphql_flutter.dart';
```

**Why NOT use this?**
- ❌ Backend is REST API, not GraphQL
- ❌ Overkill for simple CRUD operations
- ❌ More complex setup

#### 3. ✅ Dio (What we chose)
```dart
// Using Dio (powerful and clean)
import 'package:dio/dio.dart';

final dio = Dio();
final response = await dio.get('/api/data');
```

**Why YES use Dio?**
- ✅ Clean, simple syntax
- ✅ Automatic JSON parsing
- ✅ Interceptors for logging/auth
- ✅ Timeout management
- ✅ Error handling
- ✅ Request/Response transformation
- ✅ Widely used in Flutter community
- ✅ Great documentation

---

## How Dio is Used in Our App

### 1. Dio Client Setup (dio_client.dart)

**File**: `Frontend/inventory/lib/core/api/dio_client.dart`

```dart
import 'package:dio/dio.dart';

class DioClient {
  static Dio? _dio;

  static Dio getDio() {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: 'http://localhost:5062',  // Backend URL
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      // Add interceptors for logging
      _dio!.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
    return _dio!;
  }
}
```

**Why This Setup?**
- **Singleton Pattern**: One Dio instance for entire app
- **Base URL**: Don't repeat URL in every request
- **Timeouts**: Prevent hanging requests
- **Headers**: Set default headers for all requests
- **Interceptors**: Log all requests/responses for debugging

---

### 2. Pagination with Dio

**File**: `Frontend/inventory/lib/services/master_list_service.dart`

```dart
import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';

class MasterListService {
  final Dio _dio = DioClient.getDio();  // Get Dio instance

  // Fetch paginated data
  Future<PaginationModel<MasterListModel>> getMasterListPaginated({
    required int pageNumber,
    required int pageSize,
    String? searchText,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        if (searchText != null && searchText.isNotEmpty) 
          'searchText': searchText,
      };

      // Make HTTP GET request using Dio
      final response = await _dio.get(
        '/api/enhanced-master-list/paginated',
        queryParameters: queryParams,
      );

      // Dio automatically parses JSON response
      if (response.statusCode == 200) {
        final data = response.data;  // Already parsed JSON!
        
        // Extract pagination metadata
        final totalCount = data['totalCount'] as int;
        final pageNum = data['pageNumber'] as int;
        final pageSz = data['pageSize'] as int;
        final totalPages = data['totalPages'] as int;
        
        // Parse items array
        final itemsList = (data['items'] as List)
            .map((item) => MasterListModel.fromJson(item))
            .toList();
        
        // Return pagination model
        return PaginationModel<MasterListModel>(
          totalCount: totalCount,
          pageNumber: pageNum,
          pageSize: pageSz,
          totalPages: totalPages,
          items: itemsList,
        );
      } else {
        throw Exception('Failed to load paginated data');
      }
    } catch (e) {
      throw Exception('Error fetching paginated master list: $e');
    }
  }
}
```

**What Dio Does Here:**
1. **Builds URL**: Combines base URL + endpoint + query params
   - Result: `http://localhost:5062/api/enhanced-master-list/paginated?pageNumber=2&pageSize=10`
2. **Makes HTTP Request**: Sends GET request to backend
3. **Receives Response**: Gets JSON response from backend
4. **Parses JSON**: Automatically converts JSON string to Dart Map
5. **Returns Data**: Service can immediately use `response.data`

**Without Dio (using http package):**
```dart
// Much more verbose!
import 'dart:convert';
import 'package:http/http.dart' as http;

final uri = Uri.parse('http://localhost:5062/api/enhanced-master-list/paginated')
    .replace(queryParameters: {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    });

final response = await http.get(uri);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);  // Manual JSON parsing
  // ... rest of code
}
```

---

### 3. Next Service Date with Dio

**File**: `Frontend/inventory/lib/services/next_service_calculation_service.dart`

```dart
import 'package:dio/dio.dart';
import '../core/api/dio_client.dart';

class NextServiceCalculationService {
  final Dio _dio = DioClient.getDio();

  // Get last service date from backend
  Future<DateTime?> _getLastServiceDate(String assetId, String assetType) async {
    try {
      // Make HTTP GET request using Dio
      final response = await _dio.get(
        '/api/NextService/GetLastServiceDate/$assetId/$assetType',
      );

      if (response.statusCode == 200 && response.data != null) {
        final lastServiceDateStr = response.data['lastServiceDate'];
        if (lastServiceDateStr != null) {
          return DateTime.tryParse(lastServiceDateStr);
        }
      }
      return null;
    } catch (e) {
      print('Error getting last service date: $e');
      return null;
    }
  }

  // Update next service date in backend
  Future<bool> _updateItemNextServiceDate(
    String assetId, 
    String assetType, 
    DateTime nextServiceDate
  ) async {
    try {
      // Make HTTP POST request using Dio
      final response = await _dio.post(
        '/api/NextService/UpdateNextServiceDate',
        data: {
          'assetId': assetId,
          'assetType': assetType,
          'nextServiceDate': nextServiceDate.toIso8601String(),
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating next service date: $e');
      return false;
    }
  }

  // Get maintenance frequency from backend
  Future<String?> getMaintenanceFrequency(
    String assetId,
    String assetType,
  ) async {
    try {
      // Make HTTP GET request using Dio
      final response = await _dio.get(
        '/api/NextService/GetMaintenanceFrequency/$assetId/$assetType',
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['maintenanceFrequency'];
      }
      return null;
    } catch (e) {
      print('Error getting maintenance frequency: $e');
      return null;
    }
  }
}
```

**What Dio Does Here:**
1. **GET Request**: Fetches last service date from backend
2. **POST Request**: Sends calculated next service date to backend
3. **JSON Handling**: Automatically serializes/deserializes JSON
4. **Error Handling**: Catches network errors gracefully

---

## Real-World Example: Complete Flow

### Scenario: User Navigates to Page 2

**Step 1: User Action**
```dart
// User clicks "Next Page" button
onPressed: () {
  ref.read(paginationProvider.notifier).nextPage();
}
```

**Step 2: State Update**
```dart
// PaginationProvider updates state
void nextPage() {
  state = PaginationState(
    currentPage: state.currentPage + 1,  // 1 → 2
    pageSize: state.pageSize,
    searchText: state.searchText,
  );
}
```

**Step 3: Provider Detects Change**
```dart
// paginatedMasterListProvider watches pagination state
final paginatedMasterListProvider = FutureProvider((ref) async {
  final paginationState = ref.watch(paginationProvider);
  
  // Call service to fetch data
  final service = MasterListService();
  return await service.getMasterListPaginated(
    pageNumber: paginationState.currentPage,  // 2
    pageSize: paginationState.pageSize,       // 10
  );
});
```

**Step 4: Service Uses Dio**
```dart
// MasterListService makes HTTP request
final response = await _dio.get(
  '/api/enhanced-master-list/paginated',
  queryParameters: {
    'pageNumber': 2,
    'pageSize': 10,
  },
);
```

**Step 5: Dio Makes HTTP Request**
```
HTTP Request:
GET http://localhost:5062/api/enhanced-master-list/paginated?pageNumber=2&pageSize=10

Headers:
Content-Type: application/json
Accept: application/json
```

**Step 6: Backend Processes Request**
```csharp
// MasterRegisterController receives request
[HttpGet("enhanced-master-list/paginated")]
public async Task<IActionResult> GetEnhancedMasterListPaginated(
    [FromQuery] int pageNumber = 1,
    [FromQuery] int pageSize = 10)
{
    var data = await _service.GetEnhancedMasterListPaginatedAsync(
        pageNumber, pageSize);
    return Ok(data);  // Returns JSON
}
```

**Step 7: Backend Returns JSON**
```json
{
  "totalCount": 150,
  "pageNumber": 2,
  "pageSize": 10,
  "totalPages": 15,
  "items": [
    {
      "itemID": "MMD011",
      "itemName": "Pressure Gauge",
      "supplier": "WIKA",
      ...
    },
    ...
  ]
}
```

**Step 8: Dio Receives Response**
```dart
// Dio automatically parses JSON
final data = response.data;  // Already a Dart Map!

// No need for manual parsing like:
// final data = jsonDecode(response.body);
```

**Step 9: Service Returns Data**
```dart
return PaginationModel<MasterListModel>(
  totalCount: data['totalCount'],
  pageNumber: data['pageNumber'],
  pageSize: data['pageSize'],
  totalPages: data['totalPages'],
  items: itemsList,
);
```

**Step 10: UI Updates**
```dart
// Widget rebuilds with new data
Consumer(
  builder: (context, ref, child) {
    final paginatedData = ref.watch(paginatedMasterListProvider);
    
    return paginatedData.when(
      data: (data) => DataTable(items: data.items),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  },
)
```

---

## Why NOT Calculate Everything in Frontend?

### ❌ Option 1: Calculate Pagination in Frontend
```dart
// BAD: Load all 1,000 items, paginate in frontend
final allItems = await fetchAllItems();  // 1,000 items!
final page2Items = allItems.skip(10).take(10).toList();
```

**Problems:**
- ❌ Slow initial load (1,000 items)
- ❌ High memory usage
- ❌ Wasted bandwidth
- ❌ Poor performance

### ✅ Option 2: Server-Side Pagination with Dio
```dart
// GOOD: Fetch only page 2 (10 items)
final response = await _dio.get('/api/paginated?page=2&size=10');
```

**Benefits:**
- ✅ Fast load (only 10 items)
- ✅ Low memory usage
- ✅ Minimal bandwidth
- ✅ Great performance

---

## Dio Features We Use

### 1. Query Parameters
```dart
await _dio.get('/api/data', queryParameters: {
  'pageNumber': 2,
  'pageSize': 10,
  'searchText': 'Tool',
});
// Result: /api/data?pageNumber=2&pageSize=10&searchText=Tool
```

### 2. Request Body (POST/PUT)
```dart
await _dio.post('/api/maintenance', data: {
  'assetId': 'MMD001',
  'serviceDate': '2024-04-06',
  'nextServiceDue': '2024-12-01',
});
```

### 3. Path Parameters
```dart
await _dio.get('/api/NextService/GetLastServiceDate/$assetId/$assetType');
// Result: /api/NextService/GetLastServiceDate/MMD001/MMD
```

### 4. Timeout Handling
```dart
Dio(BaseOptions(
  connectTimeout: Duration(seconds: 30),  // Connection timeout
  receiveTimeout: Duration(seconds: 30),  // Response timeout
));
```

### 5. Error Handling
```dart
try {
  final response = await _dio.get('/api/data');
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    print('Connection timeout');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    print('Receive timeout');
  } else if (e.response?.statusCode == 404) {
    print('Not found');
  }
}
```

### 6. Interceptors (Logging)
```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,   // Log request body
  responseBody: true,  // Log response body
));

// Console output:
// *** Request ***
// GET http://localhost:5062/api/data
// Headers: {Content-Type: application/json}
// 
// *** Response ***
// Status: 200
// Body: {"totalCount": 150, "items": [...]}
```

---

## Summary

### Why Dio for Pagination?
1. **Backend has the data** → Need HTTP client to fetch it
2. **Dio is the best HTTP client** → Clean syntax, powerful features
3. **Server-side pagination** → Only fetch what's needed
4. **Automatic JSON parsing** → Less code, fewer errors

### Why Dio for Next Service Date?
1. **Backend calculates dates** → Need HTTP client to communicate
2. **Multiple API calls needed** → Get frequency, update dates
3. **Dio handles complexity** → Timeouts, errors, retries
4. **Consistent with rest of app** → Same HTTP client everywhere

### The Bottom Line
**Dio is the bridge between Flutter frontend and ASP.NET Core backend.** Without Dio (or similar HTTP client), the frontend cannot communicate with the backend, and features like pagination and next service date calculation would be impossible!

---

## Alternatives We Could Have Used

| HTTP Client | Pros | Cons | Why Not? |
|-------------|------|------|----------|
| **http** package | Simple, built-in | Verbose, fewer features | Too basic for our needs |
| **Dio** ✅ | Powerful, clean syntax | Slightly larger package | **BEST CHOICE** |
| **Chopper** | Type-safe, code generation | More setup, learning curve | Overkill for our app |
| **Retrofit** | Type-safe, annotations | Complex setup | Too much boilerplate |

**Dio strikes the perfect balance between power and simplicity!**
