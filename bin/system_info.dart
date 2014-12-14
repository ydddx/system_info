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
