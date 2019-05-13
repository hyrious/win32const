This repo is used to do search on _*.h_ files.

It works with [TDM-GCC](http://tdm-gcc.tdragon.net/) and [ctags](http://ctags.sourceforge.net/). Make sure `gcc.exe` and `ctags.exe` are in the PATH.

### Usage

    > ruby win32const.rb RGB
    dxvahd.h:46        DXVAHD_COLOR_RGBA   RGB;
    wingdi.h:1395  #define RGB(r,g,b) ((COLORREF)(((BYTE)(r)|((WORD)((BYTE)(g))<<8))|(((DWORD)(BYTE)(b))<<16)))
    > ruby win32const.rb POINT
    windef.h:92    } POINT,*PPOINT,*NPPOINT,*LPPOINT;
    windef.h:89
    typedef struct tagPOINT {
      LONG x;
      LONG y;
    } POINT,*PPOINT,*NPPOINT,*LPPOINT;

### See Also

- [Magic Numebr Database](https://magnumdb.com/)

## License

The MIT License.
