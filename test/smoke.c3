module smoke;

import spvreflect;

const char[*] COMPUTE_SPIRV = $embed("root.comp.spv");

fn void main() {
    ulong[spvreflect::SHADER_MODULE_SIZE / 8] module_storage;
    spvreflect::ShaderModule* reflect_module = (spvreflect::ShaderModule*)&module_storage;
    spvreflect::ReflectResult result =
        spvreflect::create_shader_module(COMPUTE_SPIRV.len, &COMPUTE_SPIRV, reflect_module);
    assert(result == spvreflect::RESULT_SUCCESS);
    reflect_module.destroy();
}
