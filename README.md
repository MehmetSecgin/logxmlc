# logxmlc

`logxmlc` extracts XML from noisy logs and pretty-prints it.

It is a single-file Python CLI with no third-party dependencies. Feed it a log line, a JSON log blob, stdin, or your clipboard, and it will pull out the XML payload for inspection.

## Why it exists

Application logs often wrap XML in timestamps, metadata, escaped JSON, or plain text noise. `logxmlc` is a quick way to recover the XML document without manually trimming the log first.

## Features

- Extracts the first XML document from mixed log text by default
- Can extract every XML document in the input with `--all`
- Pretty-prints XML for easier reading
- Can output raw XML with `--raw`
- Can read from and copy back to the clipboard
- Works with plain text logs and JSON logs that contain a `message` field

## Install

After publishing this repo to GitHub, replace `YOUR_GITHUB_USERNAME` below with your account name. If you use a different repo name, replace `logxmlc` too.

One-line install:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/logxmlc/main/install.sh | LOGXMLC_GITHUB_REPO=YOUR_GITHUB_USERNAME/logxmlc bash
```

Install after cloning:

```bash
chmod +x logxmlc install.sh
./install.sh
```

By default the installer places `logxmlc` and a `logxml` alias in `~/.local/bin`.

## Requirements

- `python3`

Optional clipboard support:

- macOS: `pbpaste` and `pbcopy`
- Linux Wayland: `wl-paste` and `wl-copy`
- Linux X11: `xclip` or `xsel`

## Usage

Pipe a log into it:

```bash
printf '%s\n' 'INFO <?xml version="1.0"?><root><a>1</a></root>' | logxmlc
```

Pass a log line directly:

```bash
logxmlc 'INFO <?xml version="1.0"?><root><a>1</a></root>'
```

Read from the clipboard:

```bash
logxmlc --clipboard
```

Read from the clipboard and copy the formatted result back:

```bash
logxmlc --clipboard --copy
```

Extract every XML document in a file:

```bash
logxmlc --all < app.log
```

Show raw XML:

```bash
logxmlc --raw < app.log
```

Omit the XML declaration from formatted output:

```bash
logxmlc --no-decl < app.log
```

## Example

Input:

```text
2026-03-31 12:00:00 INFO request failed payload=<?xml version="1.0"?><root><error code="42">bad</error></root>
```

Output:

```xml
<?xml version="1.0" ?>
<root>
  <error code="42">bad</error>
</root>
```

## License

MIT
