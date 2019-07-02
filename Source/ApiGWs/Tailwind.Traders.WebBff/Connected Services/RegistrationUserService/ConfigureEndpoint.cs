using Microsoft.Extensions.Configuration;
using System.IO;

namespace RegistrationUserService
{
    public partial class UserServiceClient : System.ServiceModel.ClientBase<RegistrationUserService.IUserService>, RegistrationUserService.IUserService
    {
        static partial void ConfigureEndpoint(System.ServiceModel.Description.ServiceEndpoint serviceEndpoint, System.ServiceModel.Description.ClientCredentials clientCredentials)
        {
            var registrationSvcEndpoint = new ConfigurationBuilder()
                        .SetBasePath(Directory.GetCurrentDirectory())
                        .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                        .AddEnvironmentVariables()
                        .Build()["RegistrationUsersEndpoint"];            

            serviceEndpoint.Address =
                new System.ServiceModel.EndpointAddress(new System.Uri(registrationSvcEndpoint),
                new System.ServiceModel.DnsEndpointIdentity(""));
        }
    }
}