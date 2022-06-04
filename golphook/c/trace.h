#include "windows.h"


// im sorry but i spent to much time trying to make is work in v since it wasn't
// possible to make it in v due to the lack of support for calling coventions
// https://github.com/danielkrupinski/Anubis/blob/master/Anubis/SDK/EngineTrace.c

// note this was before my pr to vlang its now possible to implement it

#define CALL_VIRTUAL_METHOD(type, this, index, ...) (((type)(((PUINT*)(this))[0][index]))(this, 0, __VA_ARGS__));

typedef struct TraceFilter {
    PVOID vmt;
    PVOID skip;
} TraceFilter;

static bool __fastcall shouldHitEntity(TraceFilter* traceFilter, PVOID _1, PVOID entity, INT _2)
{
    return entity != traceFilter->skip;
}

static INT __fastcall getTraceType()
{
    return 0;
}

static PVOID traceFilterVmt[2] = { shouldHitEntity, getTraceType };

VOID TraceFilter_init(TraceFilter* traceFilter)
{
    traceFilter->vmt = traceFilterVmt;
}

void IEngineTrace_trace(void* thi, void* ray, UINT mask, void* filter, void* trace ) {

    TraceFilter* tf = (TraceFilter*)filter;
    TraceFilter_init(tf);

    CALL_VIRTUAL_METHOD(VOID(__fastcall*)(PVOID, PVOID, const void*, UINT, const void*, void*), thi, 5, ray, mask, filter, trace);
}
