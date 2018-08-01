using System;
using System.Collections.Generic;
using System.DirectoryServices.AccountManagement;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace AdHelpers
{
    public class LDAPHelper
    {
        public static string GetUPN(string userName)
        {
            var upn = string.Empty;

            try
            {
                PrincipalContext ctx = new PrincipalContext(ContextType.Domain);

                UserPrincipal user = UserPrincipal.FindByIdentity(ctx, userName);
                if (user == null)
                {
                    return null;
                }
                else
                {
                    upn = user.UserPrincipalName;
                    return upn;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());
            }
            return null;
        }
    }
}
