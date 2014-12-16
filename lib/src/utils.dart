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

List<Map<String, String>> _execAndTrimAsGroups(String executable, List<String> arguments, String separator, {bool runInShell: false}) {
  var string = _execAndTrim(executable, arguments, runInShell: runInShell);
  var lines = _stringToLines(string);
  return _linesToGroups(lines, separator);
}

Map<String, String> _execAndTrimAsMap(String executable, List<String> arguments, String separator, {bool runInShell: false}) {
  var string = _execAndTrim(executable, arguments, runInShell: runInShell);
  return _stringToMap(string, separator);
}

String _getByIndex(List<String> list, int index, [String defaultValue]) {
  if (list == null) {
    return defaultValue;
  }

  if (index >= list.length) {
    return defaultValue;
  }

  return list[index];
}

int _getByIndexAsInt(List<String> list, int index, [int defaultValue]) {
  if (list == null) {
    return defaultValue;
  }

  if (index >= list.length) {
    return defaultValue;
  }

  var value = list[index];
  if (value == null) {
    return defaultValue;
  }

  return int.parse(value, onError: (e) => defaultValue);
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

Map<String, List<String>> _linesToTable(List<String> lines, List<String> parseColumns(String line), List<String> parseRow(String line)) {
  var result = <String, List<String>>{};
  List<String> columns;
  var length = lines.length;
  if (length > 0) {
    columns = parseColumns(lines[0]);
    for (var name in columns) {
      result[name] = new List<String>(columns.length);
    }
  }

  for (var i = 1; i < length; i++) {
    var row = new List<String>(columns.length);
    var cells = parseColumns(lines[i]);
    for (var j = 0; j < columns.length && j < cells.length; j++) {
      row = cells[i];
    }
  }

  return result;
}

String _reduceSpaces(String string) {
  string = _trim(string);
  var sb = new StringBuffer();
  var length = string.length;
  var skip = false;
  for (var i = 0; i < length; i++) {
    var current = string[i];
    switch (current) {
      case " ":
      case "\t":
        if (!skip) {
          sb.write(" ");
          skip = true;
        }

        break;
      default:
        sb.write(current);
        skip = false;
        break;
    }
  }

  return sb.toString();
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
