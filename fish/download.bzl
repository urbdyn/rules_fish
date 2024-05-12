"""Fish download helper functions. WIP.

Reference go_toolchain and llvm for example:

https://github.com/bazelbuild/rules_go/blob/c0ef535977f9fd2d9a67243552cd04da285ab629/go/private/sdk.bzl#L56
https://github.com/bazel-contrib/toolchains_llvm/blob/96b5eee584450963408be7c33b695ae457ad93e8/toolchain/deps.bzl 
"""

def _fish_multiple_toolchains_impl(repository_ctx):
    print("_fish_multiple_toolchains_impl")

    _pcre2_download(
        repository_ctx,
        [
            "https://mirror.bazel.build/github.com/PCRE2Project/pcre2/releases/download/pcre2-10.43/pcre2-10.43.tar.gz",
            "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.43/pcre2-10.43.tar.gz",
        ],
        "889d16be5abb8d05400b33c25e151638b8d4bac0e2d9c76e9d6923118ae8a34e",
        "10.43",
    )

    _fish_download_impl(repository_ctx)
    repository_ctx.file(
        "BUILD.bazel",
        fish_toolchains_build_file_content(
            repository_ctx,
            versions = repository_ctx.attr.versions,
        ),
        executable = False,
    )

fish_multiple_toolchains = repository_rule(
    implementation = _fish_multiple_toolchains_impl,
    attrs = {
        "versions": attr.string_list(mandatory = True),
        # TODO: there IS a mirror available from fishshell.com: https://github.com/fish-shell/fish-shell?tab=readme-ov-file#building-from-source
        "urls": attr.string_list(default = ["https://github.com/fish-shell/fish-shell/releases/download/{version}/fish-{version}.tar.xz"]),
        "sha256": attr.string(default = "614c9f5643cd0799df391395fa6bbc3649427bb839722ce3b114d3bbc1a3b250"),
        "_fish_build_file": attr.label(
            # TODO: this label will break
            default = Label("//fish:BUILD.fish.bazel"),
        ),
    },
)

def _pcre2_download(repository_ctx, urls, sha256, version):
    print("_pcre2_download")
    repository_ctx.report_progress("Downloading and extracting pcre2")

    repository_ctx.download_and_extract(
        url = urls,
        sha256 = sha256,
        output = "pcre2",
        stripPrefix = "pcre2-{}".format(version),
    )

    repository_ctx.template(
        "pcre2/BUILD.bazel",
        # TODO: this label will break
        repository_ctx.path(Label("//fish:BUILD.pcre2.bazel")),
        executable = False,
        substitutions = {
            # TODO: this will need to be configurable based on ...
            "{PCRE2_CODE_UNIT_WIDTH}": "32",
        },
    )

def _fish_download_impl(repository_ctx):
    print("_fish_download_impl")
    version = repository_ctx.attr.versions[0]
    print(version)

    # TODO: we could do better with string formatting here ...
    _remote_fish(repository_ctx, [url.format(version = version) for url in repository_ctx.attr.urls], repository_ctx.attr.sha256)

    # TODO: remove .format()?
    repository_ctx.template(
        "fish/BUILD.bazel".format(version = version),
        repository_ctx.path(repository_ctx.attr._fish_build_file),
        executable = False,
        substitutions = {
            "{version}": version,
        },
    )

    # TODO: this logic needs improved
    if not repository_ctx.attr.versions:
        # Returning this makes Bazel print a message that 'version' must be specified for a reproducible build.
        return {
            "version": version,
        }
    return None

def _remote_fish(repository_ctx, urls, sha256):
    print("_remote_fish")
    if len(urls) == 0:
        fail("no urls specified")

    repository_ctx.report_progress("Downloading and extracting Fish toolchain")

    repository_ctx.download_and_extract(
        url = urls,
        sha256 = sha256,
        output = "fish",
        stripPrefix = "fish-3.7.1",
    )

def fish_download_release(name, register_toolchains = True, **kwargs):
    print("fish_download_release")

    _fish_toolchains(
        name = name + "_toolchains",
        version = kwargs.get("version"),
    )

# TODO: re-sort this madness in the end
def _fish_toolchains(name, version):
    print("_fish_toolchains")

    print("call repository_rule 'fish_multiple_toolchains' with name = {}, versions = [{}]".format(name, version))
    fish_multiple_toolchains(name = name, versions = [version])

def fish_toolchains_single_definition(repository_ctx, version):
    print("fish_toolchains_single_definition")

    chunks = []
    loads = []

    loads.append("""load(":toolchain.bzl", "fish_toolchain")""")

    chunks.append("""toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

fish_toolchain(
    name = "fish_linux",
)
""")

    chunks.append("""toolchain(
    name = "fish_linux_toolchain",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":fish_linux",
    toolchain_type = ":toolchain_type",
    # toolchain_type = "//fish:toolchain_type",
)
""")
    return struct(
        loads = loads,
        chunks = chunks,
    )

def fish_toolchains_build_file_content(repository_ctx, versions):
    print("fish_toolchains_build_file_content")

    repository_ctx.file(
        "toolchain.bzl",
        # TODO: this label will break
        repository_ctx.read(Label("//fish:toolchain.bzl")),
        executable = False,
    )

    loads = [
        """""",
    ]
    chunks = [
        """package(default_visibility = ["//visibility:public"])""",
    ]

    for i in range(len(versions)):
        definition = fish_toolchains_single_definition(
            repository_ctx,
            version = versions[i],
        )
        loads.extend(definition.loads)
        chunks.extend(definition.chunks)

    return "\n".join(loads + chunks)

def fish_register_toolchains(version = None):
    print("fish_register_toolchains")
    fish_download_release("fish", register_toolchains = True, version = version)
