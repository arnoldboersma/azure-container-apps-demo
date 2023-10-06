using app;
using Microsoft.ApplicationInsights.Extensibility;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddApplicationInsightsTelemetry();

builder.Services.Configure<TelemetryConfiguration>((o) => {
    o.TelemetryInitializers.Add(new AppInsightsTelemetryInitializer());
});


//builder.Services.AddHttpClient("WeatherServiceClient", httpClient =>
//{
//    httpClient.BaseAddress = new Uri(builder.Configuration["API_BASE_URL"]);
//    httpClient.Timeout = new TimeSpan(0, 0, 3);
//});
var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

Console.WriteLine("Hello");

//app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

//app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
