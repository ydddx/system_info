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
