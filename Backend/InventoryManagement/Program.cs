//using InventoryManagement.Data;
//using InventoryManagement.Repositories;
//using InventoryManagement.Repositories.Interfaces;
//using InventoryManagement.Services;
//using InventoryManagement.Services.Interfaces;

//var builder = WebApplication.CreateBuilder(args);

//builder.Services.AddControllers();
//builder.Services.AddSingleton<DapperContext>();

//// Add CORS
//builder.Services.AddCors(options =>
//{
//    options.AddPolicy("AllowFrontend", policy =>
//    {
//        policy.WithOrigins(
//                "http://localhost:3000", 
//                "http://127.0.0.1:3000",
//                "http://localhost:8080",
//                "http://127.0.0.1:8080",
//                "http://localhost:5000",
//                "http://127.0.0.1:5000",
//                "http://localhost:3001",
//                "http://127.0.0.1:3001",
//                "http://localhost:3002",
//                "http://127.0.0.1:3002"
//              )
//              .AllowAnyHeader()
//              .AllowAnyMethod();
//    });
//});

//builder.Services.AddScoped<IToolRepository, ToolRepository>();
//builder.Services.AddScoped<IToolService, ToolService>();

//builder.Services.AddScoped<IMmdsRepository, MmdsRepository>();
//builder.Services.AddScoped<IMmdsService, MmdsService>();

//builder.Services.AddScoped<IAssetsConsumablesRepository, AssetsConsumablesRepository>();
//builder.Services.AddScoped<IAssetsConsumablesService, AssetsConsumablesService>();

//builder.Services.AddScoped<IMasterRegisterRepository, MasterRegisterRepository>();
//builder.Services.AddScoped<IMasterRegisterService, MasterRegisterService>();

//builder.Services.AddEndpointsApiExplorer();
//builder.Services.AddSwaggerGen();

//var app = builder.Build();

//app.UseSwagger();
//app.UseSwaggerUI();

//// Use CORS
//app.UseCors("AllowFrontend");

//app.UseAuthorization();
//app.MapControllers();
//app.Run();


using InventoryManagement.Data;
using InventoryManagement.Repositories;
using InventoryManagement.Repositories.Interfaces;
using InventoryManagement.Services;
using InventoryManagement.Services.Interfaces;

var builder = WebApplication.CreateBuilder(args);

// Services
builder.Services.AddControllers();
builder.Services.AddSingleton<DapperContext>();

//  CORS (ALLOW FLUTTER WEB � DEV MODE)

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()   // IMPORTANT for Flutter Web (random port)
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

// Repositories
builder.Services.AddScoped<IToolRepository, ToolRepository>();
builder.Services.AddScoped<IToolService, ToolService>();

builder.Services.AddScoped<IMmdsRepository, MmdsRepository>();
builder.Services.AddScoped<IMmdsService, MmdsService>();

builder.Services.AddScoped<IAssetsConsumablesRepository, AssetsConsumablesRepository>();
builder.Services.AddScoped<IAssetsConsumablesService, AssetsConsumablesService>();

builder.Services.AddScoped<IMasterRegisterRepository, MasterRegisterRepository>();
builder.Services.AddScoped<IMasterRegisterService, MasterRegisterService>();

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddScoped<IQualityRepository, QualityRepository>();
builder.Services.AddScoped<IQualityService, QualityService>();


var app = builder.Build();


// Middleware
app.UseSwagger();
app.UseSwaggerUI();

// ? CORS MUST COME BEFORE Authorization
app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();
