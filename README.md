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

## Notes

- Make sure that your files are executable
  - (`chmod +x FILE`)
- Make sure that you've included the correct shebang
  - `#!/bin/bash`, `#!/usr/bin/env ruby`, etc...

## Roadmap

- [ ] Include support for directory-based access control
