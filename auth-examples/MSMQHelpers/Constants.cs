using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSMQHelpers
{
    public static class Constants
    {
        /// <summary>
        /// Trace line break
        /// </summary>
        public const string TRACE_LINE_BREAK = "******************";

        /// <summary>
        /// Computer user
        /// </summary>
        public const string REGISTRY_HKCU = "HCKU";

        /// <summary>
        /// local machine
        /// </summary>
        public const string REGISTRY_HKLM = "HKLM";

        /// <summary>
        /// MSMQ Parameters
        /// </summary>
        public const string REGISTRY_MSMQ_PARAMETERS = @"Software\Microsoft\MSMQ\Parameters\";

        /// <summary>
        /// MSMQ Workgroup mode
        /// </summary>
        public const string REGISTRY_MSMQ_WORKGROUP = "Workgroup";

        /// <summary>
        /// Queue Name
        /// </summary>
        public const string QUEUE_NAME = ".\\TestQueue1";

        /// <summary>
        /// Used for the direct format name protocol (e.g. OS, TCP, etc)
        /// https://msdn.microsoft.com/en-us/library/ms700996(v=vs.85).aspx
        /// </summary>
        public const string DIRECT_FORMAT_PROTOCOL = "OS";
        
        /// <summary>
        /// Private Queue Name
        /// </summary>
        public const string PRIVATE_QUEUE_NAME = ".\\private$\\TestQueue";

        /// <summary>
        /// 4 MB for now
        /// </summary>
        public const int MAX_MESSAGE_SIZE = 4194304;

        /// <summary>
        /// This is the user for Everyone.
        /// </summary>
        public const string EVERYONE = "Everyone";

        /// <summary>
        /// This is for the group Authenticated Users
        /// </summary>
        public const string AUTHENTICATED_USERS = "Authenticated Users";
    }
}
