This repo is used to do search on _*.h_ files.

It works with [TDM-GCC](http://tdm-gcc.tdragon.net/) and [ctags](http://ctags.sourceforge.net/). Make sure `gcc.exe` and `ctags.exe` are in the PATH.

### Usage

    > ruby win32const.rb RGB
    C:/TDM-GCC-64/x86_64-w64-mingw32/include/dxvahd.h:46        DXVAHD_COLOR_RGBA   RGB;
    C:/TDM-GCC-64/x86_64-w64-mingw32/include/wingdi.h:1395  #define RGB(r,g,b) ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))
    > ruby win32const.rb POINT
    C:/TDM-GCC-64/x86_64-w64-mingw32/include/windef.h:92    } POINT,*PPOINT,*NPPOINT,*LPPOINT;
    C:/TDM-GCC-64/x86_64-w64-mingw32/include/windef.h:89
    typedef struct tagPOINT {
      LONG x;
      LONG y;
    } POINT,*PPOINT,*NPPOINT,*LPPOINT;

### See Also

- [Magic Numebr Database](https://magnumdb.com/)

## License

The MIT License.
