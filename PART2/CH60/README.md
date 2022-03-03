# BSPMAKER and MAZE

The [DDJBSP2.zip](DDJBSP2.zip) included here is from book CD-ROM for 32-bit Windows apps. See its included `README.txt`, which states

>  Both programs are Win32 programs, tested with VC++ 2.0 running on Windows NT 3.5.

The file `\BSPMAKER\BSPMAKER.CPP` was edited so that it compiles on Windows 10 x86 target in Visual Studio 2022/Visual C++. 

## Building the apps

You can import the respective directories into Visual Studio with `File >> New > Project From Existing Code...`  Build the `x86` target.

They can also be built from command line using the old-school Makefiles. Start a "Developer Command Prompot for VS 2022" and use `NMAKE`. for example:

```console
DEV>cd \BSPMAKER\
DEV>NMAKE /f BASPMAKER.MAK
```

## Running the apps

`BSPMAKER` runs and works great, including saving compiled BSP-s.

`MAZE` works partly, but sometime in the intervening 25+ years since it was published, the way it handles keyboard input and other events has fallen into disrepair w.r.t. Windows state of the art.  

- It loads the BSP file named `BSPTREE.TXT` in the directory it was launched from, and draws the initial viewpoint. But then it does not handle more than one or two input events before it stops updating the GUI. 

- The `File > Quit` menu item is not displayed correctly (at least on my desktop) but it functions to exit the app when activated.

**TODO**: Someone who knows basic Win32 programming should be able to update the event loop and have it fully working on Windows 10.

