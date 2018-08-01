using MSMQHelpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Messaging;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace MSMQReceiverTest
{
    class Program
    {
        static void Main(string[] args)
        {
            MSMQHelper msmqHelper = new MSMQHelper();
            string queueName = Environment.GetEnvironmentVariable("QUEUE_NAME") ?? Constants.PRIVATE_QUEUE_NAME;
            string directFormatProtocol = Environment.GetEnvironmentVariable("DIRECT_FORMAT_PROTOCOL") ?? Constants.DIRECT_FORMAT_PROTOCOL;

            Console.WriteLine("This should run as a separate user from the sending app.\r\nThis will try to receive a message.");
            while (true)
            {
                try
                {
                    Message msg = msmqHelper.ReceiveMessage(queueName, directFormatProtocol);
                    Console.WriteLine(String.Format("Received a message {0}", msg.Body));
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
                Console.WriteLine("This will try to receive a message.");

                //Console.ReadLine();
                Thread.Sleep(1000);
            }
        }
    }
}
