# spvreflect.c3l

C3 binding for [SPIRV-Reflect](https://github.com/KhronosGroup/SPIRV-Reflect) —
SPIR-V reflection (descriptor bindings, sets, types, entry points,
push-constant blocks). Vendors static libraries for linux-x64 and windows-x64.

## Vendored library version

Both libraries are built from tag **vulkan-sdk-1.4.341.0** and must stay on one
tag: push-block `size` semantics changed at vulkan-sdk-1.4.304 (padded before,
tight after), and consumers validate against the reported sizes.

```sh
git clone --depth 1 --branch vulkan-sdk-1.4.341.0 https://github.com/KhronosGroup/SPIRV-Reflect
cd SPIRV-Reflect
gcc -O2 -DNDEBUG -c spirv_reflect.c -o spirv_reflect.o        # linux-x64
ar rcs libspvreflect.a spirv_reflect.o
x86_64-w64-mingw32-gcc -O2 -DNDEBUG -c spirv_reflect.c -o spirv_reflect_win.o   # windows-x64
x86_64-w64-mingw32-ar rcs spvreflect.lib spirv_reflect_win.o
```

`-DNDEBUG` matters on windows: mingw's `assert` pulls `__imp__assert`, which
ucrt does not export.

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
