using System;
using System.Collections.Generic;
using System.DirectoryServices.AccountManagement;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using AdHelpers;

namespace windows_auth_impersonate_explicit_frontend.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            ViewBag.MachineName = Server.MachineName;
            ViewBag.AuthenticationType = Request?.LogonUserIdentity.AuthenticationType;
            ViewBag.ImpersonationLevel = Request?.LogonUserIdentity.ImpersonationLevel;
            ViewBag.Claims = Request?.LogonUserIdentity.Claims;

            ViewBag.Groups = Request?.LogonUserIdentity.Groups.Select(x => new AdGroup()
            {
                Name = AdGroup.ToName(x),
                Value = x.Value
            });


            Ldap ldapInfo = new Ldap();
            try
            {
                PrincipalContext ctx = new PrincipalContext(ContextType.Domain);
                ldapInfo.ConnectedServer = ctx.ConnectedServer;
                ldapInfo.Container = ctx.Container;

                var identity = UserPrincipal.FindByIdentity(ctx, Request.LogonUserIdentity.Name);
                ldapInfo.UserPrincipalName = identity.UserPrincipalName;
            }
            catch (Exception ex)
            {
                ldapInfo.ErrorMessage = ex.ToString();
            }

            ViewBag.LdapInfo = ldapInfo;

            return View();
        }

        private string GoGetsomevarINeed()
        {
            throw new NotImplementedException();
        }

        public async Task<ActionResult> About()
        {
            AdInfo adinfo = new AdInfo();

            var apiBaseUrl = Environment.GetEnvironmentVariable("API_URL") ?? "http://localhost:60201/";
            using (System.Security.Principal.WindowsImpersonationContext impersonationContext =
                    ((System.Security.Principal.WindowsIdentity)Request.LogonUserIdentity).Impersonate())
            {
                var client = new HttpClient(new HttpClientHandler() { UseDefaultCredentials = true });
                client.BaseAddress = new Uri(apiBaseUrl);
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(
                    new MediaTypeWithQualityHeaderValue("application/json"));

                var response = await client.GetAsync("api/values");
                if (response.IsSuccessStatusCode)
                {
                    string data = await response.Content.ReadAsStringAsync();
                    JavaScriptSerializer JSserializer = new JavaScriptSerializer();
                    adinfo = JSserializer.Deserialize<AdInfo>(data);
                }
            }
            return View(adinfo);
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}