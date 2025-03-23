# MemBuddy: A simple memory profiler for AOS.

A pure Lua module for measuring memory usage of variables and data structures
in an AOS Lua environment. This profiler provides detailed memory usage information,
including nested tables and detection of circular references.

## Features

- Measure memory usage of individual variables or the entire global environment
- Support for profiling to a specified depth, returning the total size of the
  table and the size of each nested table.
- Detection and reporting of circular references.
- Pure Lua implementation with no external dependencies.
- Minimal (but non-zero!) memory overhead during profiling.

Due to the lightweight nature of this tool, it provides a good approximation
of memory usage, but is not a precise measurement. Additionally, it needs to
duplicate (and then immediately `free') elements of the live environment in order
to function leading to some memory overhead during profiling. It does not,
however, cause any overhead during the normal course of operation of the
process it is profiling. Further, it is also not necessary to have `membuddy`
installed at the time of allocating the memory to be profiled: It can be added
or removed at any time.

## Installation

Simply copy the `membuddy.lua` file to your project or Lua path.

```lua
local membuddy = require("membuddy")
```

Alternatively, you can load the module into AOS using the `apm` package manager:

```bash
aos [your-process-name]

.load-blueprint apm
APM.install("membuddy")
```

## Usage

### Basic Usage

```lua
-- Profile all global variables with a max reporting depth of 3
local results = membuddy.profile({depth = 3})

-- Print the results in a human-readable format
membuddy.print_results(results)
```

### Profile a Specific Table

```lua
-- Profile a specific table with a max depth of 2
local my_table = {a = {b = {c = {d = "deep"}}}, e = "shallow"}
my_table.f = my_table
local results = membuddy.profile(my_table, {depth = 2})
```
Results in...
```lua
results = {
    totalSize = 1234567,  -- Total memory usage in bytes
    sizes = {
        -- Paths and their respective memory usage in bytes
        ["a/b/..."] = 100,
        ["a/e"] = 400
    },
    circular = {
        -- Circular references detected during profiling
        ["my_table"] = "my_table"
    }
}
```

To print the results in a human-readable format, use:

```lua
membuddy.print(results)
```
This should yield a result of the following form:
```lua
Total size: 1234567 bytes

Sizes:
    a/b/...: 100 bytes
    a/e: 400 bytes

Circular references:
    my_table: my_table
```

## API Reference

### membuddy.profile([table,] options)

Profiles the memory usage of a table.

- `table`: The table to profile. If not provided, the entire global environment
  will be profiled.
- `options`: A table of options
  - `depth`: Maximum depth to traverse (optional)
- **Returns**: Results table with memory usage information

### membuddy.print([results])

Prints profiling results.

- `results`: The results table returned by `profile`. If not provided, a full
  profile of the global environment will be printed.
- **Prints**: The results in a human-readable format.

### membuddy.format_size(bytes)

Formats a byte count into a human-readable string.

- `bytes`: Number of bytes
- Returns: Formatted string (e.g., "1.23 MB")

## Example

See `src/example.lua` for a complete example of using the profiler.

## License

This code is released under the MIT License.