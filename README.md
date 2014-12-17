system_info
=====

Provides easy access to useful information about the system (architecture, bitness, kernel, operating system, CPU, user).

Version: 0.0.7

Warning! Not tested on Mac OS X!
Warning! Not tested on Linux ARM!

**Basic examples:**

```dart
if (SysInfo.operatingSystemName == "Ubuntu") {
  log.info("We love Ubuntu users");
}
```

```dart
if (SysInfo.userSpaceBitness == 32) {
  log.info("Dart VM runs as a 32-bit process");
}
```

**Common information:**

```dart
import "package:system_info/system_info.dart";

const int MEGABYTE = 1024 * 1024;

void main() {
  print("Kernel architecture     : ${SysInfo.kernelArchitecture}");
  print("Kernel bitness          : ${SysInfo.kernelBitness}");
  print("Kernel name             : ${SysInfo.kernelName}");
  print("Kernel version          : ${SysInfo.kernelVersion}");
  print("Operating system name   : ${SysInfo.operatingSystemName}");
  print("Operating system version: ${SysInfo.operatingSystemVersion}");
  print("User directory          : ${SysInfo.userDirectory}");
  print("User id                 : ${SysInfo.userId}");
  print("User name               : ${SysInfo.userName}");
  print("User space bitness      : ${SysInfo.userSpaceBitness}");
  var processors = SysInfo.processors;
  print("Number of processors    : ${processors.length}");
  for (var processor in processors) {
    print("  Architecture          : ${processor.architecture}");
    print("  Name                  : ${processor.name}");
    print("  Socket                : ${processor.socket}");
    print("  Vendor                : ${processor.vendor}");
  }
  print("Total physical memory   : ${SysInfo.getTotalPhysicalMemory() ~/ MEGABYTE} MB");
  print("Free physical memory    : ${SysInfo.getFreePhysicalMemory() ~/ MEGABYTE} MB");
  print("Total virtual memory    : ${SysInfo.getTotalVirtualMemory() ~/ MEGABYTE} MB");
  print("Free virtual memory     : ${SysInfo.getFreeVirtualMemory() ~/ MEGABYTE} MB");
}

```

Output:

```
Kernel architecture     : i686
Kernel bitness          : 32
Kernel name             : Linux
Kernel version          : 3.13.0-43-generic
Operating system name   : Ubuntu
Operating system version: 14.04
User directory          : /home/andrew
User id                 : 1000
User name               : andrew
User space bitness      : 32
Number of processors    : 2
  Architecture          : X86_64
  Name                  : AMD Athlon(tm) II X2 240 Processor
  Socket                : 0
  Vendor                : AuthenticAMD
  Architecture          : X86_64
  Name                  : AMD Athlon(tm) II X2 240 Processor
  Socket                : 0
  Vendor                : AuthenticAMD
Total physical memory   : 3782 MB
Free physical memory    : 385 MB
Total virtual memory    : 7651 MB
Free virtual memory     : 4249 MB
```
