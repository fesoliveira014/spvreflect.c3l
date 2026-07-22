module spvreflect;

// SPIRV-Reflect (Khronos), vendored at tag vulkan-sdk-1.4.341.0 for BOTH
// platforms (gcc/mingw -O2 -DNDEBUG; see README for the exact build commands).
// Both libs must come from the same tag: push-block `size` semantics changed
// at vulkan-sdk-1.4.304 (tight vs padded), which consumers validate against.
//
// Bound surface: build a reflect module from SPIR-V bytes, enumerate
// descriptor bindings (index/set/type), look up entry points (existence +
// stage), enumerate push-constant blocks and their member shapes, destroy the
// module.

// SpvReflectShaderModule is a large value struct (1216 bytes on both x64
// platforms at the pinned tag, measured with a C offsetof/sizeof probe). The C
// API only ever takes/returns it by pointer, so the engine treats it as opaque
// sized storage: allocate a SHADER_MODULE_SIZE byte blob and pass its pointer.
// non-inline: a 1216-byte value struct, not a pointer handle — inline void*
// would misrepresent the ABI.
typedef ShaderModule     = void;

// non-inline: read by verified-offset accessors + the enumerate API hands back
// an array of pointers (SpvReflectDescriptorBinding**), so the bare-void +
// explicit-* form keeps the pointer levels unambiguous.
typedef DescriptorBinding = void;

// Entry-point and push-constant reflection. These are value structs handed
// back by pointer; use the same opaque + verified-offset idiom.
typedef EntryPoint      = void;
typedef BlockVariable   = void;
typedef TypeDescription = void;

const usz SHADER_MODULE_SIZE = 1216;

// Verified byte offsets of the three read fields within
// SpvReflectDescriptorBinding (measured with offsetof against the SDK header;
// each is a 4-byte uint32_t): binding=16, set=24, descriptor_type=28.
const usz OFFSET_BINDING         = 16;
const usz OFFSET_SET             = 24;
const usz OFFSET_DESCRIPTOR_TYPE = 28;

// Verified byte offsets from C probes against the SDK header on linux-x64 and
// windows-x64.
// SpvReflectEntryPoint: name=0 (const char*), shader_stage=16 (uint32_t).
// SpvReflectBlockVariable: offset=16, size=24 (both uint32_t, bytes).
const usz BLOCK_VARIABLE_SIZE             = 360;
const usz OFFSET_ENTRY_POINT_STAGE        = 16;
const usz OFFSET_BLOCK_OFFSET             = 16;
const usz OFFSET_BLOCK_SIZE               = 24;
const usz OFFSET_BLOCK_NUMERIC            = 36;
const usz OFFSET_BLOCK_ARRAY              = 60;
const usz OFFSET_BLOCK_MEMBER_COUNT       = 328;
const usz OFFSET_BLOCK_MEMBERS            = 336;
const usz OFFSET_BLOCK_TYPE_DESCRIPTION   = 344;
const usz OFFSET_NUMERIC_SCALAR_WIDTH      = 0;
const usz OFFSET_NUMERIC_SCALAR_SIGNEDNESS = 4;
const usz OFFSET_NUMERIC_VECTOR_COMPONENTS = 8;
const usz OFFSET_NUMERIC_MATRIX_COLUMNS    = 12;
const usz OFFSET_NUMERIC_MATRIX_ROWS       = 16;
const usz OFFSET_ARRAY_DIMS_COUNT          = 0;
const usz OFFSET_TYPE_DESCRIPTION_FLAGS    = 28;

// SpvReflectDescriptorType mirrors VkDescriptorType values (confirmed against
// the SDK header via a C probe: SAMPLER=0, COMBINED_IMAGE_SAMPLER=1,
// SAMPLED_IMAGE=2, STORAGE_IMAGE=3, UNIFORM_BUFFER=6, STORAGE_BUFFER=7).
constdef DescriptorType : int
{
    DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER = 1,
    DESCRIPTOR_TYPE_STORAGE_IMAGE          = 3,
    DESCRIPTOR_TYPE_UNIFORM_BUFFER         = 6,
    DESCRIPTOR_TYPE_STORAGE_BUFFER         = 7,
}

constdef ReflectResult : int
{
    RESULT_SUCCESS = 0,
}

// SpvReflectShaderStageFlagBits values (Vulkan stage bits; confirmed against
// the SDK header via a C probe: VERTEX=0x1, FRAGMENT=0x10, COMPUTE=0x20).
constdef ShaderStage : uint
{
    SHADER_STAGE_VERTEX   = 0x1,
    SHADER_STAGE_FRAGMENT = 0x10,
    SHADER_STAGE_COMPUTE  = 0x20,
}

constdef TypeFlags : uint
{
    TYPE_FLAG_UNDEFINED = 0x00000000,
    TYPE_FLAG_BOOL      = 0x00000002,
    TYPE_FLAG_INT       = 0x00000004,
    TYPE_FLAG_FLOAT     = 0x00000008,
    TYPE_FLAG_VECTOR    = 0x00000100,
    TYPE_FLAG_MATRIX    = 0x00000200,
    TYPE_FLAG_STRUCT    = 0x10000000,
    TYPE_FLAG_ARRAY     = 0x20000000,
    TYPE_FLAG_REF       = 0x40000000,
}

extern fn ReflectResult ShaderModule.enumerate_descriptor_bindings(&self, uint* count, DescriptorBinding** bindings) @cname("spvReflectEnumerateDescriptorBindings");

<* Null when no entry point matches `name`. *>
extern fn EntryPoint* ShaderModule.get_entry_point(&self, ZString name) @cname("spvReflectGetEntryPoint");
extern fn ReflectResult ShaderModule.enumerate_push_constant_blocks(&self, uint* count, BlockVariable** blocks) @cname("spvReflectEnumeratePushConstantBlocks");
extern fn ReflectResult ShaderModule.enumerate_entry_point_descriptor_bindings(&self, ZString entry_point, uint* count, DescriptorBinding** bindings) @cname("spvReflectEnumerateEntryPointDescriptorBindings");
extern fn ReflectResult ShaderModule.enumerate_entry_point_push_constant_blocks(&self, ZString entry_point, uint* count, BlockVariable** blocks) @cname("spvReflectEnumerateEntryPointPushConstantBlocks");
extern fn void ShaderModule.destroy(&self) @cname("spvReflectDestroyShaderModule");

fn uint DescriptorBinding.binding_index(&self) {
    return *(uint*)((char*)self + OFFSET_BINDING);
}

fn uint DescriptorBinding.set_index(&self) {
    return *(uint*)((char*)self + OFFSET_SET);
}

fn DescriptorType DescriptorBinding.descriptor_type(&self) {
    return *(DescriptorType*)((char*)self + OFFSET_DESCRIPTOR_TYPE);
}

fn ShaderStage EntryPoint.stage(&self) {
    return *(ShaderStage*)((char*)self + OFFSET_ENTRY_POINT_STAGE);
}

<* Lowest member offset of the push block, in bytes. *>
fn uint BlockVariable.byte_offset(&self) {
    return *(uint*)((char*)self + OFFSET_BLOCK_OFFSET);
}

fn uint BlockVariable.byte_size(&self) {
    return *(uint*)((char*)self + OFFSET_BLOCK_SIZE);
}

fn uint BlockVariable.member_count(&self) {
    return *(uint*)((char*)self + OFFSET_BLOCK_MEMBER_COUNT);
}

fn BlockVariable* BlockVariable.member(&self, uint index) {
    if (index >= self.member_count()) return null;
    BlockVariable* members =
        *(BlockVariable**)((char*)self + OFFSET_BLOCK_MEMBERS);
    if (members == null) return null;
    return (BlockVariable*)((char*)members + index * BLOCK_VARIABLE_SIZE);
}

fn TypeFlags BlockVariable.type_flags(&self) {
    TypeDescription* description =
        *(TypeDescription**)((char*)self + OFFSET_BLOCK_TYPE_DESCRIPTION);
    if (description == null) return TYPE_FLAG_UNDEFINED;
    return *(TypeFlags*)((char*)description + OFFSET_TYPE_DESCRIPTION_FLAGS);
}

fn uint BlockVariable.scalar_width(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_NUMERIC
        + OFFSET_NUMERIC_SCALAR_WIDTH);
}

fn bool BlockVariable.scalar_is_signed(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_NUMERIC
        + OFFSET_NUMERIC_SCALAR_SIGNEDNESS) != 0;
}

fn uint BlockVariable.vector_component_count(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_NUMERIC
        + OFFSET_NUMERIC_VECTOR_COMPONENTS);
}

fn uint BlockVariable.matrix_column_count(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_NUMERIC
        + OFFSET_NUMERIC_MATRIX_COLUMNS);
}

fn uint BlockVariable.matrix_row_count(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_NUMERIC
        + OFFSET_NUMERIC_MATRIX_ROWS);
}

fn uint BlockVariable.array_dimension_count(&self) {
    return *(uint*)((char*)self
        + OFFSET_BLOCK_ARRAY
        + OFFSET_ARRAY_DIMS_COUNT);
}

extern fn ReflectResult create_shader_module(usz size, void* code, ShaderModule* out_module) @cname("spvReflectCreateShaderModule");
