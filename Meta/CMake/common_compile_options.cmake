# Flags shared by Lagom (including Ladybird) and Serenity.
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_COLOR_DIAGNOSTICS ON)

add_compile_options(-Wall)
add_compile_options(-Wextra)

add_compile_options(-Wno-invalid-offsetof)

add_compile_options(-Wno-unknown-warning-option)
add_compile_options(-Wno-unused-command-line-argument)

add_compile_options(-fno-exceptions)

add_compile_options(-ffp-contract=off)

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "18")
    add_compile_options(-Wpadded-bitfield)
endif()

if (NOT CMAKE_HOST_SYSTEM_NAME MATCHES SerenityOS)
    # FIXME: Something makes this go crazy and flag unused variables that aren't flagged as such when building with the toolchain.
    #        Disable -Werror for now.
    add_compile_options(-Werror)
endif()

if (WIN32)
    # -Wall with clang-cl is equivalent to -Weverything, which is extremely noisy
    add_compile_options(-Wno-unknown-attributes) # [[no_unique_address]] is broken in MSVC ABI until next ABI break
    add_compile_options(-Wno-reinterpret-base-class)
    add_compile_options(-Wno-microsoft-unqualified-friend) # MSVC doesn't support unqualified friends
    add_compile_definitions(-D_CRT_SECURE_NO_WARNINGS) # _s replacements not desired (or implemented on any other platform other than VxWorks)
    add_compile_definitions(-D_CRT_NONSTDC_NO_WARNINGS) # POSIX names are just fine, thanks
    add_compile_definitions(-D_USE_MATH_DEFINES)
    add_compile_definitions(-D_WIN32_WINNT=0x0602)
    add_compile_definitions(-DNOMINMAX)
    add_compile_definitions(-DWIN32_LEAN_AND_MEAN)
    add_compile_definitions(-DNAME_MAX=255)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
    add_compile_options(-Wno-deprecated-declarations)
    add_compile_options(-Wno-unused-function)
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "Clang$")
    # Clang's default constexpr-steps limit is 1048576(2^20), GCC doesn't have one
    add_compile_options(-fconstexpr-steps=16777216)

    add_compile_options(-Wno-implicit-const-int-float-conversion)
    add_compile_options(-Wno-user-defined-literals)
    add_compile_options(-Wno-vla-cxx-extension)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # Only ignore expansion-to-defined for g++, clang's implementation doesn't complain about function-like macros
    add_compile_options(-Wno-expansion-to-defined)
    add_compile_options(-Wno-literal-suffix)

    # FIXME: This warning seems useful but has too many false positives with GCC 13.
    add_compile_options(-Wno-dangling-reference)
endif()

if (UNIX AND NOT APPLE AND NOT ENABLE_FUZZERS)
    add_compile_options(-fno-semantic-interposition)
    add_compile_options(-fvisibility-inlines-hidden)
endif()
