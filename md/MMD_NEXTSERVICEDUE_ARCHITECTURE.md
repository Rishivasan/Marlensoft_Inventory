# MMD NextServiceDue Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Flutter)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐    ┌──────────────────────────────────┐  │
│  │   Add MMD Form   │    │   Master List Display            │  │
│  │                  │    │                                  │  │
│  │  - Calibration   │    │  - Shows NextServiceDue column  │  │
│  │    Frequency     │    │  - Color coded by status        │  │
│  │  - Last Calib    │    │  - Sortable/Filterable          │  │
│  │  - Next Calib    │    │                                  │  │
│  └────────┬─────────┘    └──────────────┬───────────────────┘  │
│           │                              │                       │
│           │                              │                       │
│  ┌────────▼──────────────────────────────▼───────────────────┐  │
│  │         NextServiceCalculationService                     │  │
│  │                                                            │  │
│  │  calculateNextServiceDateForNewItem()                     │  │
│  │  - Takes: assetId, assetType, createdDate, frequency     │  │
│  │  - Calculates: NextServiceDue based on frequency         │  │
│  │  - Stores: Result in provider and sends to API           │  │
│  └────────────────────────────┬───────────────────────────────┘  │
│                                │                                  │
│  ┌─────────────────────────────▼──────────────────────────────┐  │
│  │              NextServiceProvider                           │  │
│  │              (State Management)                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           │ HTTP Requests
                           │
┌──────────────────────────▼───────────────────────────────────────┐
│                      BACKEND (ASP.NET Core)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MmdsController                               │  │
│  │                                                            │  │
│  │  GET    /api/Mmds              → GetAllMmds()            │  │
│  │  POST   /api/Mmds              → CreateMmd()             │  │
│  │  PUT    /api/Mmds/{id}         → UpdateMmd()             │  │
│  │  DELETE /api/Mmds/{id}         → DeleteMmd()             │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │                                           │
│  ┌────────────────────▼───────────────────────────────────────┐  │
│  │              MmdsService                                   │  │
│  │              (Business Logic)                              │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │                                           │
│  ┌────────────────────▼───────────────────────────────────────┐  │
│  │              MmdsRepository                                │  │
│  │                                                            │  │
│  │  GetAllMmdsAsync()                                        │  │
│  │  - SELECT with NextServiceDue                            │  │
│  │  - Checks column existence                               │  │
│  │  - Returns MmdsEntity with NextServiceDue                │  │
│  │                                                            │  │
│  │  CreateMmdsAsync(MmdsEntity)                             │  │
│  │  - INSERT with NextServiceDue                            │  │
│  │  - Checks column existence                               │  │
│  │  - Handles backward compatibility                        │  │
│  │                                                            │  │
│  │  UpdateMmdsAsync(MmdsEntity)                             │  │
│  │  - UPDATE with NextServiceDue                            │  │
│  │  - Checks column existence                               │  │
│  │  - Handles backward compatibility                        │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │                                           │
│  ┌────────────────────▼───────────────────────────────────────┐  │
│  │              DapperContext                                 │  │
│  │              (Database Connection)                         │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │                                           │
└───────────────────────┼───────────────────────────────────────────┘
                        │
                        │ SQL Queries
                        │
┌───────────────────────▼───────────────────────────────────────────┐
│                    DATABASE (SQL Server)                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MmdsMaster Table                             │  │
│  │                                                            │  │
│  │  MmdId                VARCHAR      PRIMARY KEY            │  │
│  │  BrandName            VARCHAR      NULL                   │  │
│  │  AccuracyClass        VARCHAR      NULL                   │  │
│  │  Vendor               VARCHAR      NULL                   │  │
│  │  ...                  ...          ...                    │  │
│  │  CalibrationFrequency VARCHAR      NULL                   │  │
│  │  LastCalibration      DATETIME     NULL                   │  │
│  │  NextCalibration      DATETIME     NULL                   │  │
│  │  NextServiceDue       DATETIME     NULL    ✨ NEW         │  │
│  │  Status               BIT          NOT NULL               │  │
│  │  CreatedDate          DATETIME     NOT NULL               │  │
│  │  UpdatedDate          DATETIME     NULL                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              MasterRegister Table                         │  │
│  │                                                            │  │
│  │  RefId                VARCHAR      (links to MmdId)       │  │
│  │  ItemType             VARCHAR      ('MMD')                │  │
│  │  CreatedDate          DATETIME                            │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                          