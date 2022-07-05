using app.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

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
            var result = string.Empty;
            try
            {
                _logger.LogInformation("GetWeatherForecast APP Start");

                var client = _httpClientFactory.CreateClient("WeatherServiceClient");

                var apiResult = await client.GetAsync("/WeatherForecast");
                result = await apiResult.Content.ReadAsStringAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "GetWeatherForecast APP failed");
                result = ex.Message;
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