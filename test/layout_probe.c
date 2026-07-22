#include <stddef.h>

#include "spirv_reflect.h"

_Static_assert(sizeof(SpvReflectShaderModule) == 1216,
               "SpvReflectShaderModule size changed");

_Static_assert(offsetof(SpvReflectDescriptorBinding, binding) == 16,
               "descriptor binding offset changed");
_Static_assert(offsetof(SpvReflectDescriptorBinding, set) == 24,
               "descriptor set offset changed");
_Static_assert(offsetof(SpvReflectDescriptorBinding, descriptor_type) == 28,
               "descriptor type offset changed");

_Static_assert(offsetof(SpvReflectEntryPoint, shader_stage) == 16,
               "entry-point stage offset changed");

_Static_assert(sizeof(SpvReflectBlockVariable) == 360,
               "block-variable size changed");
_Static_assert(offsetof(SpvReflectBlockVariable, offset) == 16,
               "block offset changed");
_Static_assert(offsetof(SpvReflectBlockVariable, size) == 24,
               "block size changed");
_Static_assert(offsetof(SpvReflectBlockVariable, numeric) == 36,
               "block numeric-traits offset changed");
_Static_assert(offsetof(SpvReflectBlockVariable, array) == 60,
               "block array-traits offset changed");
_Static_assert(offsetof(SpvReflectBlockVariable, member_count) == 328,
               "block member-count offset changed");
_Static_assert(offsetof(SpvReflectBlockVariable, members) == 336,
               "block members offset changed");
_Static_assert(offsetof(SpvReflectBlockVariable, type_description) == 344,
               "block type-description offset changed");

_Static_assert(offsetof(SpvReflectNumericTraits, scalar.width) == 0,
               "scalar width offset changed");
_Static_assert(offsetof(SpvReflectNumericTraits, scalar.signedness) == 4,
               "scalar signedness offset changed");
_Static_assert(offsetof(SpvReflectNumericTraits, vector.component_count) == 8,
               "vector component-count offset changed");
_Static_assert(offsetof(SpvReflectNumericTraits, matrix.column_count) == 12,
               "matrix column-count offset changed");
_Static_assert(offsetof(SpvReflectNumericTraits, matrix.row_count) == 16,
               "matrix row-count offset changed");
_Static_assert(offsetof(SpvReflectArrayTraits, dims_count) == 0,
               "array dimension-count offset changed");
_Static_assert(offsetof(SpvReflectTypeDescription, type_flags) == 28,
               "type-flags offset changed");

int main(void) {
    return 0;
}
