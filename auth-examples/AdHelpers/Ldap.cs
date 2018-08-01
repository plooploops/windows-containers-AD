namespace AdHelpers
{
    public class Ldap
    {
        public string ConnectedServer { get; set; }
        public string Container { get; set; }
        public string UserPrincipalName { get; set; }

        public string ErrorMessage { get; set; }

        public bool HasError => !string.IsNullOrWhiteSpace(ErrorMessage);
    }
}