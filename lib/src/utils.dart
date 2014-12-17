part of system_info;

String _exec(String executable, List<String> arguments, {bool runInShell: false}) {
  try {
    var result = Process.runSync(executable, arguments, runInShell: runInShell);
    if (result.exitCode == 0) {
      return result.stdout.toString();
    }

  } catch (e) {
  }

  return null;
}

void _parseLdConf(String path, List<String> paths, Set<String> processed) {
  var file = new File(path);
  if (!file.existsSync()) {
    return;
  }

  for (var line in file.readAsLinesSync()) {
    line = line.trim();
    var index = line.indexOf("#");
    if (index != -1) {
      line = line.substring(0, index);
    }

    if (!line.isEmpty) {
      if (line.startsWith("include ")) {
        var s = FileUtils.glob(line.substring(8));
        for (var path in FileUtils.glob(line.substring(8))) {
          if (!processed.contains(path)) {
            processed.add(path);
            _parseLdConf(path, paths, processed);
          }

        }

      } else {
        paths.add(line);
      }
    }
  }
}

String _wmicGetValue(String section, List<String> fields, {List<String> where}) {
  var arguments = <String>[section];
  if (where != null) {
    arguments.add("where");
    arguments.addAll(where);
  }

  arguments.add("get");
  arguments.addAll(fields.join(", ").split(" "));
  arguments.add("/VALUE");
  return _exec("wmic", arguments);
}

List<Map<String, String>> _wmicGetValueAsGroups(String section, List<String> fields, {List<String> where}) {
  var string = _wmicGetValue(section, fields, where: where);
  return _fluent(string).stringToList().listToGroups("=").groupsValue;
}

Map<String, String> _wmicGetValueAsMap(String section, List<String> fields, {List<String> where}) {
  var string = _wmicGetValue(section, fields, where: where);
  return _fluent(string).stringToList().listToMap("=").mapValue;
}
