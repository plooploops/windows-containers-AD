using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AdHelpers
{
    public class AdInfo
    {
        public string MachineName { get; set; }
        public string AuthenticationType { get; set; }
        public string ImpersonationLevel { get; set; }
        public Dictionary<string, string> Claims { get; set; }
        public List<AdGroup> Groups { get; set; }
        public Ldap LDAP { get; set; }
    }
}
