system_info
=====

Provides easy access to useful information about the system (architecture, bitness, kernel, operating system, CPU, user).

Version: 0.0.5

Warning! Not tested on Mac OS X!

Example:

```dart
import "package:system_info/system_info.dart";

const int MEGABYTE = 1024 * 1024;

void main() {
  print("Kernel architecture: ${SysInfo.kernelArchitecture}");
  print("Kernel bitness: ${SysInfo.kernelBitness}");
  print("Kernel name: ${SysInfo.kernelName}");
  print("Kernel version: ${SysInfo.kernelVersion}");
  print("Operating system name: ${SysInfo.operatingSystemName}");
  print("Operating system version: ${SysInfo.operatingSystemVersion}");
  print("Physical memory free size: ${SysInfo.physicalMemoryFreeSize() ~/ MEGABYTE} MB");
  print("Physical memory total size: ${SysInfo.physicalMemoryTotalSize() ~/ MEGABYTE} MB");
  print("User directory: ${SysInfo.userDirectory}");
  print("User id: ${SysInfo.userId}");
  print("User name: ${SysInfo.userName}");
  print("User space bitness: ${SysInfo.userSpaceBitness}");
  print("Virtual memory free size: ${SysInfo.virtualMemoryFreeSize() ~/ MEGABYTE} MB");
  print("Virtual memory total size: ${SysInfo.virtualMemoryTotalSize() ~/ MEGABYTE} MB");
  var processors = SysInfo.processors;
  print("Number of processors: ${processors.length}");
  for (var processor in processors) {
    print("  Name: ${processor.name}");
    print("  Socket: ${processor.socket}");
    print("  Vendor: ${processor.vendor}");
  }
}

```

Output:

```
Kernel architecture: AMD64
Kernel bitness: 64
Kernel name: Windows_NT
Kernel version: 6.1.7601
Operating system name: Microsoft Windows 7 Ultimate 
Operating system version: 6.1.7601
User directory: C:\Users\user
User id: S-1-5-21-804019658-624049337-3525438850-1000
User name: user
User space bitness: 32
Number of processors: 2
  Name: AMD A4-3400 APU with Radeon(tm) HD Graphics
  Socket: 0
  Vendor: AuthenticAMD
  Name: AMD A4-3400 APU with Radeon(tm) HD Graphics
  Socket: 0
  Vendor: AuthenticAMD
```
