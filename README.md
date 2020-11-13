# Microsoft SEAL

Microsoft SEAL is an easy-to-use open-source ([MIT licensed](LICENSE)) homomorphic encryption library developed by the Cryptography and Privacy Research group at Microsoft.
Microsoft SEAL is written in modern standard C++ and is easy to compile and run in many different environments.
For more information about the Microsoft SEAL project, see [sealcrypto.org](https://www.microsoft.com/en-us/research/project/microsoft-seal).

This document pertains to Microsoft SEAL version 3.6.
Users of previous versions of the library should look at the [list of changes](CHANGES.md).

### Correct Use of Microsoft SEAL

Homomorphic encryption schemes have various and often unexpected security models that may be surprising even to cryptography experts.
In particular, decryptions of Microsoft SEAL ciphertexts should be treated as private information only available to the secret key owner, and sharing information directly or indirectly about a decryption should be thought of as equivalent to sharing information about the secret key itself.
If it is absolutely necessary to share information about the decryption of a ciphertext, the number of bits shared should be kept to a minimum, and no more decryptions under the same secret key should be performed.
Commercial applications of Microsoft SEAL, or any homomorphic encryption library, should be carefully reviewed by experts who are familiar with these matters.

## Contents

- [Microsoft SEAL](#microsoft-seal)
    - [Correct Use of Microsoft SEAL](#correct-use-of-microsoft-seal)
  - [Contents](#contents)
  - [Introduction](#introduction)
    - [Core Concepts](#core-concepts)
    - [Homomorphic Encryption](#homomorphic-encryption)
    - [Microsoft SEAL](#microsoft-seal-1)
  - [Getting Started](#getting-started)
    - [Optional Dependencies](#optional-dependencies)
      - [Microsoft GSL](#microsoft-gsl)
      - [ZLIB and Zstandard](#zlib-and-zstandard)
    - [Installing from NuGet Package (Windows, Linux, macOS, Android, iOS)](#installing-from-nuget-package-windows-linux-macos-android-ios)
    - [Examples](#examples)
  - [Building Microsoft SEAL Manually](#building-microsoft-seal-manually)
    - [Building C++ Components](#building-c-components)
      - [Requirements](#requirements)
      - [Building Microsoft SEAL](#building-microsoft-seal)
      - [Installing Microsoft SEAL](#installing-microsoft-seal)
      - [Building on Windows](#building-on-windows)
      - [Linux, macOS, and FreeBSD](#linux-macos-and-freebsd)
      - [Android and iOS](#android-and-ios)
      - [Basic CMake Options](#basic-cmake-options)
      - [Advanced CMake Options](#advanced-cmake-options)
      - [Linking with Microsoft SEAL through CMake](#linking-with-microsoft-seal-through-cmake)
      - [Examples and Tests](#examples-and-tests)
    - [Building .NET Components](#building-net-components)
    - [Windows](#windows)
      - [Native Library](#native-library)
      - [.NET Library](#net-library)
      - [.NET Examples](#net-examples)
      - [.NET Unit Tests](#net-unit-tests)
      - [Using Microsoft SEAL for .NET in Your Own Application](#using-microsoft-seal-for-net-in-your-own-application)
      - [Building Your Own NuGet Package](#building-your-own-nuget-package)
    - [Linux and macOS](#linux-and-macos)
      - [Native Library](#native-library-1)
      - [.NET Library](#net-library-1)
      - [.NET Examples](#net-examples-1)
      - [.NET Unit Tests](#net-unit-tests-1)
      - [Using Microsoft SEAL for .NET in Your Own Application](#using-microsoft-seal-for-net-in-your-own-application-1)
    - [Android and iOS](#android-and-ios-1)
  - [Contributing](#contributing)
  - [Citing Microsoft SEAL](#citing-microsoft-seal)
    - [Version 3.6](#version-36)
    - [Version 3.5](#version-35)
    - [Version 3.4](#version-34)
    - [Version 3.3](#version-33)
    - [Version 3.2](#version-32)
    - [Version 3.1](#version-31)
    - [Version 3.0](#version-30)

## Introduction

### Core Concepts

Most encryption schemes consist of three functionalities: key generation, encryption, and decryption.
Symmetric-key encryption schemes use the same secret key for both encryption and decryption; public-key encryption schemes use separately a public key for encryption and a secret key for decryption.
Therefore, public-key encryption schemes allow anyone who knows the public key to encrypt data, but only those who know the secret key can decrypt and read the data.
Symmetric-key encryption can be used for efficiently encrypting very large amounts of data, and enables secure outsourced cloud storage.
Public-key encryption is a fundamental concept that enables secure online communication today, but is typically much less efficient than symmetric-key encryption.

While traditional symmetric- and public-key encryption can be used for secure storage and communication, any outsourced computation will necessarily require such encryption layers to be removed before computation can take place.
Therefore, cloud services providing outsourced computation capabilities must have access to the secret keys, and implement access policies to prevent unauthorized employees from getting access to these keys.

### Homomorphic Encryption

Homomorphic encryption refers to encryption schemes that allow the cloud to compute directly on the encrypted data, without requiring the data to be decrypted first.
The results of such encrypted computations remain encrypted, and can be only decrypted with the secret key (by the data owner).
Multiple homomorphic encryption schemes with different capabilities and trade-offs have been invented over the past decade; most of these are public-key encryption schemes, although the public-key functionality may not always be needed.

Homomorphic encryption is not a generic technology: only some computations on encrypted data are possible.
It also comes with a substantial performance overhead, so computations that are already very costly to perform on unencrypted data are likely to be infeasible on encrypted data.
Moreover, data encrypted with homomorphic encryption is many times larger than unencrypted data, so it may not make sense to encrypt, e.g., entire large databases, with this technology.
Instead, meaningful use-cases are in scenarios where strict privacy requirements prohibit unencrypted cloud computation altogether, but the computations themselves are fairly lightweight.

Typically, homomorphic encryption schemes have a single secret key which is held by the data owner.
For scenarios where multiple different private data owners wish to engage in collaborative computation, homomorphic encryption is probably not a reasonable solution.

Homomorphic encryption cannot be used to enable data scientist to circumvent GDPR.
For example, there is no way for a cloud service to use homomorphic encryption to draw insights from encrypted customer data.
Instead, results of encrypted computations remain encrypted and can only be decrypted by the owner of the data, e.g., a cloud service customer.

Most homomorphic encryption schemes provide weaker security guarantees than traditional encryption schemes.
Two things are important to be aware of:

1. Information about decryptions of ciphertexts must not be shared with anyone; see [Correct Use of Microsoft SEAL](#correct-use-of-microsoft-seal).

1. A ciphertext protects the underlying data from anyone who does not have the secret key.

A ciphertext does not protect anything from anyone who has the secret key.
For example, a server cannot apply a proprietary algorithm on encrypted data, return it to the secret key owner, and expect that its algorithm remains protected.

### Microsoft SEAL

Microsoft SEAL is a homomorphic encryption library that allows additions and multiplications to be performed on encrypted integers or real numbers.
Other operations, such as encrypted comparison, sorting, or regular expressions, are in most cases not feasible to evaluate on encrypted data using this technology.
Therefore, only specific privacy-critical cloud computation parts of programs should be implemented with Microsoft SEAL.

It is not always easy or straightfoward to translate an unencrypted computation into a computation on encrypted data, for example, it is not possible to branch on encrypted data.
Microsoft SEAL itself has a steep learning curve and requires the user to understand many homomorphic encryption specific concepts, even though in the end the API is not too complicated.
Even if a user is able to program and run a specific computation using Microsoft SEAL, the difference between efficient and inefficient implementations can be several orders of magnitude, and it can be hard for new users to know how to improve the performance of their computation.

Microsoft SEAL comes with two different homomorphic encryption schemes with very different properties.
The BFV scheme allows modular arithmetic to be performed on encrypted integers.
The CKKS scheme allows additions and multiplications on encrypted real or complex numbers, but yields only approximate results.
In applications such as summing up encrypted real numbers, evaluating machine learning models on encrypted data, or computing distances of encrypted locations CKKS is going to be by far the best choice.
For applications where exact values are necessary, the BFV scheme is the only choice.

## Getting Started

There are multiple ways of installing Microsoft SEAL and starting to use it.
The easiest way is to use a package manager such as [vcpkg](https://github.com/microsoft/vcpkg) or [Homebrew](https://formulae.brew.sh/formula/seal) to download, build, and install the library.
The .NET library is available as a multiplatform [NuGet package](https://www.nuget.org/packages/Microsoft.Research.SEALNet).
Finally, one can build Microsoft SEAL manually with a multiplatform CMake build system; see [Building Microsoft SEAL Manually](#building-microsoft-seal-manually) for details.

### Optional Dependencies

Microsoft SEAL has no required dependencies, but certain optional features can be enabled when compiling with support for specific third-party libraries.

When [building manually](#building-microsoft-seal-manually), one can choose to have the Microsoft SEAL build system download and build the dependencies, or alternatively search the system directories for pre-installed dependencies.
On the other extreme, the downloadable [NuGet package](https://www.nuget.org/packages/Microsoft.Research.SEALNet) cannot be configured at all, but it is always possible to [build a custom NuGet package](#building-your-own-nuget-package).
Other package managers offer varying amounts of opportunities for configuring the dependencies and [other build options](#basic-cmake-options).

The optional dependencies and their tested versions (other versions may work as well) are as follows.

| Optional dependency                                | Tested version | Use                                              |
| -------------------------------------------------- | -------------- | ------------------------------------------------ |
| [Microsoft GSL](https://github.com/microsoft/GSL)  | 3.1.0          | API extensions                                   |
| [ZLIB](https://github.com/madler/zlib)             | 1.2.11         | Compressed serialization                         |
| [Zstandard](https://github.com/facebook/zstd)      | 1.4.5          | Compressed serialization (much faster than ZLIB) |
| [GoogleTest](https://github.com/google/googletest) | 1.10.0         | For running tests                                |

#### Microsoft GSL

Microsoft GSL (Guidelines Support Library) is a header-only library that implements `gsl::span`: a *view type* that provides safe (bounds-checked) array access to memory.

For example, if Microsoft GSL is available, Microsoft SEAL can allow `BatchEncoder` and `CKKSEncoder` to encode from and decode to a `gsl::span` instead of `std::vector`, which can in some cases have a significant performance benefit.

#### ZLIB and Zstandard

ZLIB and Zstandard are widely used compression libraries. Microsoft SEAL can optionally use these libraries to compress data that is serialized.

One may ask how compression can help when ciphertext and key data is supposed to be indistinguishable from random.
In Microsoft SEAL `Ciphertext` objects consist of a large number of integers modulo specific prime numbers (`coeff_modulus` primes).
When using the CKKS scheme in particular, these prime numbers can be quite small (e.g., 30 bits), but the data is nevertheless serialized as 64-bit integers.
Therefore, it is not uncommon that almost half of the ciphertext bytes are zeros, and applying a general-purpose compression algorithm is a convenient way of getting rid this wasted space.
The BFV scheme benefits typically less from this technique, because the prime numbers used for the `coeff_modulus` encryption parameter tend to be larger, and integers modulo these prime numbers fill more of each 64-bit word.
Compressed serialization can be applied to any serializable Microsoft SEAL object &ndash; not just to `Ciphertext` and keys .

If Microsoft SEAL is compiled with ZLIB or Zstandard support, compression will automatically be used for serialization; see `Serialization::compr_mode_default` in [native/src/seal/serialization.h](native/src/seal/serialization.h).
However, it is always possible to explicitly pass `compr_mode_type::none` to serialization methods to disable compression.
If both ZLIB and Zstandard support are enabled, Zstandard is used by default due to its much better performance.

**Note:** The compression rate for a `SecretKey` can (in theory at least) reveal information about the key.
In most common applications of Microsoft SEAL the size of a `SecretKey` would not be deliberately revealed to untrusted parties.
If this is a concern, one can always save the `SecretKey` in an uncompressed form.

<!-- ### Installing with VCPKG (Windows, Unix-like) -->
<!-- To install Microsoft SEAL with all dependencies enabled, run `./vcpkg install seal` or `./vcpkg install seal:x64-windows-static` on Windows. -->
<!-- To install Microsoft SEAL with partial dependencies enabled, for example, only `ms-gsl`, run `./vcpkg install seal[core,ms-gsl]` or `./vcpkg install seal[core,ms-gsl]:x64-windows-static` on Windows. -->

<!-- ### Installing with Homebrew (macOS) -->

### Installing from NuGet Package (Windows, Linux, macOS, Android, iOS)

For .NET developers the easiest way of installing Microsoft SEAL is by using the multiplatform NuGet package available at [NuGet.org](https://www.nuget.org/packages/Microsoft.Research.SEALNet).
Simply add this package into your .NET project as a dependency and you are ready to go.

To develop mobile applications using Microsoft SEAL and .NET for Android and iOS, just add this package to your [Xamarin](https://dotnet.microsoft.com/apps/xamarin) project. Unlike the Microsoft SEAL C++ library, the .NET wrapper library works only on 64-bit platforms, so only `arm64-v8a`/`x86_64` Android ABIs and `arm64`/`x86_64` iOS architectures are supported.

### Examples

Using Microsoft SEAL will require the user to invest some time in learning fundamental concepts in homomorphic encryption.
The code comes with heavily commented examples that are designed to gradually teach such concepts as well as to demonstrate a large fraction of the API.
The examples are available (and identical) in C++ and C#, and are divided into several source files in `native/examples/` (C++) and `dotnet/examples/` (C#), as follows.

| C++                   | C#                   | Description                                                                  |
| --------------------- | -------------------- | ---------------------------------------------------------------------------- |
| `examples.cpp`        | `Examples.cs`        | The example runner application                                               |
| `1_bfv_basics.cpp`    | `1_BFV_Basics.cs`    | Encrypted modular arithmetic using the BFV scheme                            |
| `2_encoders.cpp`      | `2_Encoders.cs`      | Encoding more complex data into Microsoft SEAL plaintext objects             |
| `3_levels.cpp`        | `3_Levels.cs`        | Introduces the concept of levels; prerequisite for using the CKKS scheme     |
| `4_ckks_basics.cpp`   | `4_CKKS_Basics.cs`   | Encrypted real number arithmetic using the CKKS scheme                       |
| `5_rotation.cpp`      | `5_Rotation.cs`      | Performing cyclic rotations on encrypted vectors in the BFV and CKKS schemes |
| `6_serialization.cpp` | `6_Serialization.cs` | Serializing objects in Microsoft SEAL                                        |
| `7_performance.cpp`   | `7_Performance.cs`   | Performance tests                                                            |

It is recommended to read the comments and the code snippets along with command line printout from running an example.
For easier navigation, command line printout provides the line number in the associated source file where the associated code snippets start.
To build the examples, see [Examples and Tests](#examples-and-tests).

**Note:** It is impossible to know how to use Microsoft SEAL correctly without studying all of the examples.
They are designed to provide the reader with the necessary conceptual background on homomorphic encryption.
Reusing code directly from the examples will not work well, as the examples are often demonstrating individual pieces of functionality, and are not optimized for performance.
Writing Microsoft SEAL code without studying the examples in depth will inevitably result in code that is vulnerable, malfunctioning, or extremely slow.

## Building Microsoft SEAL Manually

### Building C++ Components

On all platforms Microsoft SEAL is built with CMake.
We recommend using out-of-source build although in-source build works.
Below we give instructions for how to configure, build, and install Microsoft SEAL either system-wide (global install), or for a single user (local install).
A system-wide install requires elevated (root) privileges.

**NOTE:** Microsoft SEAL compiled with Clang++ has much better runtime performance than that compiled with GNU G++.

#### Requirements

| System | Toolchain |
|---|---|
| Windows | Visual Studio 2019 |
| Linux | Clang++ (>= 5.0) or GNU G++ (>= 6.0), CMake (>= 3.12) |
| macOS/iOS | Xcode toolchain (>= 9.3), CMake (>= 3.12) |
| Android | Android Studio |

#### Building Microsoft SEAL

We assume that Microsoft SEAL has been cloned into a directory called `SEAL` and all commands presented below are assumed to be executed in the directory `SEAL`.

You can build Microsoft SEAL library (out-of-source) for your machine by executing the following commands:

```bash
cmake -S . -B build
cmake --build build
```

Various configuration options can be specified and passed to the CMake build system.
These are decribed below in sections [Basic CMake Options](#basic-cmake-options) and [Advanced CMake Options](#advanced-cmake-options).

#### Installing Microsoft SEAL

If you have root access to the system you can install Microsoft SEAL system-wide as follows:

```bash
cmake -S . -B build
cmake --build build
sudo cmake --install build
```

To instead install Microsoft SEAL locally, e.g., to `~/mylibs/`, do the following:

```bash
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=~/mylibs
cmake --build build
sudo cmake --install build
```

#### Building on Windows

On Windows the same scripts above work in a developer command prompt for Visual Studio.
The right x64 or x86 version of command prompt ...

Ninja/Visual Studio generators.
Please choose the right platform before building Microsoft SEAL.
The `SEAL_C` project and the .NET wrapper library `SEALNet` can only be built for `x64`.
With Ninja generator ...
With Visual Studio generator, a specific architecture flag `-A x64` or `-A x86` should be provided.

Visual Studio / Visual Stuido Code open as CMake project.

Replace `sudo` with administrator.

This results in the static library `seal.lib` to be created in `lib\$(Platform)\$(Configuration)`.
When linking with applications, you need to add `native\src\` (full path) as an include directory for Microsoft SEAL header files.

#### Linux, macOS, and FreeBSD

Microsoft SEAL is very easy to configure and build in Linux and macOS using CMake (>= 3.12).
A modern version of GNU G++ (>= 6.0) or Clang++ (>= 5.0) is needed.
In macOS the Xcode toolchain (>= 9.3) will work.

In macOS you will need CMake with command line tools. For this, you can either

1. install the cmake package with [Homebrew](https://brew.sh), or
1. download CMake directly from [cmake.org/download](https://cmake.org/download) and
[enable command line tools](https://stackoverflow.com/questions/30668601/installing-cmake-command-line-tools-on-a-mac).

#### Android and iOS

Microsoft SEAL can be compiled for Android and iOS.
Under the [android](android) directory of the source tree you will find an [Android Studio](https://developer.android.com/studio) project that you can use to compile the library for Android.

To build the library for iOS, use the following scripts:

```bash
# Configure CMake
cmake -S . -B build -GXcode -DSEAL_BUILD_SEAL_C=ON -DSEAL_BUILD_STATIC_SEAL_C=ON -DCMAKE_SYSTEM_NAME=iOS "-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64" -C cmake/memset_s.iOS.cmake

# Build libseal*.a for x86_64
xcodebuild -project build/SEAL.xcodeproj -sdk iphonesimulator -arch x86_64 -configuration Release clean build
mkdir -p build/lib/x86_64
cp build/lib/Release/libseal*.a build/lib/x86_64

# Build libseal*.a for arm64
xcodebuild -project SEAL.xcodeproj -sdk iphoneos -arch arm64 -configuration Release clean build
mkdir -p build/lib/arm64
cp build/lib/Release/libseal*.a build/lib/arm64

# Combine libseal-*.a into libseal.a and libsealc-*.a into libsealc.a
lipo -create -output build/lib/libseal.a build/lib/x86_64/libseal-*.a arm64/libseal-*.a
lipo -create -output build/lib/libsealc.a build/lib/x86_64/libsealc-*.a build/lib/arm64/libsealc-*.a
```

The native libraries generated through these methods are meant to be called only through the .NET library described in the following sections.
Specifically, they do not contain any wrappers that can be used from Java (for Android) or Objective C (for iOS).

#### Basic CMake Options

The following options can be used with CMake to configure the build. The default value for each option is denoted with boldface in the **Values** column.

| CMake option        | Values                                                       | Information                                                                                                                                                                                            |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| CMAKE_BUILD_TYPE    | **Release**</br>Debug</br>RelWithDebInfo</br>MinSizeRel</br> | `Debug` and `MinSizeRel` have worse run-time performance. `Debug` inserts additional assertion code. Set to `Release` unless you are developing Microsoft SEAL itself or debugging some complex issue. |
| SEAL_BUILD_EXAMPLES | ON / **OFF**                                                 | Build the C++ examples in [native/examples](native/examples).                                                                                                                                          |
| SEAL_BUILD_TESTS    | ON / **OFF**                                                 | Build the tests to check that Microsoft SEAL works correctly.                                                                                                                                          |
| SEAL_BUILD_DEPS     | **ON** / OFF                                                 | Set to `ON` to automatically download and build [optional dependencies](#optional-dependencies); otherwise CMake will attempt to locate pre-installed dependencies.                                    |
| SEAL_USE_MSGSL      | **ON** / OFF                                                 | Build with Microsoft GSL support.                                                                                                                                                                      |
| SEAL_USE_ZLIB       | **ON** / OFF                                                 | Build with ZLIB support.                                                                                                                                                                               |
| SEAL_USE_ZSTD       | **ON** / OFF                                                 | Build with Zstandard support.                                                                                                                                                                          |
| BUILD_SHARED_LIBS   | ON / **OFF**                                                 | Set to `ON` to build a shared library instead of a static library. Not supported in Windows.                                                                                                           |
| SEAL_BUILD_SEAL_C   | ON / **OFF**                                                 | Build the C wrapper library SEAL_C. This is used by the C# wrapper and most users should have no reason to build it.                                                                                   |
| SEAL_USE_CXX17      | **ON** / OFF                                                 | Set to `ON` to build Microsoft SEAL as C++17 for a positive performance impact.                                                                                                                        |
| SEAL_USE_INTRIN     | **ON** / OFF                                                 | Set to `ON` to use compiler intrinsics for improved performance. CMake will automatically detect which intrinsics are available and enable them accordingly.                                           |

As usual, these options can be passed to CMake with the `-D` flag.
For example, one could run
```bash
cmake -S . -B build -DSEAL_BUILD_EXAMPLES=ON
```
to configure a release build of a static Microsoft SEAL library and also build the examples.

#### Advanced CMake Options

The following options can be used with CMake to further configure the build. Most users should have no reason to change these, which is why they are marked as advanced.

| CMake option                         | Values                    | Information                                                                                                                                                                                                                                                                                              |
| ------------------------------------ | ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SEAL_THROW_ON_TRANSPARENT_CIPHERTEXT | **ON** / OFF              | Set to `ON` to throw an exception when Microsoft SEAL produces a ciphertext with no key-dependent component. For example, subtracting a ciphertext from itself, or multiplying a ciphertext with a plaintext zero yield identically zero ciphertexts that should not be considered as valid ciphertexts. |
| SEAL_BUILD_STATIC_SEAL_C             | ON / **OFF**              | Set to `ON` to build SEAL_C as a static library instead of a shared library.                                                                                                                                                                                                                             |
| SEAL_DEFAULT_PRNG                    | **Blake2xb**</br>Shake256 | Microsoft SEAL supports both Blake2xb and Shake256 XOFs for generating random bytes. Blake2xb is much faster, but it is not standardized, whereas Shake256 is a FIPS standard.                                                                                                                           |
| SEAL_USE_GAUSSIAN_NOISE              | ON / **OFF**              | Set to `ON` to use a non-constant time rounded continuous Gaussian for the error distribution; otherwise a centered binomial distribution &ndash; with slightly larger standard deviation &ndash; is used.                                                                                               |

#### Linking with Microsoft SEAL through CMake

It is very easy to link your own applications and libraries with Microsoft SEAL if you use CMake.
Simply add the following to your `CMakeLists.txt`:

```bash
find_package(SEAL 3.6 REQUIRED)
target_link_libraries(<your target> SEAL::seal)
```

If Microsoft SEAL was installed globally, the above `find_package` command will likely find the library automatically.
To link with a Microsoft SEAL installed locally or by a package manager, e.g., installed in `~/mylibs` as described above, you may need to tell CMake where to look for Microsoft SEAL when you configure your application by running:

```bash
cd <directory containing your CMakeLists.txt>
cmake . -DCMAKE_PREFIX_PATH=~/mylibs
```

See [native/examples/CMakeLists.txt](native/examples/CMakeLists.txt) as a sample CMake project that is linked with Microsoft SEAL.

#### Examples and Tests

When building Microsoft SEAL, examples and tests can be built by enabling [Basic CMake Options](basic-cmake-options): `SEAL_BUILD_EXAMPES` and `SEAL_BUILD_TESTS`.
Alternatively, both [examples](native/examples/CMakeLists.txt) and [tests](native/tests/CMakeLists.txt) can be built as standalone CMake projects that are linked with Microsoft SEAL installed to `~/mylibs`, by following the scripts below. Omit `-DCMAKE_PREFIX_PATH` if Microsoft is installed globally.

```bash
cd native/<examples-or-tests>
cmake -S . -B build -DCMAKE_PREFIX_PATH=~/mylibs
cmake --build build
```

### Building .NET Components

Microsoft SEAL provides a .NET Standard library that wraps the functionality in Microsoft SEAL for use in .NET development.

### Windows

The Microsoft Visual Studio 2019 solution file `SEAL.sln` contains the projects necessary to build the .NET assembly, a backing native shared library, .NET examples, and unit tests.

#### Native Library

Microsoft SEAL for .NET requires a native library that is invoked by the managed .NET library.
Build the SEAL_C project `native\src\SEAL_C_.vcxproj` from `SEAL.sln`.
Building SEAL_C results in the dynamic library `sealc.dll` to be created in `lib\$(Platform)\$(Configuration)`.
This library is meant to be used only by the .NET library, not by end users, and needs to be present in the same directory as your executable when running a .NET application.

#### .NET Library

Once you have built the shared native library (see above), build the SEALNet project `dotnet\src\SEALNet.csproj` from `SEAL.sln`.
Building SEALNet results in the assembly `SEALNet.dll` to be created in `lib\dotnet\$(Configuration)\netstandard2.0`.
This is the assembly you can reference in your application.

#### .NET Examples

Build the SEALNetExamples project `dotnet\examples\SEALNetExamples.csproj` from `SEAL.sln`.
This results in the assembly `SEALNetExamples.dll` to be created in `bin\dotnet\$(Configuration)\netcoreapp3.1`.
The project takes care of copying the native SEAL_C library to the output directory.

#### .NET Unit Tests

Build the SEALNetTest project `dotnet\tests\SEALNetTest.csproj` from `SEAL.sln`.
This results in the assembly `SEALNetTest.dll` to be created in `bin\dotnet\$(Configuration)\netcoreapp3.1`.
The project takes care of copying the native SEAL_C library to the output directory.

#### Using Microsoft SEAL for .NET in Your Own Application

To use Microsoft SEAL for .NET in your own application you need to:

1. add a reference in your project to `SEALNet.dll`;
1. ensure `sealc.dll` is available for your application when run.
The easiest way to ensure this is to copy `sealc.dll` to the same directory where your application's executable is located.

#### Building Your Own NuGet Package

You can build your own NuGet package for Microsoft SEAL by following the instructions in [NUGET.md](dotnet/nuget/NUGET.md).

### Linux and macOS

Microsoft SEAL for .NET relies on a native shared library that can be easily configured and built using CMake (>= 3.12) and a modern version of GNU G++ (>= 6.0) or Clang++ (>= 5.0).
In macOS the Xcode toolchain (>= 9.3) will work.

For compiling .NET code you will need to install a .NET Core SDK (>= 3.1).
You can follow these [instructions for installing in Linux](https://dotnet.microsoft.com/download?initial-os=linux), or for [installing in macOS](https://dotnet.microsoft.com/download?initial-os=macos).

#### Native Library

If you only intend to run the examples and unit tests provided with Microsoft SEAL, you do not need to install the native shared library.
You only need to compile it.
The SEALNetExamples and SEALNetTest projects take care of copying the native shared library to the appropriate assembly output directory.

Microsoft SEAL by default does not build SEAL_C.
You can enable it in CMake configuration options as follows:

```bash
cmake -S . -B build -DSEAL_BUILD_SEAL_C=ON
make -C build
```

This results in a shared native library `libsealc.so*` in Linux or `libsealc*.dylib` in macOS.

If you have root access to the system, you have the option to install the native shared library globally.
Then your application will always be able to find and load it.
Assuming Microsoft SEAL is build and installed globally, you can install the shared native library globally as follows:

```bash
sudo make -C build install
```

#### .NET Library

To build the .NET Standard library, do the following:

```bash
dotnet build dotnet/src --configuration <Debug|Release>
```

This will result in a `SEALNet.dll` assembly to be created in `lib/dotnet/$(Configuration)/netstandard2.0`.
This assembly is the one you will want to reference in your own projects.
The optional `dotnet` parameter `--configuration <Debug|Release>` can be used to build either a `Debug` or `Release` version of the assembly.

#### .NET Examples

To build and run the .NET examples, do:

```bash
dotnet run -p dotnet/examples
```

As mentioned before, the .NET project will copy the shared native library to the assembly output directory.
You can use the `dotnet` parameter `--configuration <Debug|Release>` to run either `Debug` or `Release` versions of the examples.

#### .NET Unit Tests

To build and run the .NET unit tests, do:

```bash
dotnet test dotnet/tests
```

All unit tests should pass.
You can use the `dotnet` parameter `--configuration <Debug|Release>` to run `Debug` or `Relase` unit tests.
And you can use `--verbosity detailed` to print the list of unit tests that are being run.

#### Using Microsoft SEAL for .NET in Your Own Application

To use Microsoft SEAL for .NET in your own application you need to:

1. add a reference in your project to `SEALNet.dll`;
1. ensure the native shared library is available for your application when run.
The easiest way to ensure this is to copy the native shared library to the same directory where your application's executable is located.

### Android and iOS

You can use [Android Studio](https://developer.android.com/studio) to build the native shared library used by the .NET Standard wrapper library for Android.
If you want to build for iOS, please take a look at our [iOS pipeline](pipelines/ios.yml) file to see how to configure and build the native library using CMake and Xcode.

However, the recommended way of using SEAL for .NET in Android and iOS is to add a reference to the multiplatform [NuGet package](https://www.nuget.org/packages/Microsoft.Research.SEALNet) to your [Xamarin](https://dotnet.microsoft.com/apps/xamarin) project.

## Contributing

For contributing to Microsoft SEAL, please see [CONTRIBUTING.md](CONTRIBUTING.md).

## Citing Microsoft SEAL

To cite Microsoft SEAL in academic papers, please use the following BibTeX entries.

### Version 3.6

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.6)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = nov,
        year = 2020,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.5

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.5)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = apr,
        year = 2020,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.4

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.4)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = oct,
        year = 2019,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.3

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.3)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = jun,
        year = 2019,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.2

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.2)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = feb,
        year = 2019,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.1

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.1)},
        howpublished = {\url{https://github.com/Microsoft/SEAL}},
        month = dec,
        year = 2018,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```

### Version 3.0

```tex
    @misc{sealcrypto,
        title = {{M}icrosoft {SEAL} (release 3.0)},
        howpublished = {\url{http://sealcrypto.org}},
        month = oct,
        year = 2018,
        note = {Microsoft Research, Redmond, WA.},
        key = {SEAL}
    }
```
