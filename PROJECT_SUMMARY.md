# Marlensoft — Frontend & Backend Summary

## Overview

**Marlensoft** is an **Inventory Management** application for manufacturing, focused on **Tools, Assets, MMDs (Measuring/Monitoring Devices), and Consumables**. It consists of a **Flutter** (Dart) frontend and an **ASP.NET Core** (.NET 9) Web API backend, with **SQL Server** as the database, accessed via **Dapper**.

---

## 1. Backend (ASP.NET Core)

### 1.1 Technology Stack

| Component | Technology |
|----------|------------|
| Framework | ASP.NET Core / .NET 9.0 |
| ORM / Data Access | Dapper |
| Database | SQL Server (Microsoft.Data.SqlClient) |
| API Docs | Swagger (Swashbuckle) |
| Architecture | Controllers → Services → Repositories |

### 1.2 Project Structure

```
Backend/InventoryManagement/
├── Controllers/          # API endpoints
├── Data/                 # DapperContext (SQL connection)
├── Models/
│   ├── DTOs/            # Data transfer objects
│   └── Entities/        # Domain/database entities
├── Repositories/         # Data access (Dapper)
│   └── Interfaces/
├── Services/             # Business logic
│   └── Interfaces/
├── Program.cs
├── appsettings.json
└── Properties/launchSettings.json
```

### 1.3 API Endpoints

| Controller | Method | Route | Description |
|------------|--------|-------|-------------|
| **ToolsController** | GET | `api/tools` | List all tools |
| | POST | `api/addtools` | Create tool (body: `ToolEntity`) |
| **MmdsController** | GET | `api/mmds` | List all MMDs |
| | POST | `api/addmmds` | Create MMD (body: `MmdsEntity`) |
| | PUT | `api/updatemmds` | Update MMD (body: `MmdsEntity`) |
| **AssetsConsumablesController** | GET | `api/assets-consumables` | List assets/consumables |
| | POST | `api/add-assets-consumables` | Create asset/consumable (body: `AssetsConsumablesEntity`) |
| | PUT | `api/update-assets-consumables` | Update asset/consumable |
| | GET | `api/asset-full-details?assetId=&assetType=` | Full details + maintenance + allocation |
| **MasterRegisterController** | GET | `api/master-list` | Unified master list (Tools, Assets, Consumables, MMDs) |

### 1.4 Database & Configuration

- **Connection**: `appsettings.json` → `ConnectionStrings:DefaultConnection`
- **Database**: `ManufracturingApp2` (SQL Server; `User Id=sa`, `TrustServerCertificate=True`)
- **URLs** (from config): `http://localhost:5000`, `https://localhost:44370` (IIS Express also uses `https://localhost:44370`)

### 1.5 Entities (Domain Models)

- **ToolEntity**  
  ToolsId, ToolName, ToolType, AssociatedProduct, ArticleCode, VendorName, Specifications, StorageLocation, PoNumber, PoDate, InvoiceNumber, InvoiceDate, ToolCost, ExtraCharges, TotalCost, Lifespan, MaintainanceFrequency, HandlingCertificate, AuditInterval, MaxOutput, LastAuditDate, LastAuditNotes, ResponsibleTeam, Notes, MsiAsset, KernAsset, CreatedBy, UpdatedBy, CreatedDate, UpdatedDate, Status.

- **MmdsEntity**  
  MmdId, AccuracyClass, Vendor, CalibratedBy, Specifications, ModelNumber, SerialNumber, Quantity, CalibrationCertNo, Location, PoNumber, PoDate, InvoiceNumber, InvoiceDate, TotalCost, CalibrationFrequency, LastCalibration, NextCalibration, WarrantyYears, CalibrationStatus, ResponsibleTeam, ManualLink, StockMsi, Remarks, CreatedBy, UpdatedBy, CreatedDate, UpdatedDate, Status.

- **AssetsConsumablesEntity**  
  AssetId, Category, AssetName, Product, Vendor, Specifications, Quantity, StorageLocation, PoNumber, PoDate, InvoiceNumber, InvoiceDate, AssetCost, ExtraCharges, TotalCost, DepreciationPeriod, MaintenanceFrequency, ResponsibleTeam, MsiTeam, Remarks, ItemTypeKey, CreatedBy, UpdatedBy, CreatedDate, UpdatedDate, Status.

- **MasterRegister**  
  SNo, ItemType, RefId, IsActive, CreatedDate. Used as a central register for Tools, Assets, Consumables, and MMDs.

- **MaintenanceEntity**  
  MaintenanceId, AssetType, AssetId, ItemName, ServiceDate, ServiceProviderCompany, ServiceEngineerName, ServiceType, NextServiceDue, ServiceNotes, MaintenanceStatus, Cost, ResponsibleTeam, CreatedDate.

- **AllocationEntity**  
  AllocationId, AssetType, AssetId, ItemName, EmployeeId, EmployeeName, TeamName, Purpose, IssuedDate, ExpectedReturnDate, ActualReturnDate, AvailabilityStatus, CreatedDate.

### 1.6 DTOs

- **MasterListDto**  
  SNo, ItemType, RefId, CreatedDate, DisplayId, Name, Type, Supplier, Location — built from joins of `MasterRegister` with `ToolsMaster`, `AssetsConsumablesMaster`, and `MmdsMaster`.

- **AssetFullDetailDto**  
  MasterDetails (object), MaintenanceRecords (List&lt;MaintenanceEntity&gt;), AllocationRecords (List&lt;AllocationEntity&gt;).

- **ToolDto**, **MmdsDto**, **AssetsConsumablesDto**  
  Used for list/detail responses.

### 1.7 Dependency Injection (Program.cs)

- **Singleton**: `DapperContext`
- **Scoped**:  
  - `IToolRepository` / `ToolRepository`, `IToolService` / `ToolService`  
  - `IMmdsRepository` / `MmdsRepository`, `IMmdsService` / `MmdsService`  
  - `IAssetsConsumablesRepository` / `AssetsConsumablesRepository`, `IAssetsConsumablesService` / `AssetsConsumablesService`  
  - `IMasterRegisterRepository` / `MasterRegisterRepository`, `IMasterRegisterService` / `MasterRegisterService`
- **Swagger**: `AddSwaggerGen()`, `app.UseSwagger()`, `app.UseSwaggerUI()`

---

## 2. Frontend (Flutter / Dart)

### 2.1 Technology Stack

| Component | Technology |
|----------|------------|
| Framework | Flutter (Dart SDK ^3.10.1) |
| State Management | flutter_riverpod |
| Routing | auto_route |
| HTTP | http, dio |
| UI | Material 3, flutter_svg |
| Font | FiraSans (custom) |

### 2.2 Project Structure

```
Frontend/inventory/
├── lib/
│   ├── core/api/           # dio_client, http_override (HTTPS cert bypass)
│   ├── dialogs/            # dialog_pannel_helper (slide-in add panel)
│   ├── features/tools/     # tool-specific data & providers
│   ├── model/              # master_list_model, tool_model, assets_table_model
│   ├── providers/          # sidebar, header, master_list, tool, sidebar_expand
│   ├── routers/            # app_router, app_router.gr.dart (auto_route)
│   ├── screens/
│   │   ├── add_forms/      # add_tool, add_asset, add_mmd, add_consumable
│   │   ├── dashboard_body.dart, dashboard_screen.dart
│   │   ├── default_screen.dart (placeholder / under construction)
│   │   └── master_list.dart
│   ├── services/           # api_service, master_list_service, tool_service
│   ├── widgets/            # footer, nav_profile, sidebar, sidebar_item, top_layer
│   └── main.dart
├── assets/images/          # SVGs, under_construction.png, etc.
├── assets/fonts/           # FiraSans
├── pubspec.yaml
├── web/, android/, ios/, macos/, linux/, windows/
└── test/
```

### 2.3 Routing (AutoRoute)

- **Root**: `DashboardRoute` (initial) → `DashboardScreen` (sidebar + `DashboardBodyScreen`).
- **Children**:
  - `DefaultRoute` (initial child): placeholder (“under construction”).
  - `MasterListRoute`: `MasterListScreen` (master list table).
- **Navigation**: `dashboard_body` uses `ref.listen(sideBarStateProvider, ...)` to switch `headerProvider` and `context.router.replace(DefaultRoute() | MasterListRoute())` based on sidebar index.

### 2.4 Sidebar & Header

- **Sidebar** (`SidebarWidget`):  
  - Items: Dashboard, Products, BOM Master, Orders, Suppliers, Purchases, **Inventory** (index 6 → Master List).  
  - Expand/collapse (70px / 210px) via `sidebarExpandProvider`.  
  - Logos: Inveon, “New Logo with black subtext” (Marlensoft).

- **Header** (`DashboardBodyScreen`):  
  - Title and subtitle from `headerProvider` (updated when sidebar selection changes).  
  - `NavbarProfileWidget` on the right.

### 2.5 Screens

| Screen | Purpose |
|--------|---------|
| **DashboardScreen** | Row: Sidebar + `DashboardBodyScreen` (header, `AutoRouter` body, footer). |
| **DefaultScreen** | Placeholder with `under_construction.png`. Used for Dashboard, Products, BOM, Orders, Suppliers, Purchases. |
| **MasterListScreen** | Table of master list (Asset ID, Type, Asset Name, Supplier, Location) from `masterListProvider`; `TopLayer` (search, Delete, Export, “Add new item” popup). |
| **Add Tool / Asset / MMD / Consumable** | Forms in a slide-in panel via `DialogPannelHelper.showAddPannel`; opened from “Add new item” in `TopLayer`. |

### 2.6 Master List & Data Flow

- **Provider**: `masterListProvider` (Riverpod `FutureProvider`).
- **Service**: `MasterListService.getMasterList()` → `GET` to `$baseUrl/api/master-list` (`https://localhost:44370` in `MasterListService`).
- **Model**: `MasterListModel` with `sno`, `itemType`, `refId`, `assetId`, `type`, `name` (`assetName`), `supplier`, `location`; `fromJson` supports Tool, Asset, Consumable, MMD based on `itemType`.

### 2.7 Add Forms

- **AddTool, AddAsset, AddMmd, AddConsumable**:  
  - Sectioned forms (e.g. “Tool information”, “Purchase information”, “Maintenance and Audit information”).  
  - Validation, date pickers, dropdowns (e.g. tool type, maintenance frequency, status).  
  - Cost + extra charges → total.  
  - Submit: `validator` run, then `Navigator.pop`, `submit()` callback (e.g. `ref.invalidate(masterListProvider)`), SnackBar.  
- **Add Tool**: not wired to backend `api/addtools` in the provided code; form only triggers `submit()` (and thus refresh of master list). Same pattern for Asset/MMD/Consumable — forms exist, backend integration may be partial or via other services.

### 2.8 Top Layer (Master List)

- Search bar (UI only; no backend filter in the reviewed code).  
- Delete, Export (UI only).  
- **“Add new item”** popup: Tool, Asset, MMD, Consumable → `DialogPannelHelper.showAddPannel` with the corresponding form; on submit, `ref.invalidate(masterListProvider)`.

### 2.9 API / HTTP

- **Base URLs**:  
  - `MasterListService`: `https://localhost:44370`  
  - `ApiService`: `https://localhost:44370`  
  - `DioClient`: `http://localhost:44370` (Dio; used where Dio is referenced).
- **HTTP overrides**: `MyHttpOverrides` in `main.dart` to allow self-signed/localhost HTTPS (`badCertificateCallback = true`).

### 2.10 Theming (main.dart)

- Material 3, `useMaterial3: true`.  
- `ColorScheme.fromSeed(seedColor: 0xff909090)`, `secondary: 0xff00599A`.  
- `InputDecorationTheme`, `OutlinedButton`, `ElevatedButton`, `Checkbox`, `TextTheme` (e.g. FiraSans, sizes 11–12).  

---

## 3. Integration Summary

| Backend API | Frontend consumer |
|-------------|--------------------|
| `GET /api/master-list` | `MasterListService` → `masterListProvider` → `MasterListScreen` |
| `GET /api/tools` | `ApiService.getTools()` (e.g. for tools feature; `toolListProvider` / `tool_service` may use it) |
| `POST /api/addtools` | `ApiService.addTool()` — Add Tool form not clearly wired in the snippets |
| `api/mmds`, `api/addmmds`, `api/updatemmds` | No explicit frontend service in the reviewed files |
| `api/assets-consumables`, `api/add-assets-consumables`, `api/update-assets-consumables` | No explicit frontend service in the reviewed files |
| `api/asset-full-details` | No explicit frontend usage in the reviewed files |

---

## 4. Database Assumptions (from Backend)

Tables inferred from repositories and entities:

- **MasterRegister** (SNo, ItemType, RefId, IsActive, CreatedDate)  
- **ToolsMaster** (tool fields; key `ToolsId`)  
- **AssetsConsumablesMaster** (asset/consumable fields; key `AssetId`, `ItemTypeKey`)  
- **MmdsMaster** (MMD fields; key `MmdId`)  
- Maintenance and Allocation tables for `AssetFullDetailDto`.

---

## 5. Configuration Checklist

- **Backend**:  
  - `appsettings.json`: `ConnectionStrings:DefaultConnection`, `applicationUrl` (e.g. `https://localhost:44370` for HTTPS).  
  - `launchSettings.json`: IIS Express `sslPort: 44370`; other profiles can use different ports.
- **Frontend**:  
  - `MasterListService.baseUrl`, `ApiService.baseUrl`, `DioClient.baseUrl` must match the running backend (e.g. `https://localhost:44370` or `http://localhost:5069` depending on profile).  
  - `DefaultScreen` references `assets/Images/under_construction.png`; correct casing is `assets/images/` in pubspec — verify path.

---

## 6. Gaps & Notes

1. **Master list contract**: Backend `MasterListDto` uses `DisplayId`, `Name`, `Type`, `Supplier`, `Location`. Frontend `MasterListModel.fromJson` is written for both a unified structure and type-specific keys (e.g. `toolType`, `toolName`). Align API JSON shape and `fromJson` to avoid parsing errors.
2. **Add forms → backend**: Add Tool/Asset/MMD/Consumable forms invalidate `masterListProvider` on submit but are not clearly connected to `POST /api/addtools`, `api/add-assets-consumables`, `api/addmmds`. Wire each form to the corresponding API.
3. **Asset full details**: `GET /api/asset-full-details` exists; no UI or service usage was found. Consider a detail view or slide-in that calls this and shows maintenance and allocation.
4. **Search, Delete, Export**: Implemented only in the UI in `TopLayer`; no backend filters or bulk delete/export yet.
5. **CORS**: If the Flutter app runs from `localhost` (e.g. web) to `https://localhost:44370`, ensure the backend has CORS enabled for that origin.
6. **Auth**: No authentication/authorization in the reviewed code; all endpoints are open.

---

## 7. How to Run

**Backend**

- From `Backend/InventoryManagement/`:  
  `dotnet run` (or use IIS Express / `https` profile).  
- Swagger: e.g. `https://localhost:44370/swagger` or `http://localhost:5069/swagger` (profile-dependent).

**Frontend**

- From `Frontend/inventory/`:  
  `flutter pub get`  
  `dart run build_runner build` (for `app_router.gr.dart` if needed)  
  `flutter run -d chrome` (web) or `flutter run -d windows` (desktop).  
- Point base URLs to the actual backend URL in use.

---

*Summary generated from the Marlensoft codebase (Backend: InventoryManagement, Frontend: inventory).*
