include_guard()

include(CheckCCompilerFlag)

# https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html

macro(add_hardened_compiler_flags)
  foreach(flag ${ARGV})
    check_c_compiler_flag(${flag} supports_${flag})

    if(supports_${flag})
      target_compile_options(${target} PRIVATE ${flag})
    endif()
  endforeach()
endmacro()

macro(harden_posix)
  add_hardened_compiler_flags(
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
    -fstrict-flex-arrays=3
    -ftrivial-auto-var-init=zero
  )

  if(RUNTIME)
    add_hardened_compiler_flags(
      -fstack-clash-protection
      -fstack-protector-strong
    )
  endif()

  if(LINUX OR ANDROID)
    add_hardened_compiler_flags(
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

  add_hardened_compiler_flags(
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
