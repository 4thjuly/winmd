# Low level wrapper for metadataimport

import Base.@kwdef

const DEFAULT_BUFFER_LEN = 1024
const S_OK = 0x00000000
const CorOpenFlags_ofRead = 0x00000000;
const TYPEREF_TYPE_FLAG = 0x01000000
const TYPEDEF_TYPE_FLAG = 0x02000000
const FIELDDEF_TYPE_FLAG = 0x04000000
const TYPESPEC_TYPE_FLAG = 0x1b000000

const Byte = UInt8
const HRESULT = UInt32
const ULONG32 = UInt32
const ULONG = UInt32
const DWORD = UInt32
const mdToken = ULONG32
const mdTypeDef = mdToken
const mdMethodDef = mdToken
const mdModuleRef = mdToken
const mdParamDef = mdToken
const mdSignature = mdToken
const mdTypeRef = mdToken
const mdTypeSpec = mdToken
const mdFieldDef = mdToken
const mdTokenNil = mdToken(0)

const UVCP_CONSTANT = Ptr{Cvoid}
const HCORENUM = Ptr{Cvoid}
const COR_SIGNATURE = UInt8

struct HRESULT_FAILED <: Exception 
    hresult::HRESULT
end

struct GUID
    Data1::Culong
    Data2::Cushort
    Data3::Cushort
    Data4::NTuple{8,Byte}
end

const CLSID = GUID
const IID = GUID

parse_hexbytes(s::String) = parse(Byte, s, base = 16)

# Guid of form 12345678-0123-5678-0123-567890123456
macro guid_str(s)
    GUID(parse(Culong, s[1:8], base = 16),   # 12345678
        parse(Cushort, s[10:13], base = 16), # 0123
        parse(Cushort, s[15:18], base = 16), # 5678
        (parse_hexbytes(s[20:21]),           # 0123
            parse_hexbytes(s[22:23]), 
            parse_hexbytes(s[25:26]),        # 567890123456
            parse_hexbytes(s[27:28]), 
            parse_hexbytes(s[29:30]), 
            parse_hexbytes(s[31:32]), 
            parse_hexbytes(s[33:34]), 
            parse_hexbytes(s[35:36])))
end

const CLSID_CorMetaDataDispenser = guid"E5CB7A31-7512-11d2-89CE-0080C792E5D8"
const IID_IMetaDataDispenser = guid"809C652E-7396-11D2-9771-00A0C9B4D50C"
const IID_IMetaDataImport = guid"7DAC8207-D3AE-4C75-9B67-92801A497D44"

struct IUnknown
    QueryInterface::Ptr{Cvoid}
    AddRef::Ptr{Cvoid}
    Release::Ptr{Cvoid}
end

# TODO - Make Interface definitions a macro?
# - Create the vtbl, prepend other interface (eg IUnknown) and define the IID_ ala DECLARE_INTERFACE_IID 
# @declare_interface_iid IMetaDataDispenser IUnknown "7DAC8207-D3AE-4C75-9B67-92801A497D44"
#     ...
# end

struct IMetaDataDispenser
    iUnknown::IUnknown
    DefineScope::Ptr{Cvoid}
    OpenScope::Ptr{Cvoid}
    OpenScopeOnMemmory::Ptr{Cvoid}
end

struct COMObject{T}
    pvtbl::Ptr{T}
end

struct COMWrapper{T}
    punk::Ptr{COMObject{T}}
    vtbl::T
end

function metadataDispenser()
    rpmdd = Ref(Ptr{COMObject{IMetaDataDispenser}}(C_NULL))
    res = @ccall "Rometadata".MetaDataGetDispenser( 
        Ref(CLSID_CorMetaDataDispenser)::Ptr{Cvoid}, 
        Ref(IID_IMetaDataDispenser)::Ptr{Cvoid}, 
        rpmdd::Ref{Ptr{COMObject{IMetaDataDispenser}}}
        )::HRESULT
    if res == S_OK
        pmdd = rpmdd[]
        mdd = unsafe_load(pmdd)
        vtbl = unsafe_load(mdd.pvtbl)
        return COMWrapper{IMetaDataDispenser}(pmdd, vtbl)
    end
    throw(HRESULT_FAILED(res))
end

struct IMetaDataImport
    iUnknown::IUnknown
    CloseEnum::Ptr{Cvoid}         
    CountEnum::Ptr{Cvoid} 
    ResetEnum::Ptr{Cvoid} 
    EnumTypeDefs::Ptr{Cvoid} 
    EnumInterfaceImpls::Ptr{Cvoid} 
    EnumTypeRefs::Ptr{Cvoid} 
    FindTypeDefByName::Ptr{Cvoid} 
    GetScopeProps::Ptr{Cvoid} 
    GetModuleFromScope::Ptr{Cvoid} 
    GetTypeDefProps::Ptr{Cvoid} 
    GetInterfaceImplProps::Ptr{Cvoid} 
    GetTypeRefProps::Ptr{Cvoid} 
    ResolveTypeRef::Ptr{Cvoid} 
    EnumMembers::Ptr{Cvoid} 
    EnumMembersWithName::Ptr{Cvoid} 
    EnumMethods::Ptr{Cvoid} 
    EnumMethodsWithName::Ptr{Cvoid} 
    EnumFields::Ptr{Cvoid} 
    EnumFieldsWithName::Ptr{Cvoid} 
    EnumParams::Ptr{Cvoid} 
    EnumMemberRefs::Ptr{Cvoid} 
    EnumMethodImpls::Ptr{Cvoid} 
    EnumPermissionSets::Ptr{Cvoid} 
    FindMember::Ptr{Cvoid} 
    FindMethod::Ptr{Cvoid} 
    FindField::Ptr{Cvoid} 
    FindMemberRef::Ptr{Cvoid} 
    GetMethodProps::Ptr{Cvoid} 
    GetMemberRefProps::Ptr{Cvoid} 
    EnumProperties::Ptr{Cvoid} 
    EnumEvents::Ptr{Cvoid} 
    GetEventProps::Ptr{Cvoid} 
    EnumMethodSemantics::Ptr{Cvoid} 
    GetMethodSemantics::Ptr{Cvoid} 
    GetClassLayout::Ptr{Cvoid} 
    GetFieldMarshal::Ptr{Cvoid} 
    GetRVA::Ptr{Cvoid} 
    GetPermissionSetProps::Ptr{Cvoid} 
    GetSigFromToken::Ptr{Cvoid} 
    GetModuleRefProps::Ptr{Cvoid} 
    EnumModuleRefs::Ptr{Cvoid} 
    GetTypeSpecFromToken::Ptr{Cvoid} 
    GetNameFromToken::Ptr{Cvoid} 
    EnumUnresolvedMethods::Ptr{Cvoid} 
    GetUserString::Ptr{Cvoid} 
    GetPinvokeMap::Ptr{Cvoid} 
    EnumSignatures::Ptr{Cvoid} 
    EnumTypeSpecs::Ptr{Cvoid} 
    EnumUserStrings::Ptr{Cvoid} 
    GetParamForMethodIndex::Ptr{Cvoid} 
    EnumCustomAttributes::Ptr{Cvoid} 
    GetCustomAttributeProps::Ptr{Cvoid} 
    FindTypeRef::Ptr{Cvoid} 
    GetMemberProps::Ptr{Cvoid} 
    GetFieldProps::Ptr{Cvoid} 
    GetPropertyProps::Ptr{Cvoid} 
    GetParamProps::Ptr{Cvoid} 
    GetCustomAttributeByName::Ptr{Cvoid} 
    IsValidToken::Ptr{Cvoid} 
    GetNestedClassProps::Ptr{Cvoid} 
    GetNativeCallConvFromSig::Ptr{Cvoid} 
    IsGlobal::Ptr{Cvoid} 
end

function metadataImport(mdd::COMWrapper{IMetaDataDispenser})
    rpmdi = Ref(Ptr{COMObject{IMetaDataImport}}(C_NULL))
    res = @ccall $(mdd.vtbl.OpenScope)(
        mdd.punk::Ref{COMObject{IMetaDataDispenser}}, 
        "Windows.Win32.winmd"::Cwstring,
        CorOpenFlags_ofRead::Cuint, 
        Ref(IID_IMetaDataImport)::Ptr{Cvoid}, 
        rpmdi::Ref{Ptr{COMObject{IMetaDataImport}}}
        )::HRESULT
    if res == S_OK
        pmdi = rpmdi[]
        mdi = unsafe_load(pmdi)
        vtbl = unsafe_load(mdi.pvtbl)
        return COMWrapper{IMetaDataImport}(pmdi, vtbl)
    end
    throw(HRESULT_FAILED(res))
end

function findTypeDef(mdi::COMWrapper{IMetaDataImport}, name::String)::mdToken
    rStructToken = Ref(mdToken(0))
    res = @ccall $(mdi.vtbl.FindTypeDefByName)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        name::Cwstring, 
        mdTokenNil::mdToken, 
        rStructToken::Ref{mdToken}
        )::HRESULT
    if res == S_OK
        return rStructToken[]
    end
    return mdTokenNil
end

function findMethod(mdi::COMWrapper{IMetaDataImport}, td::mdTypeDef, methodName::String)
    rmethodDef = Ref(mdToken(0))
    res = @ccall $(mdi.vtbl.FindMethod)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        td::mdTypeDef,
        methodName::Cwstring, 
        C_NULL::Ref{Cvoid}, 
        0::ULONG, 
        rmethodDef::Ref{mdToken}
        )::HRESULT 
    if res == S_OK
        return rmethodDef[]
    end
    return mdTokenNil
end

function getPInvokeMap(mdi::COMWrapper{IMetaDataImport}, md::mdMethodDef)
    rflags = Ref(DWORD(0))
    importname = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rnameLen = Ref(ULONG(0))
    rmoduleRef = Ref(mdModuleRef(0))
    res = @ccall $(mdi.vtbl.GetPinvokeMap)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        md::mdMethodDef, 
        rflags::Ref{DWORD},
        importname::Ref{Cwchar_t},
        length(importname)::ULONG, 
        rnameLen::Ref{ULONG}, 
        rmoduleRef::Ref{mdModuleRef}
        )::HRESULT
    if res == S_OK
        return (rmoduleRef[], transcode(String, importname[begin:rnameLen[]-1]))
    end
    return (mdTokenNil, "")
end

function getModuleRefProps(mdi::COMWrapper{IMetaDataImport}, mr::mdModuleRef)
    modulename = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rmodulanameLen = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.GetModuleRefProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        mr::mdModuleRef,
        modulename::Ref{Cwchar_t},
        length(modulename)::ULONG,
        rmodulanameLen::Ref{ULONG}
        )::HRESULT
    if res == S_OK
        return transcode(String, modulename[begin:rmodulanameLen[]-1])
    end
    return ""
end

function getParamForMethodIndex(mdi::COMWrapper{IMetaDataImport}, md::mdMethodDef, i::Int)
    rparamDef = Ref(mdParamDef(0))
    res = @ccall $(mdi.vtbl.GetParamForMethodIndex)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        md::mdMethodDef,
        ULONG(i)::ULONG,
        rparamDef::Ref{mdParamDef}
    )::HRESULT
    if res == S_OK
        return rparamDef[]
    end
    return mdTokenNil
end

function getParamProps(mdi::COMWrapper{IMetaDataImport}, paramDef::mdParamDef)
    paramName = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rparamMethodDef = Ref(mdMethodDef(0))
    rparamNameLen = Ref(ULONG(0))
    rseq = Ref(ULONG(0))
    rattr = Ref(DWORD(0))
    rcplustypeFlag = Ref(DWORD(0))
    rpvalue = Ptr{Cvoid}(0)
    rcchValue = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.GetParamProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        paramDef::mdParamDef,
        rparamMethodDef::Ref{mdMethodDef},
        rseq::Ref{ULONG},
        paramName::Ref{Cwchar_t},
        length(paramName)::ULONG,
        rparamNameLen::Ptr{ULONG},
        rattr::Ptr{DWORD},
        rcplustypeFlag::Ptr{DWORD},
        rpvalue::Ptr{Cvoid},
        rcchValue::Ptr{ULONG}
        )::HRESULT
    # @show res
    # @show rparamMethodDef[]
    # @show rseq[]
    # @show rparamNameLen[]
    # println("Param: ", transcode(String, paramName[begin:rparamNameLen[]-1]))
    if res == S_OK
        return transcode(String, paramName[begin:rparamNameLen[]-1])
    end
    return ""
end

function getMethodProps(mdi::COMWrapper{IMetaDataImport}, methodDef::mdMethodDef)
    rclass = Ref(mdTypeDef(0))
    methodName = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rmethodNameLen = Ref(ULONG(0))
    rattr = Ref(DWORD(0))
    rpsig = Ref(Ptr{COR_SIGNATURE}(C_NULL))
    rsigLen = Ref(ULONG(0))
    rrva = Ref(ULONG(0))
    rflags = Ref(DWORD(0))
    res = @ccall $(mdi.vtbl.GetMethodProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        methodDef::mdMethodDef,
        rclass::Ref{mdTypeDef},
        methodName::Ref{Cwchar_t},
        length(methodName)::ULONG,
        rmethodNameLen::Ref{ULONG},
        rattr::Ref{DWORD},
        rpsig::Ref{Ptr{COR_SIGNATURE}},
        rsigLen::Ref{ULONG},
        rrva::Ref{ULONG},
        rflags::Ref{DWORD}
        )::HRESULT
    # @show res
    # @show rclass[]
    # @show rmethodNameLen[]
    # println("methodName: ", transcode(String, methodName[begin:rmethodNameLen[]-1]))
    # @show rsigLen[]
    if res == S_OK
        return unsafe_wrap(Vector{COR_SIGNATURE}, Ptr{UInt8}(rpsig[]), rsigLen[])
    end
    throw(HRESULT_FAILED(res))
end

function uncompress(sig::AbstractVector{COR_SIGNATURE})
    val::UInt32 = UInt32(0)
    len = 0
    if sig[1] & 0x80 == 0x00
        val = UInt32(sig[1])
        len = 1
    elseif sig[1] & 0xC0 == 0x80
        val = UInt32(sig[1] & 0x3F) << 8 | UInt32(sig[2])
        len = 2
    elseif sig[1] & 0xE0 == 0xC0
        val = UInt32(sig[1] & 0x1f) << 24 | UInt32(sig[2]) << 16 | UInt32(sig[3]) << 8 | UInt32(sig[4])
        len = 4
    else
        error("Bad signature")
    end
    return (val, len)
end

function uncompressToken(sig::AbstractVector{COR_SIGNATURE})
    val, len = uncompress(sig)
    tok::mdToken = mdTokenNil
    if val & 0x03 == 0x00
        tok = mdTypeDef(TYPEDEF_TYPE_FLAG | (val >> 2))
    elseif val & 0x03 == 0x01
        tok = mdTypeRef(TYPEREF_TYPE_FLAG | (val >> 2))
    elseif val & 0x03 == 0x02
        tok = mdTypeDef(TYPESPEC_TYPE_FLAG | (val >> 2))
    end
    return tok, len
end

# check
function isValidToken(mdi::COMWrapper{IMetaDataImport}, tok::mdToken)::Bool
    return @ccall $(mdi.vtbl.IsValidToken)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        tok::mdToken
        )::Bool
end

function getTypeRefName(mdi::COMWrapper{IMetaDataImport}, tr::mdTypeRef)::String
    rscope = Ref(mdToken(0))
    name = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rnameLen = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.GetTypeRefProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        tr::mdTypeRef,
        rscope::Ref{mdToken},
        name::Ref{Cwchar_t},
        length(name)::ULONG,
        rnameLen::Ref{ULONG}
        )::HRESULT
    if res == S_OK
        return transcode(String, name[begin:rnameLen[]-1])
    end
    return ""
end

function getName(mdi::COMWrapper{IMetaDataImport}, mdt::mdToken)
    if mdt & TYPEDEF_TYPE_FLAG == TYPEDEF_TYPE_FLAG
        name = getTypeDefProps(mdi, mdt)
        return name
    elseif mdt & TYPEREF_TYPE_FLAG == TYPEREF_TYPE_FLAG
        return getTypeRefName(mdi, mdt)
    else
        return ""
    end
end

function findTypeDef(mdi::COMWrapper{IMetaDataImport}, name::String)::mdToken
    rStructToken = Ref(mdToken(0))
    res = @ccall $(mdi.vtbl.FindTypeDefByName)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        name::Cwstring, 
        mdTokenNil::mdToken, 
        rStructToken::Ref{mdToken}
        )::HRESULT
    if res == S_OK
        return rStructToken[]
    end
    return mdTokenNil
end

# function getTypeDefName(mdi::COMWrapper{IMetaDataImport}, td::mdTypeDef)::String
#     name = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
#     rnameLen = Ref(ULONG(0))
#     rflags = Ref(DWORD(0))
#     rextends = Ref(mdToken(0))
#     res = @ccall $(mdi.vtbl.GetTypeDefProps)(
#         mdi.punk::Ref{COMObject{IMetaDataImport}}, 
#         td::mdTypeDef,
#         name::Ref{Cwchar_t},
#         length(name)::ULONG,
#         rnameLen::Ref{ULONG},
#         rflags::Ref{DWORD},
#         rextends::Ref{mdToken}
#         )::HRESULT
#     return res == S_OK ? transcode(String, name[begin:rnameLen[]-1]) : ""
# end

function getTypeDefProps(mdi::COMWrapper{IMetaDataImport}, td::mdTypeDef)
    name = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rnameLen = Ref(ULONG(0))
    rflags = Ref(DWORD(0))
    rextends = Ref(mdToken(0))
    res = @ccall $(mdi.vtbl.GetTypeDefProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        td::mdTypeDef,
        name::Ref{Cwchar_t},
        length(name)::ULONG,
        rnameLen::Ref{ULONG},
        rflags::Ref{DWORD},
        rextends::Ref{mdToken}
        )::HRESULT
    if res == S_OK
        return (name=transcode(String, name[begin:rnameLen[]-1]), extends=rextends[], flags=rflags[])
    end
    throw(HRESULT_FAILED(res))
end

function fieldProps(mdi::COMWrapper{IMetaDataImport}, fd::mdFieldDef)
    rclass = Ref(mdTypeDef(0))
    fieldname = zeros(Cwchar_t, DEFAULT_BUFFER_LEN)
    rfieldnameLen = Ref(ULONG(0))
    rattrs = Ref(DWORD(0))
    rpsigblob = Ref(Ptr{COR_SIGNATURE}(0))
    rsigbloblen = Ref(ULONG(0))
    rcplusTypeFlag = Ref(DWORD(0))
    rvalue = Ref(UVCP_CONSTANT(0))
    rvalueLen = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.GetFieldProps)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        fd::mdFieldDef,
        rclass::Ref{mdTypeDef},
        fieldname::Ref{Cwchar_t},
        length(fieldname)::ULONG,
        rfieldnameLen::Ref{ULONG},
        rattrs::Ref{DWORD},
        rpsigblob::Ref{Ptr{COR_SIGNATURE}},
        rsigbloblen::Ref{ULONG},
        rcplusTypeFlag::Ref{DWORD},
        rvalue::Ref{UVCP_CONSTANT},
        rvalueLen::Ref{ULONG}
        )::HRESULT
    if res == S_OK
        name = transcode(String, fieldname[begin:rfieldnameLen[]-1])
        sigblob = unsafe_wrap(Vector{COR_SIGNATURE}, rpsigblob[], rsigbloblen[])
        return (name=name, sigblob=sigblob, cptype=rcplusTypeFlag[])
    end
    
    return ("", UInt8[], DWORD(0))
end

function enumFields(mdi::COMWrapper{IMetaDataImport}, tok::mdTypeDef)::Vector{mdFieldDef}
    rEnum = Ref(HCORENUM(0))
    fields = zeros(mdFieldDef, DEFAULT_BUFFER_LEN)
    rcTokens = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.EnumFields)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        rEnum::Ref{HCORENUM},
        tok::mdTypeDef,
        fields::Ref{mdFieldDef},
        length(fields)::ULONG,
        rcTokens::Ref{ULONG}
        )::HRESULT
    if res == S_OK
        return fields[begin:rcTokens[]]
    end
    throw(HRESULT_FAILED(res))
end

@enum SIG_KIND begin
    SIG_KIND_DEFAULT = 0x0 
    SIG_KIND_C = 0x1 
    SIG_KIND_STDCALL = 0x2 
    SIG_KIND_THISCALL = 0x3 
    SIG_KIND_FASTCALL = 0x4 
    SIG_KIND_VARARG = 0x5 
    SIG_KIND_FIELD = 0x06 
    SIG_KIND_HASTHIS = 0x20 
    SIG_KIND_EXPLICITTHIS = 0x40 
end

@enum ELEMENT_TYPE::Byte begin
    ELEMENT_TYPE_END = 0x00
    ELEMENT_TYPE_VOID = 0x01
    ELEMENT_TYPE_BOOLEAN = 0x02
    ELEMENT_TYPE_CHAR = 0x03
    ELEMENT_TYPE_I1 = 0x04
    ELEMENT_TYPE_U1 = 0x05
    ELEMENT_TYPE_I2 = 0x06
    ELEMENT_TYPE_U2 = 0x07
    ELEMENT_TYPE_I4 = 0x08
    ELEMENT_TYPE_U4 = 0x09
    ELEMENT_TYPE_I8 = 0x0a
    ELEMENT_TYPE_U8 = 0x0b
    ELEMENT_TYPE_R4 = 0x0c
    ELEMENT_TYPE_R8 = 0x0d
    ELEMENT_TYPE_STRING = 0x0e
    ELEMENT_TYPE_PTR = 0x0f # Followed by type
    ELEMENT_TYPE_BYREF = 0x10 # Followed by type
    ELEMENT_TYPE_VALUETYPE = 0x11 # Followed by TypeDef or TypeRef token
    ELEMENT_TYPE_CLASS = 0x12 # Followed by TypeDef or TypeRef token
    ELEMENT_TYPE_VAR = 0x13 # Generic parameter in a generic type definition, represented as number (compressed unsigned integer)
    ELEMENT_TYPE_ARRAY = 0x14 # type rank boundsCount bound1 … loCount lo1 …
    ELEMENT_TYPE_GENERICINST = 0x15 # Generic type instantiation. Followed by type type-arg-count type-1 ... type-n
    ELEMENT_TYPE_TYPEDBYREF = 0x16
    ELEMENT_TYPE_I = 0x18 # System.IntPtr
    # TBD
end

function paramType(paramblob::Vector{COR_SIGNATURE})
    len = 1
    et::ELEMENT_TYPE = ELEMENT_TYPE(paramblob[1])
    type::mdToken = mdTokenNil
    isPtr::Bool = false
    isValueType::Bool = false
    
    if et == ELEMENT_TYPE_PTR
        isPtr = true
        subet = ELEMENT_TYPE(paramblob[2])
        if subet == ELEMENT_TYPE_VALUETYPE
            isValueType = true
            type, len = uncompressToken(paramblob[3:end])
        else
            type, len = uncompress(paramblob[2:end])
        end
    elseif et == ELEMENT_TYPE_VALUETYPE
        isValueType = true
        type, len = uncompressToken(paramblob[2:end])
    elseif et == ELEMENT_TYPE_CLASS
        type, len = uncompressToken(paramblob[2:end])
    else
        type = paramblob[1]
        len = 1
    end

    return (type=type, len=len, isPtr=isPtr, isValueType=isValueType)
end

function methodSigblobtoTypeInfo(sigblob::Vector{COR_SIGNATURE})
    sk::SIG_KIND = SIG_KIND(sigblob[1] & 0xF)
    # et::ELEMENT_TYPE = ELEMENT_TYPE_VOID
    # typeToken::mdToken = mdTokenNil
    isPtr::Bool = false
    isValueType::Bool = false
    paramCount::Int = 0
    i = 2

    # NB Assumes c-api
    
    paramCount, len = uncompress(sigblob[i:end])
    i += len

    rt, len = paramType(sigblob[i:end])
    i += len

    # TODO loop over param count
    pt, len, isPtr, isValueType = paramType(sigblob[i:end])

    return (sigkind=sk, retType=rt, paramType=pt, isPtr=isPtr, isValueType=isValueType)
end

function fieldSigblobtoTypeInfo(sigblob::Vector{COR_SIGNATURE})
    if SIG_KIND(sigblob[1]) == SIG_KIND_FIELD
        return paramType(sigblob[2:end])
    end
    throw("bad signature")
end

# function methodDefSig(sigblob::Vector{COR_SIGNATURE})
#     # The first byte of the Signature holds bits for HASTHIS, EXPLICITTHIS and calling convention (DEFAULT, VARARG, or GENERIC)
#     i = 1
#     paramCount, len =  uncompress(sigblob[i])
#     i += len
#     retTyep, len = uncompress(sigblob[i])

#     # TBD params
# end

function enumMembers(mdi::COMWrapper{IMetaDataImport}, tok::mdTypeDef)::Vector{mdToken}
    rEnum = Ref(HCORENUM(0))
    members = zeros(mdToken, DEFAULT_BUFFER_LEN)
    rcMembers = Ref(ULONG(0))
    res = @ccall $(mdi.vtbl.EnumMembers)(
        mdi.punk::Ref{COMObject{IMetaDataImport}}, 
        rEnum::Ref{HCORENUM},
        tok::mdTypeDef,
        members::Ref{mdToken},
        length(members)::ULONG,
        rcMembers::Ref{ULONG}
        )::HRESULT
    if res == S_OK
        return members[begin:rcMembers[]]
    end
    throw(HRESULT_FAILED(res))
end