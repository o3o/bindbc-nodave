# bindbc-nodave
This project provides both static and dynamic bindings to [the libnodave library](http://libnodave.sourceforge.net/).

## Usage
__NOTE__: This documentation describes how to use bindbc-nodave. As the maintainer of this library, I do not provide instructions on using the libnodave library.

By default, bindbc-nodave is configured to compile as a dynamic binding that is not `-betterC` compatible. The dynamic binding has no link-time dependency on the libnodave library, so the libnodave shared library must be manually loaded at runtime. When configured as a static binding, there is a link-time dependency on the libnodave library through either the static library or the appropriate file for linking with shared libraries on your platform (see below).

When using DUB to manage your project, the static binding can be enabled via a DUB `subConfiguration` statement in your project's package file.

To use libnodave, add bindbc-glfw as a dependency to your project's package config file. For example, the following is configured to use libnodave as a dynamic binding that is not `-betterC` compatible:

__dub.json__
```
dependencies {
    "bindbc-nodave": "~>0.1.0",
}
```

__dub.sdl__
```
dependency "bindbc-nodave" version="~>0.1.0"
```

### The dynamic binding
The dynamic binding requires no special configuration when using DUB to manage your project.
There is no link-time dependency. At runtime, the libnodave shared library is required to be on the shared library search path of the user's system. On Windows, this is typically handled by distributing the libnodave DLL with your program. On other systems, it usually means the user must install the libnodave runtime library through a package manager.

To load the shared library, you need to call the `loadNodave` function.
This returns a member of the `NodaveSupport` enumeration:

* `NodaveSupport.noLibrary` indicating that the library failed to load (it couldn't be found)
* `NodaveSupport.badLibrary` indicating that one or more symbols in the library failed to load
* a member of `NodaveSupport` indicating a version number that matches the version of libnodave that bindbc-nodave was configured at compile-time to load. By default, that is `NodaveSupport.nodave851`, but can be configured via a version identifier (see below).
This value will match the global manifest constant, `nodaveSupport`.

```d

import bindbc.nodave;

/*
 * This version attempts to load the GLFW shared library using well-known variations
 * of the library name for the host system.
*/
NodaveSupport ret = loadNodave();
if(ret != nodaveSupport) {
    /*
     Handle error. For most use cases, it's reasonable to use the the error handling API in bindbc-loader to retrieve
     error messages for logging and then abort. If necessary, it's possible to determine the root cause via the return
     value:
    */

    if(ret == NodaveSupport.noLibrary) {
        // The libnodave shared library failed to load
    }
    else if(NodaveSupport.badLibrary) {
        /*
         One or more symbols failed to load. The likely cause is that the shared library is for a lower version than bindbc-glfw was configured to load (via GLFW_31, GLFW_32 etc.)
        */
    }
}

```

[The error reporting API](https://github.com/BindBC/bindbc-loader#error-handling) in bindbc-loader can be used to log error messages.
