![](https://github.com/senselogic/FRAG/blob/master/LOGO/frag.png)

# Frag

Script fragmenter.

## Installation

Install the [DMD 2 compiler](https://dlang.org/download.html) (using the MinGW setup option on Windows).

Build the executable with the following command line :

```bash
dmd -m64 frag.d
```

## Command line

```bash
frag [options]
```

### Options

```
--semicolon
--split <maximum size> : split files
--join : join files
```

### Size suffixes

```
b : byte
k : kilobyte
m : megabyte
g : gigabyte
```

### Examples

```bash
frag --semicolon --split 800k script.sql
```

Splits the file.

```bash
frag --join script.1.sql script.2.sql script.3.sql script.sql
```

Joins those files.

## Limitations

*   Files are split and joined in memory.

## Version

0.1

## Author

Eric Pelzer (ecstatic.coder@gmail.com).

## License

This project is licensed under the GNU General Public License version 3.

See the [LICENSE.md](LICENSE.md) file for details.
