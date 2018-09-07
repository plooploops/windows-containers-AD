using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

namespace windows_auth_impersonate_globalasax_backend
{
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            var testGroup = Environment.GetEnvironmentVariable("TEST_GROUP") ?? "WebUsers";

            var identity = System.Security.Principal.WindowsIdentity.GetCurrent();
            System.Diagnostics.Debug.WriteLine("Identity is " + identity.Name);
            var principal = new System.Security.Principal.WindowsPrincipal(identity);
            System.Diagnostics.Debug.WriteLine("Principal " + principal.Identity.Name + " is in role: " + principal.IsInRole(testGroup));
            if (!principal.IsInRole(testGroup))
            {
                throw new UnauthorizedAccessException("Access is denied.");
            }

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}
