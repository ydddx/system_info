system_info2
=====

A fork of system_info as the original maintainer no longer wishes to do so.

Thanks to onepub.dev for allowing me the time and resources to support this package.

Provides easy access to useful information about the system (architecture, bitness, kernel, memory, operating system, CPU, user).

system_info2 lets you discover specific hardware characteristics of the OS you are running on includeing:

* kernelArchitecture
* Kernel bitness          
* Kernel name             
* Kernel version          
* Operating system name   
* Operating system version
* User directory          
* User id                 
* User name               
* User space bitness      

**Basic examples:**

```dart
if (SysInfo.operatingSystemName == "Ubuntu") {
  log.info("We love Ubuntu users");
}
```

## Documentation

You can find the manual at: 

[sysinfo.onepub.dev](https://sysinfo.onepub.dev)
