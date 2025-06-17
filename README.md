# cmake-harden

Compiler options hardening for CMake based on the [OpenSSF guidelines](https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html).

```
npm i cmake-harden
```

```cmake
find_package(cmake-harden REQUIRED PATHS node_modules/cmake-harden)
```

## API

#### `harden(<target> [C|CXX] [RUNTIME])`

## License

Apache-2.0
