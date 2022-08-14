using app.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Text.Json;

namespace app.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IHttpClientFactory _httpClientFactory;

        public HomeController(ILogger<HomeController> logger, IHttpClientFactory httpClientFactory)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _httpClientFactory = httpClientFactory ?? throw new ArgumentNullException(nameof(httpClientFactory));
        }

        public async Task<IActionResult> IndexAsync()
        {
            string? result;
            try
            {
                _logger.LogInformation("GetWeatherForecast APP Start");

                var client = _httpClientFactory.CreateClient("WeatherServiceClient");

                var apiResult = await client.GetAsync("/WeatherForecast");
                if (!apiResult.IsSuccessStatusCode)
                {
                    result = JsonSerializer.Serialize(new { apiResult.ReasonPhrase, apiResult.StatusCode });
                }
                else
                {
                    result = await apiResult.Content.ReadAsStringAsync();
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