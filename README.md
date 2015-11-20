# lita-cmd

Run scripts from your lita machine and get back the output!

## Installation

Add lita-cmd to your Lita instance's Gemfile:

``` ruby
gem "lita-cmd"
```

## Configuration

```ruby
Lita.configure do |config|
  # Lita CMD stuff
  config.handlers.cmd.scripts_dir = "/path/to/dir/you/expose"
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

- The user who executed the command will be pass in an environment variable called LITA_USER
- Make sure that your files are executable
  - (`chmod +x FILE`)
- Make sure that you've included the correct sha-bang
  - `#!/bin/bash`, `#!/usr/bin/env ruby`, etc...

## Roadmap

- [x] Include support for directory-based access control
- [ ] Help text for individual commands
