using InventoryManagement.Data;
using InventoryManagement.Repositories;
using InventoryManagement.Repositories.Interfaces;
using InventoryManagement.Services;
using InventoryManagement.Services.Interfaces;


var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddSingleton<DapperContext>();

builder.Services.AddScoped<IToolRepository, ToolRepository>();
builder.Services.AddScoped<IToolService, ToolService>();

builder.Services.AddScoped<IMmdsRepository, MmdsRepository>();
builder.Services.AddScoped<IMmdsService, MmdsService>();

builder.Services.AddScoped<IAssetsConsumablesRepository, AssetsConsumablesRepository>();
builder.Services.AddScoped<IAssetsConsumablesService, AssetsConsumablesService>();



builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.UseAuthorization();
app.MapControllers();
app.Run();
