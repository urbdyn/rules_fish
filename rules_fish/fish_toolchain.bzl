FishInfo = provider(
    doc = "Information about how to invoke fish shell.",
    fields = ["fish", "fish_binary"],
)

def _fish_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        fishinfo = FishInfo(
            fish = ctx.attr.fish,
            fish_binary = ctx.attr.fish_binary,
        ),
    )
    return [toolchain_info]

fish_toolchain = rule(
    implementation = _fish_toolchain_impl,
    attrs = {
        "fish": attr.label(
            doc = "The build target that produces the `fish` cmake build/install outputs.",
            default = "@fish_toolchains//fish:fish",
            cfg = "exec",
        ),
        "fish_binary": attr.label(
            doc = "The build target of the fish executable file.",
            allow_single_file = True,
            default = "@fish_toolchains//fish:fish_bin",
            cfg = "exec",
        ),
    },
)
