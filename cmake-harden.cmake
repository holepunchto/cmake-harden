include_guard()

include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)

# https://best.openssf.org/Compiler-Hardening-Guides/Compiler-Options-Hardening-Guide-for-C-and-C++.html

macro(add_hardened_compiler_flags)
  foreach(flag ${ARGV})
    if(lang MATCHES "CXX")
      check_cxx_compiler_flag(${flag} supports_${flag})
    else()
      check_c_compiler_flag(${flag} supports_${flag})
    endif()

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

  if(runtime)
    add_hardened_compiler_flags(
      -fstack-clash-protection
      -fstack-protector-strong
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
    C
    CXX
    RUNTIME
  )

  cmake_parse_arguments(
    PARSE_ARGV 1 ARGV "${option_keywords}" "" ""
  )

  set(runtime ${ARGV_RUNTIME})

  if(ARGV_CXX)
    set(lang CXX)
  else()
    set(lang C)
  endif()

  set(compiler ${CMAKE_${lang}_COMPILER_ID})

  if(compiler MATCHES "Clang")
    harden_clang()
  elseif(compiler MATCHES "GCC")
    harden_gcc()
  elseif(compiler MATCHES "MSVC")
    harden_msvc()
  endif()
endfunction()
