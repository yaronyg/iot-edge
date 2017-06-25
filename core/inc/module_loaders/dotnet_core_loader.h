// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

#ifndef DOTNET_CORE_LOADER_H
#define DOTNET_CORE_LOADER_H

#include "azure_c_shared_utility/strings.h"
#include "azure_c_shared_utility/umock_c_prod.h"

#include "module.h"
#include "module_loader.h"
#include "gateway_export.h"
#include "dotnetcore.h"


#ifdef __cplusplus
extern "C"
{
#endif

#define DOTNET_CORE_LOADER_NAME            "dotnetcore"

#define WIN32_PROGRAM_FILES_PATH                                      "C:\\Program Files\\"
#define WIN64_PROGRAM_FILES_PATH                                      "C:\\Program Files (x86)\\"
#define WIN_DOTNET_PATH                                               "dotnet\\shared\\Microsoft.NETCore.App\\"
#define CORECLR_DLL                                                   "\\coreclr.dll"
#define END_PATH_WINDOWS                                              "\\"

//#define DOT_NET_VERSION                                               "1.1.1"

#define UNIX_DOTNET_PATH                                              "/usr/share/dotnet/shared/Microsoft.NETCore.App/"
#define LIBCORECLR_SO                                                 "/libcoreclr.so"
#define END_PATH_UNIX                                                 "/"

#ifdef _WIN64
#define DOTNET_CORE_BINDING_MODULE_NAME                                "dotnetcore.dll"
#define DOTNET_CORE_CLR_PATH_DEFAULT                                   WIN32_PROGRAM_FILES_PATH WIN_DOTNET_PATH DOT_NET_VERSION CORECLR_DLL
#define DOTNET_CORE_TRUSTED_PLATFORM_ASSEMBLIES_LOCATION_DEFAULT       WIN32_PROGRAM_FILES_PATH WIN_DOTNET_PATH DOT_NET_VERSION END_PATH_WINDOWS
#elif WIN32
#define DOTNET_CORE_BINDING_MODULE_NAME                                "dotnetcore.dll"
#define DOTNET_CORE_CLR_PATH_DEFAULT                                   WIN64_PROGRAM_FILES_PATH WIN_DOTNET_PATH DOT_NET_VERSION CORECLR_DLL
#define DOTNET_CORE_TRUSTED_PLATFORM_ASSEMBLIES_LOCATION_DEFAULT       WIN64_PROGRAM_FILES_PATH WIN_DOTNET_PATH DOT_NET_VERSION END_PATH_WINDOWS
#else
#define DOTNET_CORE_BINDING_MODULE_NAME                                "libdotnetcore.so"
#define DOTNET_CORE_CLR_PATH_DEFAULT                                   UNIX_DOTNET_PATH DOT_NET_VERSION LIBCORECLR_SO
#define DOTNET_CORE_TRUSTED_PLATFORM_ASSEMBLIES_LOCATION_DEFAULT       UNIX_DOTNET_PATH DOT_NET_VERSION END_PATH_UNIX
#endif

#define DOTNET_CORE_CLR_PATH_KEY                                "binding.coreclrpath"
#define DOTNET_CORE_TRUSTED_PLATFORM_ASSEMBLIES_LOCATION_KEY    "binding.trustedplatformassemblieslocation"
   
/** @brief Module Loader Configuration, including clrOptions Configuration. */
typedef struct DOTNET_CORE_LOADER_CONFIGURATION_TAG
{
    MODULE_LOADER_BASE_CONFIGURATION base;
    DOTNET_CORE_CLR_OPTIONS* clrOptions;
} DOTNET_CORE_LOADER_CONFIGURATION;

/** @brief Structure to load a dotnet module */
typedef struct DOTNET_CORE_LOADER_ENTRYPOINT_TAG
{
    STRING_HANDLE dotnetCoreModulePath;

    STRING_HANDLE dotnetCoreModuleEntryClass;
} DOTNET_CORE_LOADER_ENTRYPOINT;

MOCKABLE_FUNCTION(, GATEWAY_EXPORT const MODULE_LOADER*, DotnetCoreLoader_Get);

#ifdef __cplusplus
}
#endif

#endif // DOTNET_CORE_LOADER_H