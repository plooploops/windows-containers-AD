using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;
using AdHelpers;

namespace windows_auth_simple.Controllers
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


            Ldap ldapInfo =new Ldap();
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

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}