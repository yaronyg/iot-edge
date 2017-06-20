using System;
using Microsoft.Azure.Devices.Gateway;

namespace HelloWorldModule
{
    public class DotNetHelloWorldModule : IGatewayModule, IGatewayModuleStart
    {
        private string configuration;
        public void Create(Broker broker, byte[] configuration)
        {
            this.configuration = System.Text.Encoding.UTF8.GetString(configuration);
            Console.WriteLine("I have been created!");
        }

        public void Start()
        {
            Console.WriteLine("We are saying HELLO WORLD!!!!!");
        }

        public void Destroy()
        {
            Console.WriteLine("I have been destroyed!");
        }

        public void Receive(Message received_message)
        {
        }
    }
}
