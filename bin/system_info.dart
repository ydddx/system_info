import "package:system_info/system_info.dart";

void main() {
  print("Kernel architecture: ${SysInfo.kernelArchitecture}");
  print("Kernel bitness: ${SysInfo.kernelBitness}");
  print("Kernel name: ${SysInfo.kernelName}");
  print("Kernel version: ${SysInfo.kernelVersion}");
  print("Operating system name: ${SysInfo.operatingSystemName}");
  print("Operating system version: ${SysInfo.operatingSystemVersion}");
  print("User directory: ${SysInfo.userDirectory}");
  print("User id: ${SysInfo.userId}");
  print("User name: ${SysInfo.userName}");
  print("User space bitness: ${SysInfo.userSpaceBitness}");
  var processors = SysInfo.processors;
  print("Number of processors: ${processors.length}");
  for (var processor in processors) {
    print("  Name: ${processor.name}");
    print("  Socket: ${processor.socket}");
    print("  Vendor: ${processor.vendor}");
  }
}
