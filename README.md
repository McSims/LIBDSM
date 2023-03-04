
Things dont know how to resolve:

In order to xcode to resolve libdsm headers we need:
- to remove `bdsm`part from include in all headers
- remake include <libtasn1> -> include "libtasn1"