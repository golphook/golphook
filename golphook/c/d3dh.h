#include "d3d9.h"
#include "d3dx9.h"

unsigned int d3d_rgba(int r,int g,int b,int a) {
    return (unsigned int)D3DCOLOR_RGBA(r,g,b,a);
}
