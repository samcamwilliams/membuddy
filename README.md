# MemBuddy: A simple memory profiler for AOS.

A pure Lua module for measuring memory usage of variables and data structures
in an AOS Lua environment. This profiler provides detailed memory usage information,
including nested tables and detection of circular references.

## Features

- Measure memory usage of individual variables or the entire global environment
- Support for profiling to a specified depth, returning the total size of the
  table and the size of each nested table.
- Detection and reporting of circular references with size information.
- Pretty-printed, colorized output with size formatting.
- Filtering options to focus on the largest memory consumers.
- Pure Lua implementation with no external dependencies.
- Minimal (but non-zero!) memory overhead during profiling.

Due to the lightweight nature of this tool, it provides a good approximation
of memory usage, but is not a precise measurement. Additionally, it needs to
duplicate (and then immediately `free') each element of the live environment in 
to calculate their memory usage. This memory overhead should, however, be capped
at the size of the largest element in the environment. After each object has its
size measured, it is immediately freed.

`Membuddy` does not cause any overhead during the normal course of operation of the
process it is profiling. Further, it is also not necessary to have `membuddy`
installed at the time of allocating the memory that it profiles: It can be added
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

There are two main ways to use `membuddy`:
1. Profile and print results to the console.
2. Profile and process the results programmatically yourself.

Both methods accept the same options, which are as follows:

- `target`: The table to profile (default: `_G`).
- `max_depth`: Maximum depth to traverse (default: 3). Can be a number,
  `math.huge`, "infinity", or "inf" to traverse all depths.
- `min_size`: Minimum size in bytes to include (default: 1).
- `top`: Maximum number of results to show (default: 20, use `false` for all).
- `cycles`: Whether to detect circular references (default: true).

In order to profile and print results to the console, you can use the following:
```lua
-- Profile and directly print results with the default options.
membuddy.print()

-- Profile and print results with custom options.
membuddy.print({
    target = table_to_profile,  -- Table to profile (default: _G)
    max_depth = 5,              -- Maximum depth to traverse (default: 3)
    min_size = 10,              -- Minimum byte size of objects to display (default: 1)
    top = 10,                   -- Show only the top N results (default: 20).
                                -- Can also be set to `false` to show all results.
    cycles = true               -- Show circular reference findings (default: true)
})
```

If you would like to use the results from `membuddy` programmatically, you can
do the following:
```lua
-- Profile and return results. The options are the same as when printing results.
local results = membuddy.profile({
    target = table_to_profile,
    max_depth = 5,
})
-- Returns:
-- {
--     type = "membuddy-results",
--     totalSize = 1000.0,
--     sizes = {
--         ["path/to/object"] = 100,
--     },
--     totalSizes = {
--         ["path/to/object"] = 100,
--     },
--     cycles = {
--         ["path/to/object"] = "path/to/cycle",
--     },
-- }

-- Print results from previous profiling runs:
membuddy.print(results)
```

## Example Output

When calling `membuddy.print()`, you will see a report of the following form:
```lua
   ===================== MEMBUDDY =====================

Analyzed a total of 206 references.
Total memory utilized: 22.78 KB.

Memory usage by reference name:
    package → 16.66 KB
    package/loaded → 16.24 KB
    Inbox → 4.49 KB
    Inbox/1 → 4.43 KB
    Inbox/1/TagArray/... → 3.27 KB
    package/loaded/.crypto.init/... → 3.11 KB
    package/loaded/.handlers/... → 2.67 KB
    package/loaded/.crypto.cipher.init/... → 2.62 KB
    package/loaded/.crypto.util.init/... → 2.62 KB
    package/loaded/.ao/... → 2.61 KB
    A → 490 bytes
    Inbox/1/Tags/... → 328 bytes
    A/D → 322 bytes
    package/path → 175 bytes
    package/loaded/io/... → 155 bytes
    A/D/B → 154 bytes
    t → 112 bytes
    package/cpath → 93 bytes
    Inbox/1/Module → 68 bytes
    Inbox/1/Authority → 68 bytes
...and 81 other references, totalling 4.49 KB.

Found circular references (potentially retaining data unnecessarily):
    _G: self-reference (22.83 KB)
    package/loaded/_G: self-reference (22.83 KB)
    package/loaded/package → package (16.66 KB)
    A/oh-dear → A (490 bytes)
    t/self → t (112 bytes)

81 results were filtered. Use top = number|false to show more results.
```

## Additional Printing Options

If you would like to disable printing the header on the report summary, you can
do so by setting the `no_header` option to `true`:
```lua
membuddy.print({no_header = true})
```

If you would like to disable the circular reference detection, you can do so by
setting the `cycles` option to `false`:
```lua
membuddy.print({cycles = false})
```

MemBuddy uses the AOS `Colors` table for output formatting:

- Red: Used for large values (KB, MB, GB)
- Green: Used for small values (bytes) and ellipsis
- Blue: Used for path names
- Gray: Used for labels and descriptions

If you would like to use your own color scheme or disable colors, you can do so
by setting the `Colors` table in your environment.

## License

This code is released under the MIT License.