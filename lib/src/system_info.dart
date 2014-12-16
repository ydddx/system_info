part of system_info;

class ProcessorInfo {
  final String name;

  final int socket;

  final String vendor;

  ProcessorInfo({this.name: "", this.socket: 0, this.vendor: ""});
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
        var data = _execAndTrimAsMap("cat", ["/proc/meminfo"], ":");
        return int.parse(_trim(data["MemFree"]).split(" ").first, onError: (e) => 0) * 1024;
      case "macos":
        // TODO:
        return 0;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["FreePhysicalMemory"]);
        return int.parse(data["FreePhysicalMemory"], onError: (e) => 0) * 1024;
      default:
        _error();
    }

    return null;
  }

  static int _getFreeVirtualMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _execAndTrimAsMap("cat", ["/proc/meminfo"], ":");
        var physical = int.parse(_trim(data["MemFree"]).split(" ").first, onError: (e) => 0);
        var swap = int.parse(_trim(data["SwapFree"]).split(" ").first, onError: (e) => 0);
        return (physical + swap) * 1024;
      case "macos":
        var data = _execAndTrimAsMap("vm_stat", [], ":");
        var free = int.parse(_trim(data["Pages free"]).replaceAll(".", "").split(" ").first, onError: (e) => 0);
        var pageSize = int.parse(_execAndTrim("sysctl", ["-n", "hw.pagesize"]), onError: (e) => 0);
        return free * pageSize;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["FreeVirtualMemory"]);
        return int.parse(data["FreeVirtualMemory"], onError: (e) => 0) * 1024;
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
        return _execAndTrim("uname", ["-m"]);
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
        var kernel = _execAndTrim("uname", ["-r"]);
        var file = new File("/boot/config-$kernel");
        if (!file.existsSync()) {
          _error();
        }

        var lines = <String>[];
        for (var line in file.readAsLinesSync()) {
          var index = line.indexOf("#");
          if (index != -1) {
            line = line.substring(0, index);
            lines.add(line);
          }
        }

        var data = _linesToMap(lines, "=");
        var result = userSpaceBitness;
        if (data["CONFIG_64BIT"].toString().toLowerCase() == "y") {
          result = 64;
        }

        return result;
      case "macos":
        var result = 32;
        if (_execAndTrim("uname", ["-m"]) == "x86_64") {
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
        return _execAndTrim("uname", ["-s"]);
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
        return _execAndTrim("uname", ["-r"]);
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
        var data = _execAndTrimAsMap("lsb_release", ["-a"], ":");
        return data["Distributor ID"];
      case "macos":
        var data = _execAndTrimAsMap("sw_vers", [""], ":");
        return data["ProductName"];
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["Caption"]);
        return data["Caption"];
      default:
        _error();
    }

    return null;
  }

  static String _getOperatingSystemVersion() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _execAndTrimAsMap("lsb_release", ["-a"], ":");
        return data["Release"];
      case "macos":
        var data = _execAndTrimAsMap("sw_vers", [""], ":");
        return data["ProductVersion"];
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["Version"]);
        return data["Version"];
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
        var groups = _execAndTrimAsGroups("cat", ["/proc/cpuinfo"], ":");
        for (var group in groups) {
          var name = _trim(group["model name"]);
          var socket = int.parse(_trim(group["physical id"]), onError: (e) => 0);
          var vendor = _trim(group["vendor_id"]);
          var processor = new ProcessorInfo(name: name, socket: socket, vendor: vendor);
          processors.add(processor);
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      case "macos":
        var data = _execAndTrimAsMap("sysctl", ["machdep.cpu"], ":");
        var numberOfCores = int.parse(data["machdep.cpu.core_count"], onError: (e) => 0);
        var processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfCores; i++) {
          var name = data["machdep.cpu.brand_string"];
          var vendor = data["machdep.cpu.vendor"];
          var processor = new ProcessorInfo(name: name, socket: 0, vendor: vendor);
          processors.add(processor);
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      case "windows":
        var groups = _wmicGetValueAsGroups("CPU", ["Architecture", "Manufacturer", "Name", "NumberOfCores"]);
        var numberOfSockets = groups.length;
        var processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfSockets; i++) {
          var data = groups[i];
          var numberOfCores = int.parse(data["NumberOfCores"], onError: (e) => 0);
          for (var socket = 0; socket < numberOfCores; socket++) {
            var name = data["Name"];
            var vendor = data["Manufacturer"];
            var processor = new ProcessorInfo(name: name, socket: socket, vendor: vendor);
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
        var data = _execAndTrimAsMap("cat", ["/proc/meminfo"], ":");
        return int.parse(_trim(data["MemTotal"]).split(" ").first, onError: (e) => 0) * 1024;
      case "macos":
        var pageSize = int.parse(_execAndTrim("sysctl", ["-n", "hw.pagesize"]), onError: (e) => 0);
        var size = int.parse(_execAndTrim("sysctl", ["-n", "hw.memsize"]), onError: (e) => 0);
        return size * pageSize;
      case "windows":
        var data = _wmicGetValueAsMap("ComputerSystem", ["TotalPhysicalMemory"]);
        return int.parse(data["TotalPhysicalMemory"], onError: (e) => 0);
      default:
        _error();
    }

    return null;
  }

  static int _getTotalVirtualMemory() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
        var data = _execAndTrimAsMap("cat", ["/proc/meminfo"], ":");
        var physical = int.parse(_trim(data["MemTotal"]).split(" ").first, onError: (e) => 0);
        var swap = int.parse(_trim(data["SwapTotal"]).split(" ").first, onError: (e) => 0);
        return (physical + swap) * 1024;
      case "macos":
        // TODO:
        return 0;
      case "windows":
        var data = _wmicGetValueAsMap("OS", ["TotalVirtualMemorySize"]);
        return int.parse(data["TotalVirtualMemorySize"], onError: (e) => 0) * 1024;
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
        return _execAndTrim("id", ["-u"]);
      case "windows":
        var data = _wmicGetValueAsMap("UserAccount", ["SID"], where: ["Name=\"$userName\""]);
        return data["SID"];
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
        return _execAndTrim("whoami", []);
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
        return int.parse(_execAndTrim("getconf", ["LONG_BIT"]), onError: (e) => _error());
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
