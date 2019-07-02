using System.Threading.Tasks;

namespace Tailwind.Traders.WebBff.Services
{
    public class RegisterService : IRegisterService
    {
        public async Task<bool> RegisterUserIfNotExists(string userName)
        {
            try
            {
                var client = new RegistrationUserService.UserServiceClient();
                return await client.RegistrationAsync(userName);
            }
            catch (System.Exception e)
            {
                var error = e;
                throw;
            }
            
        }
    }
}
