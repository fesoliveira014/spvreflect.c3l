module spvreflect;

// SPIRV-Reflect (Khronos), vendored from the Vulkan SDK
// (include/SPIRV-Reflect/spirv_reflect.{h,c}).
//
// Bound surface: build a reflect module from SPIR-V bytes, enumerate
// descriptor bindings (index/set/type), look up entry points (existence +
// stage), enumerate push-constant blocks (offset/size), destroy the module.

// SpvReflectShaderModule is a large value struct (1216 bytes on linux-x64,
// 1200 bytes on windows-x64 — both measured with a C probe printing sizeof
// against each platform's SDK header). The C API only ever takes/returns it by
// pointer, so the engine treats it as opaque sized storage: allocate a
// SHADER_MODULE_SIZE byte blob and pass its pointer. SHADER_MODULE_SIZE is the
// MAX across platforms (1216) so the blob is never under-allocated; the library
// writes its own platform sizeof (<= 1216) into it, leaving any slack unused.
// non-inline: SpvReflectShaderModule is a 1200-1216-byte value struct, not a
// pointer handle — inline void* would misrepresent the ABI (8 bytes vs 1216).
typedef ShaderModule     = void;
const usz SHADER_MODULE_SIZE = 1216;

// non-inline: read by verified-offset accessors + the enumerate API hands back
// an array of pointers (SpvReflectDescriptorBinding**), so the bare-void +
// explicit-* form keeps the pointer levels unambiguous.
typedef DescriptorBinding = void;

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

// Verified byte offsets of the three read fields within
// SpvReflectDescriptorBinding (measured with offsetof against the SDK header;
// each is a 4-byte uint32_t): binding=16, set=24, descriptor_type=28.
const usz OFFSET_BINDING         = 16;
const usz OFFSET_SET             = 24;
const usz OFFSET_DESCRIPTOR_TYPE = 28;

extern fn ReflectResult create_shader_module(usz size, void* code, ShaderModule* out_module) @cname("spvReflectCreateShaderModule");
extern fn ReflectResult ShaderModule.enumerate_descriptor_bindings(&self, uint* count, DescriptorBinding** bindings) @cname("spvReflectEnumerateDescriptorBindings");
extern fn void          ShaderModule.destroy(&self) @cname("spvReflectDestroyShaderModule");

fn uint DescriptorBinding.binding_index(&self) {
    return *(uint*)((char*)self + OFFSET_BINDING);
}

fn uint DescriptorBinding.set_index(&self) {
    return *(uint*)((char*)self + OFFSET_SET);
}

fn DescriptorType DescriptorBinding.descriptor_type(&self) {
    return *(DescriptorType*)((char*)self + OFFSET_DESCRIPTOR_TYPE);
}

// Entry-point and push-constant reflection. Both structs are value structs
// handed back by pointer; same opaque + verified-offset idiom as
// DescriptorBinding.
typedef EntryPoint    = void;
typedef BlockVariable = void;

// SpvReflectShaderStageFlagBits values (Vulkan stage bits; confirmed against
// the SDK header via a C probe: VERTEX=0x1, FRAGMENT=0x10, COMPUTE=0x20).
constdef ShaderStage : uint
{
    SHADER_STAGE_VERTEX   = 0x1,
    SHADER_STAGE_FRAGMENT = 0x10,
    SHADER_STAGE_COMPUTE  = 0x20,
}

// Verified byte offsets (offsetof C probe against the SDK header, linux-x64).
// Only 8-byte pointers and 4-byte uint32 fields precede the read members —
// identical layout under the MS ABI, so windows-x64 offsets match.
// SpvReflectEntryPoint: name=0 (const char*), shader_stage=16 (uint32_t).
// SpvReflectBlockVariable: offset=16, size=24 (both uint32_t, bytes).
const usz OFFSET_ENTRY_POINT_STAGE = 16;
const usz OFFSET_BLOCK_OFFSET      = 16;
const usz OFFSET_BLOCK_SIZE        = 24;

<* Null when no entry point matches `name`. *>
extern fn EntryPoint* ShaderModule.get_entry_point(&self, ZString name) @cname("spvReflectGetEntryPoint");
extern fn ReflectResult ShaderModule.enumerate_push_constant_blocks(&self, uint* count, BlockVariable** blocks) @cname("spvReflectEnumeratePushConstantBlocks");

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
