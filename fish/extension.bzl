load(":download.bzl", "fish_register_toolchains")

def _fish_shell_impl(module_ctx):
    print("_fish_shell_impl")
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            fish_register_toolchains(toolchain.version)

_toolchain = tag_class(attrs = dict(version = attr.string()))
fish_shell = module_extension(
    implementation = _fish_shell_impl,
    tag_classes = {
        "toolchain": _toolchain,
    },
)
