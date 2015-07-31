# Description

Command-line script to update `<progress>` elements in the signature block
of compatibly-configured phpBB forum sites.

# Usage

    update-sig --username=USERNAME --password=PASSWORD \
        --site=http://www.example.com/phpBB/ \
        --foo=3 --bar=2/10 --qux=+1 --this=/+10 --that=-2 --other=.1/10

Username and password can also be stored in a YAML config file
(`cp update-sig.yml.example update-sig.yml` and edit it)
or in the environment variables
`PHPBB_UPDATE_SIG_USERNAME` and `PHPBB_UPDATE_SIG_PASSWORD`.

Because `<progress>
Fractional

# Script Requirements

- Ruby
- gems in Gemfile

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

- test phpbb class
- test CLI
- get password from somewhere other than STDIN
