using System.Diagnostics;
using System.Text.Json;
using App.Models;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;

namespace App.Controllers;

public class HomeController : Controller
{
    private const string StoreName = "statestore";
    private const string Key = "GetWeatherForecastCounter";

    private readonly ILogger<HomeController> _logger;

    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<IActionResult> IndexAsync()
    {
        string? result;
        try
        {
            _logger.LogInformation("GetWeatherForecast APP Start");
            var daprClient = new DaprClientBuilder().Build();
            var counter = await daprClient.GetStateAsync<int>(StoreName, Key);
            _logger.LogInformation("GetWeatherForecast APP Current counter value: {counter}", counter);
            counter++;

            await daprClient.SaveStateAsync(StoreName, Key, counter);
            var request = daprClient.CreateInvokeMethodRequest(HttpMethod.Get, "api", "WeatherForecast");
            var reponse = await daprClient.InvokeMethodWithResponseAsync(request);

            if (!reponse.IsSuccessStatusCode)
            {
                result = JsonSerializer.Serialize(new { reponse.ReasonPhrase, reponse.StatusCode });
            }
            else
            {
                result = await reponse.Content.ReadAsStringAsync();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GetWeatherForecast APP failed");
            result = JsonSerializer.Serialize(new { ex.Message, ex.StackTrace });
        }

        return View("Index", result);
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}