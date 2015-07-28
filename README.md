# Description

Command-line script to update `<progress>` elements in the signature block
of compatibly-configured phpBB forum sites.

# Usage

    sig-updater --username=USERNAME --site=http://www.example.com/phpbb/ \
        --foo=3 --bar=2/10

# Script Requirements

- Ruby
- [highline](https://github.com/JEG2/highline/) gem
- [mechanize](https://github.com/sparklemotion/mechanize) gem

# phpBB Forum Configuration

## BBCode usage

    [progress={INTTEXT}]{NUMBER1}/{NUMBER2}[/progress]

## HTML replacement

```html
<span class="progress-label">{INTTEXT}:
  <progress value="{NUMBER1}" max="{NUMBER2}" title="Libros: {NUMBER1} / {NUMBER2}">
    {NUMBER1} / {NUMBER2}
  </progress>
</span>
```

# TODO

- tests
- support +N values to make incrementing easier
- support 0.N => N values
- get password from somewhere other than STDIN
