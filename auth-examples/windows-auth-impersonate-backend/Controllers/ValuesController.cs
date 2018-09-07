using System;
using System.Collections.Generic;
using System.DirectoryServices.AccountManagement;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Principal;
using System.Web;
using System.Web.Http;
using AdHelpers;
using Microsoft.Ajax.Utilities;

namespace windows_auth_impersonate.Controllers
{
    [Authorize]
    public class ValuesController : ApiController
    {
        // GET api/values
        public Object Get()
        {
            var windowsIdentity = User.Identity as WindowsIdentity;

            if (windowsIdentity is null)
            {
                return "not using windows auth.";
            }

            Ldap ldapInfo = new Ldap();
            try
            {
                PrincipalContext ctx = new PrincipalContext(ContextType.Domain);
                ldapInfo.ConnectedServer = ctx.ConnectedServer;
                ldapInfo.Container = ctx.Container;

                var identity = UserPrincipal.FindByIdentity(ctx, windowsIdentity.Name);
                ldapInfo.UserPrincipalName = identity?.UserPrincipalName;
            }
            catch (Exception ex)
            {
                ldapInfo.ErrorMessage = ex.ToString();
            }

            return new AdInfo()
            {
                MachineName = Environment.MachineName,
                AuthenticationType = User.Identity.AuthenticationType.ToString(),
                ImpersonationLevel = windowsIdentity.ImpersonationLevel.ToString(),
                Claims = windowsIdentity.Claims.DistinctBy(claim => claim.Type).ToDictionary(claim => claim.Type, claim => claim.Value),
                Groups = windowsIdentity.Groups.Select(x => new AdGroup()
                {
                    Name = AdGroup.ToName(x),
                    Value = x.Value
                }).ToList(),
                LDAP = ldapInfo,
            };
        }

        
        public string Get(int id)
        {
            return "value";
        }

        // POST api/values
        public void Post([FromBody]string value)
        {
        }

        // PUT api/values/5
        public void Put(int id, [FromBody]string value)
        {
        }

        // DELETE api/values/5
        public void Delete(int id)
        {
        }
    }
}
