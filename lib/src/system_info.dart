part of system_info;

class ProcessorInfo {
  final String name;

  final int socket;

  final String vendor;

  ProcessorInfo({this.name: "", this.socket: 0, this.vendor: ""});
}

abstract class SysInfo {
  SysInfo._internal();

  static final String _hostname = _getHostname();

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

  static final Map<String, String> _environment = Platform.environment;

  static final String _operatingSystem = Platform.operatingSystem;

  static dynamic _error() {
    throw new UnsupportedError("Unsupported operating system.");
  }

  static String _getHostname() {
    switch (_operatingSystem) {
      case "android":
      case "linux":
      case "macos":
        return _execAndTrim("hostname", []);
      case "windows":
        var group = _wmicGetValueAsGroups("ComputerSystem", ["Name"]).first;
        return group["Name"];
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
        var file = new File("/proc/cpuinfo");
        if (file.existsSync()) {
          var groups = _linesToGroups(file.readAsLinesSync(), ":");
          for (var group in groups) {
            var name = _trim(group["model name"]);
            var socket = int.parse(_trim(group["physical id"]), onError: (e) => 0);
            var vendor = _trim(group["vendor_id"]);
            var processor = new ProcessorInfo(name: name, socket: socket, vendor: vendor);
            processors.add(processor);
          }
        }

        assert(processors.length != 0);
        return new UnmodifiableListView(processors);
      case "macos":
        var data = _execAndTrimAsMap("sysctl", ["-a", "machdep.cpu"], ":");
        var numberOfCores = int.parse(data["core_count"], onError: (e) => 0);
        var processors = <ProcessorInfo>[];
        for (var i = 0; i < numberOfCores; i++) {
          var name = data["brand_string"];
          var vendor = data["vendor"];
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
