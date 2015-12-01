# lita-cmd

Run scripts from your lita machine and get back the output!

## Installation

Add lita-cmd to your Lita instance's Gemfile:

``` ruby
gem "lita-cmd"
```

## Configuration
|Config Option|Description|Type|Notes|
|-------------|-----------|----|-----|
|`scripts_dir`|Full path to location of scripts|`String`|*required*|
|`stdout_prefix`|Prefix for text returned to STDOUT|`String`||
|`stderr_prefix`|Prefix for text returned to STDERR|`String`||
|`output_format`|Format string used to encapsulate code|`String`||

#### Example:

```ruby
Lita.configure do |config|
  # Lita CMD - required parameters
  
  config.handlers.cmd.scripts_dir = "/path/to/dir/you/expose"

  # Lita CMD - optional parameters

  # Set the output format. Default: "%s"
  # Note that %s will contain the returned text
  config.handlers.cmd.output_format = "/code %s"

  # Set the prefix of stdout and stderr.
  config.handlers.cmd.stdout_prefix = ""
  config.handlers.cmd.stderr_prefix = "ERROR: "

end
```

## Usage

- `cmd-help`
  - Query the configured directory for filenames and return them
- `cmd`
  - Execute a file in the configured directory

>- dfinninger: `lita cmd-help`
- lita:
```
devops/secret
hello
name
```
- dfinninger: `lita cmd hello`
- lita:
```
Hello!
```
- dfinninger: `lita cmd name`
- lita:
```
Your name is: ... well, idk, man...
```
- dfinninger: `lita cmd name Devon`
- lita:
```
Your name is: Devon
```

### Group Control

You can now control what groups have access to your Lita scripts!

In your `scripts` dir make some more that match the name of your groups. Only users that are a part of those groups can see/execute those scripts.

#### Example

- scripts dir:
  - Basic directory setup

```
scripts/
  |- devops/
  |   `- secret
  |- hello
  `- name
```

- `lita cmd-help`
  - Help text will show you scripts that you have access to with a prefix

```
devops/secret
hello
name
```

- `lita cmd devops/secret`
  - Execute the command. Prefix required!

```
[stdout] I'm a secret!
```

A non-priviledged user will only see scripts without the prefix.

## Notes

- Make sure that your files are executable
  - (`chmod +x FILE`)
- Make sure that you've included the correct sha-bang
  - `#!/bin/bash`, `#!/usr/bin/env ruby`, etc...

## Roadmap

- [x] Include support for directory-based access control
- [ ] Help text for individual commands
