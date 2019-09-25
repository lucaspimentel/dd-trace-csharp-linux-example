using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using StackExchange.Redis;

namespace dd_trace_csharp_linux_example
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            Console.WriteLine("Environment variables:");

            foreach (var (key, value) in GetEnvironmentVariables())
            {
                Console.WriteLine($" {key}={value}");
            }

            Console.WriteLine();
            Console.WriteLine("Connecting to redis...");

            using (var redis = ConnectionMultiplexer.Connect("redis"))
            {
                Console.WriteLine(@"Setting value.");
                redis.GetDatabase().StringSet("x", "y");

                Console.WriteLine(@"Getting value.");
                redis.GetDatabase().StringGet("x");
            }

            Console.WriteLine("Done.");
            SpinWait.SpinUntil(() => false);
        }

        private static IEnumerable<(string key, string value)> GetEnvironmentVariables()
        {
            var prefixes = new[] {"COR_", "CORECLR_", "DD_", "DATADOG_"};

            return from envVar in Environment.GetEnvironmentVariables().Cast<DictionaryEntry>()
                   from prefix in prefixes
                   let key = (envVar.Key as string)?.ToUpperInvariant()
                   where key.StartsWith(prefix)
                   orderby key
                   select (key, envVar.Value as string);
        }
    }
}