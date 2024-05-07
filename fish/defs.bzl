def _fish_binary_impl(ctx):
    # TODO: clean up this function - provide doc comments?
    toolchain_info = ctx.toolchains[Label("@fish_toolchains//:toolchain_type")].fishinfo

    src = ctx.attr.srcs[0].files.to_list()[0]
    output_file = ctx.actions.declare_file(ctx.label.name)

    fish_bin_root_path = str(toolchain_info.fish_binary[DefaultInfo].files.to_list()[0].root.path)
    fish_bin_path = str(toolchain_info.fish_binary[DefaultInfo].files.to_list()[0].path)

    # TODO: this works, but don't understand the _main repo mapping. Where does this come from?
    fish_runfile_string = fish_bin_path.replace(fish_bin_root_path, "_main")

    ctx.actions.expand_template(
        template = ctx.file._template,
        output = output_file,
        substitutions = {
            "{SRCS}": src.path,
            "{FISH}": fish_runfile_string,
        },
    )

    executable = output_file
    deps = [executable]

    bazel_fish_deps = [
        ctx.file._runfiles_bash,
        ctx.file._rlocation_bash,
        ctx.file._bazel_fish,
    ]

    runfiles_list = ctx.files.data + ctx.files.deps
    runfiles_list = runfiles_list + [src]
    runfiles_list = runfiles_list + bazel_fish_deps
    runfiles_list = runfiles_list + toolchain_info.fish_binary[DefaultInfo].files.to_list()
    runfiles_list = runfiles_list + toolchain_info.fish[DefaultInfo].files.to_list()
    runfiles = ctx.runfiles(files = runfiles_list)

    transitive_runfiles = []
    for runfiles_attr in (
        ctx.attr.srcs,
        ctx.attr.deps,
        ctx.attr.data,
    ):
        for target in runfiles_attr:
            transitive_runfiles.append(target[DefaultInfo].default_runfiles)

    runfiles = runfiles.merge_all(transitive_runfiles)

    return [DefaultInfo(
        files = depset(deps),
        runfiles = runfiles,
        executable = executable,
    )]

fish_binary = rule(
    implementation = _fish_binary_impl,
    executable = True,
    attrs = {
        # TODO: exactly one file - sh_binary calls this a singleton list.
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "data": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),  # TODO: enforce fish files and link these?
        "_template": attr.label(
            default = ":fish_wrapper.sh",
            allow_single_file = True,
        ),
        "_runfiles_bash": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
            allow_single_file = True,
        ),
        "_rlocation_bash": attr.label(
            default = ":rlocation.sh",
            allow_single_file = True,
        ),
        "_bazel_fish": attr.label(
            default = ":bazel.fish",
            allow_single_file = True,
        ),
    },
    toolchains = [str(Label("@fish_toolchains//:toolchain_type"))],
)
