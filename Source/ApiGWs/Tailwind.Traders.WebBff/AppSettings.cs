﻿using Microsoft.Extensions.Configuration;

namespace Tailwind.Traders.WebBff
{
    public class AppSettings
    {
        private IConfigurationRoot configuration;
        
        public string ProductsApiUrl { get; set; }
        public string PopularProductsApiUrl { get; set; }
        public string ProfileApiUrl { get; set; }
        public string CouponsApiUrl { get; set; }
        public string ImageClassifierApiUrl { get; set; }
        public string LoginApiUrl { get; set; }
        public bool UseMlNetClassifier { get; set; }
        public string StockApiUrl { get; set; }
        public string Authority { get; set; }
        [Attribute("RegistrationUsers:BypassRegistrationUsers")]
        public bool BypassRegistrationUsers { get; set; }
        public string RegistrationUsersEndpoint { get; set; }
    }    
}
