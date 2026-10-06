# spvreflect.c3l

C3 binding for [SPIRV-Reflect](https://github.com/KhronosGroup/SPIRV-Reflect) —
SPIR-V reflection (descriptor bindings, sets, types, entry points,
push-constant blocks). Static libraries for linux-x64 (vendored) and windows-x64 (built in CI).

## Vendored library version

Both libraries are built from tag **vulkan-sdk-1.4.341.0** and must stay on one
tag: push-block `size` semantics changed at vulkan-sdk-1.4.304 (padded before,
tight after), and consumers validate against the reported sizes.

```sh
git clone --depth 1 --branch vulkan-sdk-1.4.341.0 https://github.com/KhronosGroup/SPIRV-Reflect
cd SPIRV-Reflect
gcc -O2 -DNDEBUG -c spirv_reflect.c -o spirv_reflect.o        # linux-x64
ar rcs libspvreflect.a spirv_reflect.o
```

```bat
rem windows-x64, from an MSVC x64 developer prompt
cl /nologo /c /O2 /MT /DNDEBUG spirv_reflect.c
lib /nologo /OUT:spvreflect.lib spirv_reflect.obj
```

`windows/spvreflect.lib` is built by the release workflow and is not committed.
`/MT` matches consumers that link the static CRT (`wincrt: static`).

The binding is MIT-licensed; the vendored library is Apache-2.0 (see `NOTICE`).

## Validate the binding

Regenerate the checked-in reflection fixture and run the C3 test:

```sh
glslc test/root.comp -o test/root.comp.spv
glslc test/shapes.comp -o test/shapes.comp.spv
c3c test unit --path test
```

Compile the layout probe against the exact pinned SPIRV-Reflect checkout for
both supported x64 ABIs:

```sh
gcc -std=c11 -I/path/to/SPIRV-Reflect test/layout_probe.c -o /tmp/spvreflect-layout-linux
x86_64-w64-mingw32-gcc -std=c11 -I/path/to/SPIRV-Reflect -c test/layout_probe.c -o /tmp/spvreflect-layout-windows.o
```

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
