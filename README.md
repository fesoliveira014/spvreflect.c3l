# spvreflect.c3l

C3 binding for [SPIRV-Reflect](https://github.com/KhronosGroup/SPIRV-Reflect) —
SPIR-V reflection (descriptor bindings, sets, types). Vendors a static
`libspvreflect.a` (Linux).

The binding is MIT-licensed; the vendored library is Apache-2.0 (see `NOTICE`).

## Use (git submodule)

```sh
git submodule add https://github.com/fesoliveira014/spvreflect.c3l lib/spvreflect.c3l
```

Then in `project.json`:

```json
"dependency-search-paths": [ "lib" ],
"dependencies": [ "spvreflect" ]
```

```c3
import spvreflect;
// ShaderModule is opaque; allocate SHADER_MODULE_SIZE bytes and cast.
char[] storage = mem::new_array(char, (sz)spvreflect::SHADER_MODULE_SIZE);
defer free(storage);
spvreflect::ShaderModule* module = (spvreflect::ShaderModule*)storage.ptr;
spvreflect::create_shader_module((usz)spirv.len, spirv.ptr, module);
defer module.destroy();
```
