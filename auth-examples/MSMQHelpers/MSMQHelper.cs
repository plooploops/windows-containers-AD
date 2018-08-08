using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Messaging;
using System.IO;
using System.Security.Principal;
using Microsoft.Win32;
using AdHelpers;

namespace MSMQHelpers
{
    public class MSMQHelper
    {
        public enum TraceLevel
        {
            None = 0,
            Environment = 1,
            Info = 2,
            Debug = 3
        }

        private TraceLevel _traceLevel;
        public TraceLevel Trace
        {
            get
            {
                string traceLevel = Environment.GetEnvironmentVariable("TRACE_LEVEL") ?? _traceLevel.ToString();
                _traceLevel = GetTraceLevel(traceLevel);
                return _traceLevel;
            }
            set
            {
                _traceLevel = value;
            }
        }

        private string _user;
        public string User
        {
            get
            {
                string user = Environment.GetEnvironmentVariable("USER") ?? _user;
                _user = user;
                return _user;
            }
            set
            {
                _user = value;
            }
        }
        private string _password;
        public string Password
        {
            get
            {
                string password = Environment.GetEnvironmentVariable("PASSWORD") ?? _password;
                _password = password;
                return _password;
            }
            set
            {
                _password = value;
            }
        }
        private string _remoteQueueMachineName;
        public string RemoteQueueMachineName
        {
            get
            {
                string remoteQueueMachineName = Environment.GetEnvironmentVariable("RemoteQueueMachineName") ?? _remoteQueueMachineName;
                _remoteQueueMachineName = remoteQueueMachineName;
                return _remoteQueueMachineName;
            }
            set
            {
                _remoteQueueMachineName = value;
            }
        }

        /// <summary>
        /// used for Direct Format Name (E.g. OS, TCP, etc)
        /// https://msdn.microsoft.com/en-us/library/ms700996(v=vs.85).aspx
        /// </summary>
        private string _directFormatProtocol;
        public string DirectFormatProtocol
        {
            get
            {
                string directQueueFormatProtocol = Environment.GetEnvironmentVariable("DirectQueueFormatProtocol") ?? _directFormatProtocol;
                _directFormatProtocol = directQueueFormatProtocol;
                return _directFormatProtocol;
            }
            set
            {
                _directFormatProtocol = value;
            }
        }

        public MSMQHelper()
        {
            Trace = TraceLevel.None;
        }

        public MSMQHelper(string traceLevel)
        {
            Trace = GetTraceLevel(traceLevel);
        }

        public TraceLevel GetTraceLevel(string traceLevel)
        {
            TraceLevel tl = TraceLevel.None;
            Enum.TryParse(traceLevel, out tl);

            return tl;
        }

        static void AttemptImpersonateUser(string user, Action action)
        {
            //still need to get run time version to work.
            string upn = LDAPHelper.GetUPN(user);
            if (string.IsNullOrEmpty(upn))
            {
                //unable to find the user.
                Console.WriteLine(String.Format("Unable to find user: {0} in domain.", user));
                action();
                Console.WriteLine("Ran action without impersonation");
            }
            else
            {
                using (System.Security.Principal.WindowsImpersonationContext impersonationContext =
                       new WindowsIdentity(upn).Impersonate())
                {
                    Console.WriteLine("Impersonating user: " + user);
                    action();
                    Console.WriteLine("Ran action with impersonation");
                }
            }
        }

        public string GetDirectFormatName(string qnamePath, string directFormatProtocol)
        {
            string protocol = String.IsNullOrEmpty(directFormatProtocol) ? DirectFormatProtocol : directFormatProtocol;
            return string.Format("FormatName:DIRECT={1}:{0}", qnamePath, protocol);
        }

        public string GetDirectFormatName(string machineName, string qname, string directFormatProtocol, bool privateQueue)
        {
            string protocol = String.IsNullOrEmpty(directFormatProtocol) ? DirectFormatProtocol : directFormatProtocol;
            return (privateQueue) ? string.Format("FormatName:DIRECT={2}:{0}\\private$\\{1}", machineName, qname, protocol) : string.Format("FormatName:DIRECT={2}:{0}\\{1}", machineName, qname, protocol);
        }

        public string GetQueueName(string machineName, string qname, bool privateQueue)
        {
            return (privateQueue) ? string.Format("{0}\\private$\\{1}", machineName, qname) : string.Format("{0}\\{1}", machineName, qname);
        }

        public MessageQueue GetMessageQueue(string path, bool sharedModeDenyReceive = false, bool enableCache = false, QueueAccessMode accessMode = QueueAccessMode.SendAndReceive){

            MessageQueue mq = new MessageQueue(path, sharedModeDenyReceive, enableCache, accessMode);
            Console.WriteLine("Set up Message Queue: " + mq.Path);
            Console.WriteLine("Access Mode" + mq.AccessMode);
            Console.WriteLine("Deny Shared Receive" + mq.DenySharedReceive);
            return mq;
        }

        void CreateQueue(string qname, bool transactional = true)
        {
            Console.WriteLine("Testing with Queue Name: " + qname);

            try
            {
                string upn = LDAPHelper.GetUPN(User);

                if (string.IsNullOrEmpty(upn))
                {
                    //unable to find the user.
                    Console.WriteLine("Unable to find user in domain, trying out a regular path instead");
                    StringBuilder sb = new StringBuilder();
                    sb.AppendLine("Computer Name: " + Environment.MachineName);
                    sb.AppendLine("Logged in User: " + WindowsIdentity.GetCurrent().Name);
                    //sb.AppendLine("Registry Key Value: " + RegistryHelper.GetRegistryValue(Constants.REGISTRY_HKLM, Constants.REGISTRY_MSMQ_PARAMETERS, Constants.REGISTRY_MSMQ_WORKGROUP));

                    Console.WriteLine(sb.ToString());
                    if (!MessageQueue.Exists(qname))
                    {
                        Console.WriteLine("Queue doesn't exist so we will create one.");
                        MessageQueue mq = MessageQueue.Create(qname, transactional);
                        //This should only be set for containers.  Otherwise we can use the Current User WindowsIdentity.GetCurrent().Name
                        mq.SetPermissions(Constants.EVERYONE, MessageQueueAccessRights.FullControl);
                        Console.WriteLine("Setting Permissions");
                        mq.SetPermissions(Constants.AUTHENTICATED_USERS, MessageQueueAccessRights.FullControl);
                        Console.WriteLine("Finished Setting Permissions");
                    }
                    Console.WriteLine("Queue should exist! " + qname);
                    Console.WriteLine("Ran action without impersonation");
                }
                else
                {
                    using (System.Security.Principal.WindowsImpersonationContext impersonationContext =
                           new WindowsIdentity(upn).Impersonate())
                    {
                        Console.WriteLine("Impersonating user: " + upn);
                        StringBuilder sb = new StringBuilder();
                        sb.AppendLine("Computer Name: " + Environment.MachineName);
                        sb.AppendLine("Logged in User: " + WindowsIdentity.GetCurrent().Name);
                        //sb.AppendLine("Registry Key Value: " + RegistryHelper.GetRegistryValue(Constants.REGISTRY_HKLM, Constants.REGISTRY_MSMQ_PARAMETERS, Constants.REGISTRY_MSMQ_WORKGROUP));

                        Console.WriteLine(sb.ToString());
                        if (!MessageQueue.Exists(qname))
                        {
                            Console.WriteLine("Queue doesn't exist so we will create one.");
                            MessageQueue mq = MessageQueue.Create(qname, transactional);
                            //This should only be set for containers.  Otherwise we can use the Current User WindowsIdentity.GetCurrent().Name
                            mq.SetPermissions(Constants.EVERYONE, MessageQueueAccessRights.FullControl);
                            Console.WriteLine("Setting Permissions");
                            mq.SetPermissions(Constants.AUTHENTICATED_USERS, MessageQueueAccessRights.FullControl);
                            Console.WriteLine("Finished Setting Permissions");
                        }
                        Console.WriteLine("Queue should exist! " + qname);
                        Console.WriteLine("Ran action with impersonation");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("issue with sending message.");
                Console.WriteLine(ex.ToString());
            }
        }

        public void SendMessage(string qname, string directFormatProtocol, string messageBody, string label)
        {
            CreateQueue(qname);

            try
            {
                string upn = LDAPHelper.GetUPN(User);
                string directFormatName = GetDirectFormatName(qname, directFormatProtocol);
                if (string.IsNullOrEmpty(upn))
                {
                    //unable to find the user.
                    Console.WriteLine("Unable to find User in domain, trying out a regular path instead");
                    Message msg = new Message();
                    int len = messageBody.Length;
                    if (len > Constants.MAX_MESSAGE_SIZE)
                    {
                        //do something here?
                        Console.WriteLine("Message contents larger than expected, possible truncation.");
                    }
                    msg.BodyStream = new MemoryStream(Encoding.ASCII.GetBytes(messageBody));
                    msg.Label = label;
                    msg.UseDeadLetterQueue = true;
                    MessageQueue mq = GetMessageQueue(qname, accessMode: QueueAccessMode.PeekAndAdmin);
                    Console.WriteLine(GetQueueMetadata(qname));
                    mq.Close();
                    mq.Dispose();
                    
                    //send with direct format name
                    Console.WriteLine(String.Format("Send with Direct Format Queue Name: {0}", directFormatName));
                    mq = GetMessageQueue(directFormatName, accessMode: QueueAccessMode.Send);
                    mq.Send(msg, MessageQueueTransactionType.Single);
                    mq.Close();
                    mq.Dispose();
                }
                else
                {
                    using (System.Security.Principal.WindowsImpersonationContext impersonationContext =
                           new WindowsIdentity(upn).Impersonate())
                    {
                        Message msg = new Message();
                        int len = messageBody.Length;
                        if (len > Constants.MAX_MESSAGE_SIZE)
                        {
                            //do something here?
                            Console.WriteLine("Message contents larger than expected, possible truncation.");
                        }
                        msg.BodyStream = new MemoryStream(Encoding.ASCII.GetBytes(messageBody));
                        msg.Label = label;
                        msg.UseDeadLetterQueue = true;
                        MessageQueue mq = GetMessageQueue(qname, accessMode: QueueAccessMode.PeekAndAdmin);
                        Console.WriteLine(GetQueueMetadata(qname));
                        mq.Close();
                        mq.Dispose();

                        //send with direct format name
                        Console.WriteLine(String.Format("Send with Direct Format Queue Name: {0}", directFormatName));
                        mq = GetMessageQueue(directFormatName, accessMode: QueueAccessMode.Send);
                        mq.Send(msg, MessageQueueTransactionType.Single);
                        mq.Close();
                        mq.Dispose();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("issue with sending message.");
                Console.WriteLine(ex.ToString());
            }
        }

        public Message ReceiveMessage(string qname, string directFormatProtocol)
        {
            Message msg = null;

            try
            {
                string upn = LDAPHelper.GetUPN(User);
                string directFormatName = GetDirectFormatName(qname, directFormatProtocol);

                if (string.IsNullOrEmpty(upn))
                {
                    //unable to find the user.
                    Console.WriteLine("Unable to find user in domain, trying out a regular path instead");
                    MessageQueue mq = GetMessageQueue(qname, accessMode: QueueAccessMode.PeekAndAdmin);
                    Console.WriteLine(GetQueueMetadata(qname));
                    mq.Close();
                    mq.Dispose(); //Release usage of queue
                    //Does this need to use direct queue name?
                    Console.WriteLine(String.Format("Receive with Direct Format Queue Name: {0}", directFormatName));
                    mq = GetMessageQueue(directFormatName, accessMode: QueueAccessMode.Receive);
                    msg = mq.Receive();
                    long len = msg.BodyStream.Length;

                    byte[] msgBodyBytes = new byte[(Constants.MAX_MESSAGE_SIZE < (int)len) ? Constants.MAX_MESSAGE_SIZE : (int)len];
                    if (len > Constants.MAX_MESSAGE_SIZE)
                    {
                        //do something here?
                        Console.WriteLine("Message contents larger than expected, possible truncation.");
                    }
                    msg.BodyStream.Read(msgBodyBytes, 0, (int)len);
                    //repack the message contents into the body of the message.
                    msg.Body = Encoding.ASCII.GetString(msgBodyBytes);
                    mq.Close();
                    mq.Dispose();
                }
                else
                {
                    using (System.Security.Principal.WindowsImpersonationContext impersonationContext =
                           new WindowsIdentity(upn).Impersonate())
                    {
                        MessageQueue mq = GetMessageQueue(qname, accessMode: QueueAccessMode.PeekAndAdmin);
                        Console.WriteLine(GetQueueMetadata(qname));
                        mq.Close();
                        mq.Dispose();

                        //Does this need to use direct queue name?
                        Console.WriteLine(String.Format("Receive with Direct Format Queue Name: {0}", directFormatName));
                        mq = GetMessageQueue(directFormatName);
                        msg = mq.Receive();
                        long len = msg.BodyStream.Length;

                        byte[] msgBodyBytes = new byte[(Constants.MAX_MESSAGE_SIZE < (int)len) ? Constants.MAX_MESSAGE_SIZE : (int)len];
                        if (len > Constants.MAX_MESSAGE_SIZE)
                        {
                            //do something here?
                            Console.WriteLine("Message contents larger than expected, possible truncation.");
                        }
                        msg.BodyStream.Read(msgBodyBytes, 0, (int)len);
                        //repack the message contents into the body of the message.
                        msg.Body = Encoding.ASCII.GetString(msgBodyBytes);
                        mq.Close();
                        mq.Dispose();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("issue with sending message.");
                Console.WriteLine(ex.ToString());
            }

            return msg;
        }

        public string GetQueueMetadata(string qname)
        {
            StringBuilder sb = new StringBuilder();
            string ret = string.Empty;
            try
            {
                MessageQueue mq = GetMessageQueue(qname, accessMode: QueueAccessMode.PeekAndAdmin);

                if (Trace >= TraceLevel.None)
                {
                    sb.AppendLine(Constants.TRACE_LINE_BREAK);
                    sb.AppendLine("Requested Queue Name: " + qname);
                    sb.AppendLine("Computer Name: " + Environment.MachineName);
                    sb.AppendLine("Logged in User: " + WindowsIdentity.GetCurrent().Name);
                    //sb.AppendLine("Registry Key Value: " + RegistryHelper.GetRegistryValue(Constants.REGISTRY_HKLM, Constants.REGISTRY_MSMQ_PARAMETERS, Constants.REGISTRY_MSMQ_WORKGROUP));
                    sb.AppendLine("Queue Name: " + mq.QueueName);
                    sb.AppendLine("Path: " + mq.Path);
                    sb.AppendLine("Messages in Queue: " + mq.GetAllMessages().Length);
                }

                if (Trace >= TraceLevel.Environment)
                {
                    sb.AppendLine(Constants.TRACE_LINE_BREAK);
                    sb.AppendLine("Environment Variable QUEUE_NAME: " + Environment.GetEnvironmentVariable("QUEUE_NAME"));
                    sb.AppendLine("TRACE_LEVEL: " + Trace);
                }

                if (Trace >= TraceLevel.Info)
                {
                    sb.AppendLine(Constants.TRACE_LINE_BREAK);
                    sb.AppendLine("Id: " + mq.Id);
                    sb.AppendLine("Label: " + mq.Label);
                    sb.AppendLine("Format Name: " + mq.FormatName);
                    sb.AppendLine("Formatter: " + mq.Formatter);
                    sb.AppendLine("Access Mode: " + mq.AccessMode);
                    sb.AppendLine("Authenticate: " + mq.Authenticate);
                    sb.AppendLine("Can Read: " + mq.CanRead);
                    sb.AppendLine("Can Write: " + mq.CanWrite);
                    sb.AppendLine("Category: " + mq.Category);
                    sb.AppendLine("Create Time: " + mq.CreateTime);
                    //sb.AppendLine("Default Properties To Send: " + mq.DefaultPropertiesToSend);
                    sb.AppendLine("Deny Shared Received: " + mq.DenySharedReceive);
                    sb.AppendLine("Encryption Required: " + mq.EncryptionRequired);
                    sb.AppendLine("Last Modify Time: " + mq.LastModifyTime);
                    sb.AppendLine("Machine Name: " + mq.MachineName);
                }

                if (Trace >= TraceLevel.Debug)
                {
                    sb.AppendLine(Constants.TRACE_LINE_BREAK);
                    sb.AppendLine("Maximum Journal Size: " + mq.MaximumJournalSize);
                    sb.AppendLine("Maximum Queue Size: " + mq.MaximumQueueSize);
                    //sb.AppendLine("Message Read Property Filter: " + mq.MessageReadPropertyFilter);
                    sb.AppendLine("Multicast Address: " + mq.MulticastAddress);
                    sb.AppendLine("Site: " + mq.Site);
                    sb.AppendLine("Transactional: " + mq.Transactional);
                    sb.AppendLine("Use Journal Queue: " + mq.UseJournalQueue);
                }
                ret = sb.ToString();
                mq.Close();
                mq.Dispose();
            }
            catch (Exception ex)
            {
                ret = ex.Message;
            }

            return ret;
        }
    }
}
