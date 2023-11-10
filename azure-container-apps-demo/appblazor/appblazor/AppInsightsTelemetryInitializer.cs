using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;

namespace Appblazor;

public class AppInsightsTelemetryInitializer : ITelemetryInitializer
{
    public void Initialize(ITelemetry telemetry)
    {
        if (string.IsNullOrEmpty(telemetry.Context.Cloud.RoleName))
        {
            // set custom role name here
            telemetry.Context.Cloud.RoleName = "appblazor";
        }
    }
}