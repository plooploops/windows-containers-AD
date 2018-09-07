using System.Web;
using System.Web.Mvc;

namespace windows_auth_impersonate_globalasax_backend
{
    public class FilterConfig
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }
    }
}
