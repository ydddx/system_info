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

String _execAndTrim(String executable, List<String> arguments, {bool runInShell: false}) {
  var string = _exec(executable, arguments, runInShell: runInShell);
  return _trim(string);
}

Map<String, String> _execAndTrimAsMap(String executable, List<String> arguments, String separator, {bool runInShell: false}) {
  var string = _execAndTrim(executable, arguments, runInShell: runInShell);
  return _stringToMap(string, separator);
}

Map<String, String> _linesToMap(List<String> lines, String separtor) {
  var result = <String, String>{};
  for (var line in lines) {
    var index = line.indexOf(separtor);
    if (index != -1) {
      var key = line.substring(0, index).trimRight();
      var value = line.substring(index + 1).trimLeft();
      result[key] = value;
    }
  }

  return result;
}

List<Map<String, String>> _linesToGroups(List<String> lines, String separtor) {
  var result = <Map<String, String>>[];
  var map = <String, String>{};
  result.add(map);
  for (var line in lines) {
    var index = line.indexOf(separtor);
    if (index != -1) {
      var key = line.substring(0, index).trimRight();
      var value = line.substring(index + 1).trimLeft();
      if (map.containsKey(key)) {
        map = <String, String>{};
        result.add(map);
      }

      map[key] = value;
    }
  }

  return result;
}

List<String> _stringToLines(String string, [bool noEmpty = false]) {
  if (string == null || string.isEmpty) {
    if (noEmpty) {
      return <String>[""];
    } else {
      return <String>[];
    }
  }

  string = string.replaceAll("\r\n", "\n");
  string = string.replaceAll("\r", "\n");
  var lines = string.split("\n");
  if (lines.isEmpty && noEmpty) {
    return <String>[""];
  } else {
    return lines;
  }
}

Map<String, String> _stringToMap(String string, String separtor) {
  var lines = _stringToLines(string);
  return _linesToMap(lines, separtor);
}

String _trim(String string) {
  if (string == null) {
    return "";
  }

  return string.trim();
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
  var lines = _stringToLines(string);
  return _linesToGroups(lines, "=");
}

Map<String, String> _wmicGetValueAsMap(String section, List<String> fields, {List<String> where}) {
  var string = _wmicGetValue(section, fields, where: where);
  var lines = _stringToLines(string);
  return _linesToMap(lines, "=");
}
