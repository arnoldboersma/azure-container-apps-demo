using Appblazor.Client.Pages;
using Appblazor.Components;
using Microsoft.ApplicationInsights.Extensibility;

namespace Appblazor;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddApplicationInsightsTelemetry();

        builder.Services.Configure<TelemetryConfiguration>((o) =>
        {
            o.TelemetryInitializers.Add(new AppInsightsTelemetryInitializer());
        });

        // Add services to the container.
        builder.Services.AddRazorComponents()
            .AddInteractiveServerComponents()
            .AddInteractiveWebAssemblyComponents();

        var app = builder.Build();

        // Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseWebAssemblyDebugging();
        }
        else
        {
            app.UseExceptionHandler("/Error");
        }

        app.UseStaticFiles();
        app.UseAntiforgery();

        app.MapRazorComponents<App>()
            .AddInteractiveServerRenderMode()
            .AddInteractiveWebAssemblyRenderMode()
            .AddAdditionalAssemblies(typeof(Counter).Assembly);

        app.Run();
    }
}
