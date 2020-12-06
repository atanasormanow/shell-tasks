# ShellTasksServer

A simple HTTP service, that takes a collection of tasks and sorts them acording
to their dependencies.

- Run with `mix run --no-halt`
- Listens on port `4000`
---
- You can find an example input at `static/example.json`
- Example call: `curl -d @example.json http://localhost:4000/shell-script`
- Example output:
```
#!/usr/bin/env bash
touch /tmp/file1
echo 'Hello World!' > /tmp/file1
cat /tmp/file1
rm /tmp/file1
```
---
- Request on `/` for a list of the sorted tasks as json objects.
- Request on `/shell-script` for a shell script representation of the tasks
with their respective commands
