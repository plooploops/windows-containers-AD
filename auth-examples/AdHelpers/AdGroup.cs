using System.Security.Principal;

namespace AdHelpers
{
    public class AdGroup
    {
        public string Name { get; set; }
        public string Value { get; set; }

        public static string ToName(IdentityReference id)
        {
            return new SecurityIdentifier(id.Value).Translate(typeof(NTAccount)).ToString();
        }
    }
}