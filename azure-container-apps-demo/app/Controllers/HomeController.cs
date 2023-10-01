using app.Models;
using Dapr.Client;
using Microsoft.AspNetCore.DataProtection.KeyManagement;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;

namespace app.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        //private readonly IHttpClientFactory _httpClientFactory;

        const string storeName = "statestore";
        const string key = "GetWeatherForecastCounter";

        public HomeController(ILogger<HomeController> logger, IHttpClientFactory httpClientFactory)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            //_httpClientFactory = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
        }

        public async Task<IActionResult> IndexAsync()
        {
            string? result;
            try
            {
                _logger.LogInformation("GetWeatherForecast APP Start");

                //var client = _httpClientFactory.CreateClient("WeatherServiceClient");

                var daprClient = new DaprClientBuilder().Build();
                var counter = await daprClient.GetStateAsync<int>(storeName, key);
                _logger.LogInformation("GetWeatherForecast APP Current counter value: {counter}", counter);
                counter++;


                await daprClient.SaveStateAsync(storeName, key, counter);
                //var apiResult = await client.GetAsync("/WeatherForecast");

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
}