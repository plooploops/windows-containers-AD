using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MSMQHelpers
{
    class RegistryHelper
    {
        public static object GetRegistryValue(string hive_HKLM_or_HKCU, string registryRoot, string valueName)
        {
            RegistryKey root;
            switch (hive_HKLM_or_HKCU.ToUpper())
            {
                case Constants.REGISTRY_HKLM:
                    root = Registry.LocalMachine.OpenSubKey(registryRoot, false);
                    break;
                case Constants.REGISTRY_HKCU:
                    root = Registry.CurrentUser.OpenSubKey(registryRoot, false);
                    break;
                default:
                    throw new System.InvalidOperationException("parameter registryRoot must be either \"HKLM\" or \"HKCU\"");
            }

            return root.GetValue(valueName);
        }

        public static bool RegistryValueExists(string hive_HKLM_or_HKCU, string registryRoot, string valueName)
        {
            RegistryKey root;
            switch (hive_HKLM_or_HKCU.ToUpper())
            {
                case Constants.REGISTRY_HKLM:
                    root = Registry.LocalMachine.OpenSubKey(registryRoot, false);
                    break;
                case Constants.REGISTRY_HKCU:
                    root = Registry.CurrentUser.OpenSubKey(registryRoot, false);
                    break;
                default:
                    throw new System.InvalidOperationException("parameter registryRoot must be either \"HKLM\" or \"HKCU\"");
            }

            return root.GetValue(valueName) != null;
        }
    }
}
