# Warnings Plugin;
# You can use the following regex and groovy for the warnings plugin.
# This regular expresion catch the rspec test errors (A test error should
# make your jenkins job fails) so you should enable the "Run always" 
# setting in the "Scan for compiler warnings" of your job.

__Regular Expression:__

```
^\s*rspec\s*(.*):(\d+)\s*#\s*(.*)$
```

__Mapping Script:__

```groovy
import hudson.plugins.warnings.parser.Warning
import hudson.plugins.analysis.util.model.Priority

String fileName = matcher.group(1)
String category = "ERROR"
String lineNumber = matcher.group(2)
String message = matcher.group(3)
Priority prio = Priority.HIGH

return new Warning(fileName, Integer.parseInt(lineNumber), "Rspec parser", category, message, prio);
```
