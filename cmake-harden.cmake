include_guard()

# https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html

macro(harden_posix)
  target_compile_options(
    ${target}
    PRIVATE
      -Wall
      -Wformat
      -Wformat=2
      -Wconversion
      -Wimplicit-fallthrough
      -Werror=format-security
      -Werror=implicit
      -Werror=incompatible-pointer-types
      -Werror=int-conversion
      -fno-delete-null-pointer-checks
      -fno-strict-overflow
      -fno-strict-aliasing
      -ftrivial-auto-var-init=zero
  )

  if(RUNTIME)
    target_compile_options(
      ${target}
      PRIVATE
        -fstrict-flex-arrays=3
        -fstack-clash-protection
        -fstack-protector-strong
    )
  endif()

  if(LINUX OR ANDROID)
    target_compile_options(
      ${target}
      PRIVATE
        -Wl,-z,noexecstack
        -Wl,-z,relro
        -Wl,-z,now
    )
  endif()
endmacro()

macro(harden_clang)
  harden_posix()
endmacro()

macro(harden_gcc)
  harden_posix()

  target_compile_options(
    ${target}
    PRIVATE
      -Wtrampolines
  )
endmacro()

macro(harden_msvc)
  message(WARNING "Compiler hardening is not yet supported for MSVC")
endmacro()

function(harden target)
  set(option_keywords
    RUNTIME
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  set(RUNTIME ${ARGV_RUNTIME})

  if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    harden_clang()
  elseif(CMAKE_C_COMPILER_ID MATCHES "GCC")
    harden_gcc()
  elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
    harden_msvc()
  endif()
endfunction()
