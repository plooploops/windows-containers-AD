using MSMQHelpers;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Messaging;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace MSMQSenderTest
{
    class Program
    {

        static void Main(string[] args)
        {
            FileStream ostrm;
            StreamWriter writer;
            TextWriter oldOut = Console.Out;
            try
            {
                ostrm = new FileStream("./MSMQSender.txt", FileMode.OpenOrCreate, FileAccess.Write);
                writer = new StreamWriter(ostrm);
            }
            catch (Exception e)
            {
                Console.WriteLine("Cannot open Redirect.txt for writing");
                Console.WriteLine(e.Message);
                return;
            }
            Console.SetOut(writer);
            
            MSMQHelper msmqHelper = new MSMQHelper();
            
            string queueName = Environment.GetEnvironmentVariable("QUEUE_NAME") ?? Constants.PRIVATE_QUEUE_NAME;
            string directFormatProtocol = Environment.GetEnvironmentVariable("DIRECT_FORMAT_PROTOCOL") ?? Constants.DIRECT_FORMAT_PROTOCOL;
            Console.WriteLine("This should run as a separate user from the receiving app.");
            while (true)
            {
                try
                {
                    msmqHelper.SendMessage(queueName, directFormatProtocol, "hello test", "hello");
                    Console.WriteLine("Sent a message");
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                }
                Console.WriteLine("This will try to send a message.");
                Thread.Sleep(1000);
                //Console.ReadLine();
            }
        }
    }
}
