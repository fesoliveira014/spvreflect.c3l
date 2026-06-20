module spvreflect;

// SPIRV-Reflect (Khronos), vendored from the Vulkan SDK
// (include/SPIRV-Reflect/spirv_reflect.{h,c}).
//
// Only the surface needed to enumerate set-0 descriptor bindings is bound:
// build a reflect module from SPIR-V bytes, enumerate descriptor bindings,
// read each binding's index/set/descriptor_type, and destroy the module.

// SpvReflectShaderModule is a large value struct (1216 bytes on x86_64,
// measured with a C probe printing sizeof against the SDK header). The C API
// only ever takes/returns it by pointer, so the engine treats it as opaque
// sized storage: allocate a SHADER_MODULE_SIZE byte blob and pass its pointer.
// non-inline: SpvReflectShaderModule is a 1216-byte value struct, not a pointer
// handle — inline void* would misrepresent the ABI (8 bytes vs 1216).
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
