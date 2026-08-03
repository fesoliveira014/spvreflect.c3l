module spvreflect_test;

import spvreflect;

const char[*] ROOT_SPIRV = $embed("root.comp.spv");
const char[*] SHAPES_SPIRV = $embed("shapes.comp.spv");
const char[*] RAY_QUERY_SPIRV = $embed("ray_query.comp.spv");

fn bool has_type_flag(
    spvreflect::BlockVariable* variable,
    spvreflect::TypeFlags flag,
) {
    return ((uint)variable.type_flags() & (uint)flag) != 0;
}

fn void selected_entry_point_interfaces_are_reflected() @test {
    ulong[spvreflect::SHADER_MODULE_SIZE / 8] module_storage;
    spvreflect::ShaderModule* reflect_module =
        (spvreflect::ShaderModule*)&module_storage;
    assert(spvreflect::create_shader_module(
        ROOT_SPIRV.len,
        &ROOT_SPIRV[0],
        reflect_module,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    defer reflect_module.destroy();

    spvreflect::EntryPoint* entry = reflect_module.get_entry_point("main");
    assert(entry != null);
    assert(entry.stage() == spvreflect::ShaderStage.SHADER_STAGE_COMPUTE);

    uint descriptor_count = 0;
    assert(reflect_module.enumerate_entry_point_descriptor_bindings(
        "main",
        &descriptor_count,
        null,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(descriptor_count == 1);
    spvreflect::DescriptorBinding*[1] descriptors;
    assert(reflect_module.enumerate_entry_point_descriptor_bindings(
        "main",
        &descriptor_count,
        &descriptors[0],
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(descriptors[0].binding_index() == 0);
    assert(descriptors[0].set_index() == 0);
    assert(descriptors[0].descriptor_type()
        == spvreflect::DescriptorType.DESCRIPTOR_TYPE_STORAGE_BUFFER);

    uint block_count = 0;
    assert(reflect_module.enumerate_entry_point_push_constant_blocks(
        "main",
        &block_count,
        null,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(block_count == 1);
    spvreflect::BlockVariable*[1] blocks;
    assert(reflect_module.enumerate_entry_point_push_constant_blocks(
        "main",
        &block_count,
        &blocks[0],
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);

    spvreflect::BlockVariable* block = blocks[0];
    assert(block.byte_offset() == 0);
    assert(block.byte_size() == 8);
    assert(block.member_count() == 1);

    spvreflect::BlockVariable* member = block.member(0);
    assert(member != null);
    assert(block.member(1) == null);
    assert(member.byte_offset() == 0);
    assert(member.byte_size() == 8);
    assert(has_type_flag(member, spvreflect::TypeFlags.TYPE_FLAG_INT));
    assert(member.scalar_width() == 64);
    assert(!member.scalar_is_signed());
    assert(member.vector_component_count() == 0);
    assert(member.matrix_column_count() == 0);
    assert(member.matrix_row_count() == 0);
    assert(member.array_dimension_count() == 0);
}

fn void ray_query_acceleration_structure_binding_is_reflected() @test {
    ulong[spvreflect::SHADER_MODULE_SIZE / 8] module_storage;
    spvreflect::ShaderModule* reflect_module =
        (spvreflect::ShaderModule*)&module_storage;
    assert(spvreflect::create_shader_module(
        RAY_QUERY_SPIRV.len,
        &RAY_QUERY_SPIRV[0],
        reflect_module,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    defer reflect_module.destroy();

    uint descriptor_count = 0;
    assert(reflect_module.enumerate_entry_point_descriptor_bindings(
        "main",
        &descriptor_count,
        null,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(descriptor_count == 1);
    spvreflect::DescriptorBinding*[1] descriptors;
    assert(reflect_module.enumerate_entry_point_descriptor_bindings(
        "main",
        &descriptor_count,
        &descriptors[0],
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(descriptors[0].set_index() == 0);
    assert(descriptors[0].binding_index() == 5);
    assert(descriptors[0].descriptor_type()
        == spvreflect::DescriptorType
            .DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR);
}

fn void non_scalar_member_shapes_are_reflected() @test {
    ulong[spvreflect::SHADER_MODULE_SIZE / 8] module_storage;
    spvreflect::ShaderModule* reflect_module =
        (spvreflect::ShaderModule*)&module_storage;
    assert(spvreflect::create_shader_module(
        SHAPES_SPIRV.len,
        &SHAPES_SPIRV[0],
        reflect_module,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    defer reflect_module.destroy();

    uint block_count = 0;
    assert(reflect_module.enumerate_entry_point_push_constant_blocks(
        "main",
        &block_count,
        null,
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(block_count == 1);
    spvreflect::BlockVariable*[1] blocks;
    assert(reflect_module.enumerate_entry_point_push_constant_blocks(
        "main",
        &block_count,
        &blocks[0],
    ) == spvreflect::ReflectResult.RESULT_SUCCESS);
    assert(blocks[0].member_count() == 5);

    spvreflect::BlockVariable* signed_value = blocks[0].member(0);
    assert(has_type_flag(signed_value, spvreflect::TypeFlags.TYPE_FLAG_INT));
    assert(signed_value.scalar_width() == 64);
    assert(signed_value.scalar_is_signed());

    spvreflect::BlockVariable* vector_value = blocks[0].member(1);
    assert(has_type_flag(vector_value, spvreflect::TypeFlags.TYPE_FLAG_INT));
    assert(has_type_flag(vector_value, spvreflect::TypeFlags.TYPE_FLAG_VECTOR));
    assert(vector_value.scalar_width() == 64);
    assert(vector_value.vector_component_count() == 2);

    spvreflect::BlockVariable* matrix_value = blocks[0].member(2);
    assert(has_type_flag(matrix_value, spvreflect::TypeFlags.TYPE_FLAG_FLOAT));
    assert(has_type_flag(matrix_value, spvreflect::TypeFlags.TYPE_FLAG_MATRIX));
    assert(matrix_value.scalar_width() == 32);
    assert(matrix_value.matrix_column_count() == 2);
    assert(matrix_value.matrix_row_count() == 2);

    spvreflect::BlockVariable* array_value = blocks[0].member(3);
    assert(has_type_flag(array_value, spvreflect::TypeFlags.TYPE_FLAG_INT));
    assert(has_type_flag(array_value, spvreflect::TypeFlags.TYPE_FLAG_ARRAY));
    assert(array_value.scalar_width() == 64);
    assert(array_value.array_dimension_count() == 1);

    spvreflect::BlockVariable* nested_value = blocks[0].member(4);
    assert(has_type_flag(nested_value, spvreflect::TypeFlags.TYPE_FLAG_STRUCT));
    assert(nested_value.member_count() == 1);
    spvreflect::BlockVariable* nested_member = nested_value.member(0);
    assert(nested_member != null);
    assert(has_type_flag(nested_member, spvreflect::TypeFlags.TYPE_FLAG_INT));
    assert(nested_member.scalar_width() == 32);
}
