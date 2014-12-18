part of system_info;

class ProcessorArchitecture {
  static const ProcessorArchitecture ARM = const ProcessorArchitecture("ARM");

  static const ProcessorArchitecture ARM64 = const ProcessorArchitecture("ARM64");

  static const ProcessorArchitecture IA64 = const ProcessorArchitecture("IA64");

  static const ProcessorArchitecture MIPS = const ProcessorArchitecture("MIPS");

  static const ProcessorArchitecture X86 = const ProcessorArchitecture("X86");

  static const ProcessorArchitecture X86_64 = const ProcessorArchitecture("X86_64");

  static const ProcessorArchitecture UNKNOWN = const ProcessorArchitecture("UNKNOWN");

  final String name;

  const ProcessorArchitecture(this.name);

  String toString() => name;
}

class ProcessorInfo {
  final ProcessorArchitecture architecture;

  final String name;

  final int socket;

  final String vendor;

  ProcessorInfo({this.architecture: ProcessorArchitecture.UNKNOWN, this.name: "", this.socket: 0, this.vendor: ""});
}

abstract class SysInfo {
  SysInfo._internal();

  /**
   * Returns the architecture of the kernel.
   *
   *     print(SysInfo.kernelArchitecture);
   *     => i686
   */
  static final String kernelArchitecture = _getKernelArchitecture();

  /**
   * Returns the bintness of kernel.
   *
   *     print(SysInfo.kernelBitness);
   *     => 32
   */
  static final int kernelBitness = _getKernelBitness();

  /**
   * Returns the name of kernel.
   *
   *     print(SysInfo.kernelName);
   *     => Linux
   */
  static final String kernelName = _getKernelName();

  /**
   * Returns the version of kernel.
   *
   *     print(SysInfo.kernelVersion);
   *     => 32
   */
  static final String kernelVersion = _getKernelVersion();

  /**
   * Returns the name of operating system.
   *
   *     print(SysInfo.operatingSystemName);
   *     => Ubuntu
   */
  static final String operatingSystemName = _getOperatingSystemName();

  /**
   * Returns the version of operating system.
   *
   *     print(SysInfo.operatingSystemVersion);
   *     => 14.04
   */
  static final String operatingSystemVersion = _getOperatingSystemVersion();

  /**
   * Returns the information about the processors.
   *
   *     print(SysInfo.processors.first.vendor);
   *     => GenuineIntel
   */
  static final List<ProcessorInfo> processors = _getProcessors();

  /**
   * Returns the path of user home directory.
   *
   *     print(SysInfo.userDirectory);
   *     => /home/andrew
   */
  static final String userDirectory = _getUserDirectory();

  /**
   * Returns the identifier of current user.
   *
   *     print(SysInfo.userId);
   *     => 1000
   */
  static final String userId = _getUserId();

  /**
   * Returns the name of current user.
   *
   *     print(SysInfo.userName);
   *     => "Andrew"
   */
  static final String userName = _getUserName();

  /**
   * Returns the bitness of the user space.
   *
   *     print(SysInfo.userSpaceBitness);
   *     => 32
   */
  static final int userSpaceBitness = _getUserSpaceBitness();

  /**
   * Returns the amount of free physical memory in bytes.
   *
   *     print(SysInfo.getFreePhysicalMemory());
   *     => 3755331584
   */
  static int getFreePhysicalMemory() => _getFreePhysicalMemory();

  /**
   * Returns the amount of free virtual memory in bytes.
   *
   *     print(SysInfo.getFreeVirtualMemory());
   *     => 3755331584
   */
  static int getFreeVirtualMemory() => _getFreeVirtualMemory();

  /**
   * Returns the amount of total physical memory in bytes.
   *
   *     print(SysInfo.getTotalPhysicalMemory());
   *     => 3755331584
   */
  static int getTotalPhysicalMemory() => _getTotalPhysicalMemory();

  /**
   * Returns the amount of total virtual memory in bytes.
   *
   *     print(SysInfo.getTotalVirtualMemory());
   *     => 3755331584
   */
  static int getTotalVirtualMemory() => _getTotalVirtualMemory();

  static final Map<String, String> _environment = Platform.environment;

  static final String _operatingSystem = Platform.operatingSystem;

  static dynamic _error() {
    throw new UnsupportedError("Unsupported operating system.");
  }

  static int _getFreePhysicalMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("cat", ["/proc/meminfo"])).trim().stringToMap(":").mapValue;
        var value = _fluent(data["MemFree"]).split(" ").elementAt(0).parseInt().intValue;
        return value * 1024;
      case "macos":
        // TODO:
        return 0;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["FreePhysicalMemory"]);
        var value = _fluent(data["FreePhysicalMemory"]).parseInt().intValue;
        return value * 1024;
      default:
        _error();
    }

    return null;
  }

  static int _getFreeVirtualMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("cat", ["/proc/meminfo"])).trim().stringToMap(":").mapValue;
        var physical = _fluent(data["MemFree"]).split(" ").elementAt(0).parseInt().intValue;
        var swap = _fluent(data["SwapFree"]).split(" ").elementAt(0).parseInt().intValue;
        return (physical + swap) * 1024;
      case "macos":
        var data = _fluent(_exec("vm_stat", [])).trim().stringToMap(":").mapValue;
        var free = _fluent(data["Pages free"]).replaceAll(".", "").parseInt().intValue;
        var pageSize = _fluent(_exec("sysctl", ["-n", "hw.pagesize"])).trim().parseInt().intValue;
        return free * pageSize;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["FreeVirtualMemory"]);
        var free = _fluent(data["FreeVirtualMemory"]).parseInt().intValue;
        return free * 1024;
      default:
        _error();
    }

    return null;
  }

  static String _getKernelArchitecture() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("uname", ["-m"])).trim().stringValue;
      case "windows":
        var architecture = _environment["PROCESSOR_ARCHITECTURE"];
        var wow64 = _environment["PROCESSOR_ARCHITEW6432"];
        var result = "x86";
        if (architecture == "AMD64" || wow64 == "AMD64") {
          result = "AMD64";
        }

        return result;
      default:
        _error();
    }

    return null;
  }

  static int _getKernelBitness() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        if (userSpaceBitness == 64) {
          return 64;
        }

        var paths = <String>[];
        var path = _resolveLink("/etc/ld.so.conf");
        if (path != null) {
          _parseLdConf(path, paths, new Set<String>());
        }

        paths.add("/lib");
        paths.add("/lib64");
        for (var path in paths) {
          var files = FileUtils.glob(pathos.join(path, "libc.so.*"));
          for (var filePath in files) {
            filePath = _resolveLink(filePath);
            if (filePath == null) {
              continue;
            }

            var file = new File(filePath);
            if (file.existsSync()) {
              var fileType = _fluent(_exec("file", ["-b", file.path])).trim().stringValue;
              if (fileType.startsWith("ELF 64-bit")) {
                return 64;
              }
            }
          }
        }

        return 32;
      case "macos":
        var result = 32;
        if (_fluent(_exec("uname", ["-m"])).trim() == "x86_64") {
          result = 64;
        }

        return result;
      case "windows":
        var result = 32;
        var architecture = _environment["PROCESSOR_ARCHITECTURE"];
        var wow64 = _environment["PROCESSOR_ARCHITEW6432"];
        if (architecture == "AMD64" || wow64 == "AMD64") {
          result = 64;
        }

        return result;
      default:
        _error();
    }

    return null;
  }

  static String _getKernelName() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("uname", ["-s"])).trim().stringValue;
      case "windows":
        return _environment["OS"];
      default:
        _error();
    }

    return null;
  }

  static String _getKernelVersion() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("uname", ["-r"])).trim().stringValue;
      case "windows":
        return operatingSystemVersion;
      default:
        _error();
    }

    return null;
  }

  static String _getOperatingSystemName() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("lsb_release", ["-a"])).trim().stringToMap(":").mapValue;
        return _fluent(data["Distributor ID"]).stringValue;
      case "macos":
        var data = _fluent(_exec("sw_vers", [])).trim().stringToMap(":").mapValue;
        return _fluent(data["ProductName"]).stringValue;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["Caption"]);
        return _fluent(data["Caption"]).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getOperatingSystemVersion() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("lsb_release", ["-a"])).trim().stringToMap(":").mapValue;
        return _fluent(data["Release"]).stringValue;
      case "macos":
        var data = _fluent(_exec("sw_vers", [])).trim().stringToMap(":").mapValue;
        return _fluent(data["ProductVersion"]).stringValue;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["Version"]);
        return _fluent(data["Version"]).stringValue;
      default:
        _error();
    }

    return null;
  }

  static List<ProcessorInfo> _getProcessors() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var processors = <ProcessorInfo>[];
        var groups = _fluent(_exec("cat", ["/proc/cpuinfo"])).trim().stringToList().listToGroups(":").groupsValue;
        for (var group in groups) {
          var socket = _fluent(group["physical id"]).parseInt().intValue;
          var vendor = _fluent(group["vendor_id"]).stringValue;
          var modelFields = const <String>["model name", "cpu model"];
          var name = "";
          for (var field in modelFields) {
            name = _fluent(group[field]).stringValue;
            if (!name.isEmpty) {
              break;
            }
          }

          var architecture = ProcessorArchitecture.UNKNOWN;
          if (name.startsWith("AMD")) {
            architecture = ProcessorArchitecture.X86;
            var flags = _fluent(group["flags"]).split(" ").listValue;
            if (flags.contains("lm")) {
              architecture = ProcessorArchitecture.X86_64;
            }

          } else if (name.startsWith("Intel")) {
            architecture = ProcessorArchitecture.X86;
            var flags = _fluent(group["flags"]).split(" ").listValue;
            if (flags.contains("lm")) {
              architecture = ProcessorArchitecture.X86_64;
            }

            if (flags.contains("ia64")) {
              architecture = ProcessorArchitecture.IA64;
            }

          } else if (name.startsWith("ARM")) {
            architecture = ProcessorArchitecture.ARM;
            var features = _fluent(group["Features"]).split(" ").listValue;
            if (features.contains("fp")) {
              architecture = ProcessorArchitecture.ARM64;
            }

          } else if (name.startsWith("MIPS")) {
            architecture = ProcessorArchitecture.MIPS;
          }

          var processor = new ProcessorInfo(architecture: architecture, name: name, socket: socket, vendor: vendor);
          processors.add(processor);
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      case "macos":
        var data = _fluent(_exec("sysctl", ["machdep.cpu"])).trim().stringToMap(":").mapValue;
        var architecture = ProcessorArchitecture.UNKNOWN;
        if (data["machdep.cpu.vendor"] == "GenuineIntel") {
          architecture = ProcessorArchitecture.X86;
          var extfeatures = _fluent(data["machdep.cpu.extfeatures"]).split(" ").listValue;
          if (extfeatures.contains("EM64T")) {
            architecture = ProcessorArchitecture.X86_64;
          }
        }

        var numberOfCores = _fluent(data["machdep.cpu.core_count"]).parseInt().intValue;
        var processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfCores; i++) {
          var name = _fluent(data["machdep.cpu.brand_string"]).stringValue;
          var vendor = _fluent(data["machdep.cpu.vendor"]).stringValue;
          var processor = new ProcessorInfo(architecture: architecture, name: name, socket: 0, vendor: vendor);
          processors.add(processor);
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      case "windows":
        var groups = _wmicGetValueAsGroups("CPU", ["Architecture", "DataWidth", "Manufacturer", "Name", "NumberOfCores"]);
        var numberOfSockets = groups.length;
        var processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfSockets; i++) {
          var data = groups[i];
          var numberOfCores = _fluent(data["NumberOfCores"]).parseInt().intValue;
          var architecture = ProcessorArchitecture.UNKNOWN;
          switch (_fluent(data["Architecture"]).parseInt().intValue) {
            case 0:
              architecture = ProcessorArchitecture.X86;
              break;
            case 1:
              architecture = ProcessorArchitecture.MIPS;
              break;
            case 5:
              switch (_fluent(data["DataWidth"]).parseInt().intValue) {
                case 32:
                  architecture = ProcessorArchitecture.ARM;
                  break;
                case 64:
                  architecture = ProcessorArchitecture.ARM64;
                  break;
              }

              break;
            case 9:
              architecture = ProcessorArchitecture.X86_64;
              break;
          }

          for (var socket = 0; socket < numberOfCores; socket++) {
            var name = _fluent(data["Name"]).stringValue;
            var vendor = _fluent(data["Manufacturer"]).stringValue;
            var processor = new ProcessorInfo(architecture: architecture, name: name, socket: socket, vendor: vendor);
            processors.add(processor);
          }
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      default:
        _error();
    }

    return null;
  }

  static int _getTotalPhysicalMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("cat", ["/proc/meminfo"])).trim().stringToMap(":").mapValue;
        var value = _fluent(data["MemTotal"]).split(" ").elementAt(0).parseInt().intValue;
        return value * 1024;
      case "macos":
        var pageSize = _fluent(_exec("sysctl", ["-n", "hw.pagesize"])).trim().parseInt().intValue;
        var size = _fluent(_exec("sysctl", ["-n", "hw.memsize"])).trim().parseInt().intValue;
        return size * pageSize;
      case "windows":
        var data = _wmicGetValueAsMap("ComputerSystem", ["TotalPhysicalMemory"]);
        var value = _fluent(data["TotalPhysicalMemory"]).parseInt().intValue;
        return value;
      default:
        _error();
    }

    return null;
  }

  static int _getTotalVirtualMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _fluent(_exec("cat", ["/proc/meminfo"])).trim().stringToMap(":").mapValue;
        _fluent(data["MemTotal"]).split(" ").elementAt(0).parseInt().intValue;
        var physical = _fluent(data["MemTotal"]).split(" ").elementAt(0).parseInt().intValue;
        var swap = _fluent(data["SwapTotal"]).split(" ").elementAt(0).parseInt().intValue;
        return (physical + swap) * 1024;
      case "macos":
        // TODO:
        return 0;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["TotalVirtualMemorySize"]);
        var value = _fluent(data["TotalVirtualMemorySize"]).parseInt().intValue;
        return value * 1024;
      default:
        _error();
    }

    return null;
  }

  static String _getUserDirectory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _environment["HOME"];
      case "windows":
        return _environment["USERPROFILE"];
      default:
        _error();
    }

    return null;
  }

  static String _getUserId() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("id", ["-u"])).trim().stringValue;
      case "windows":
        var data = _wmicGetValueAsMap("UserAccount", ["SID"], where: ["Name=\"$userName\""]);
        return _fluent(data["SID"]).stringValue;
      default:
        _error();
    }

    return null;
  }

  static String _getUserName() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("whoami", [])).trim().stringValue;
      case "windows":
        return _environment["USERNAME"];
      default:
        _error();
    }

    return null;
  }

  static int _getUserSpaceBitness() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _fluent(_exec("getconf", ["LONG_BIT"])).trim().parseInt().intValue;
      case "windows":
        var result = 32;
        if (_environment["PROCESSOR_ARCHITECTURE"] == "AMD64") {
          result = 64;
        }

        return result;
      default:
        _error();
    }

    return null;
  }
}
