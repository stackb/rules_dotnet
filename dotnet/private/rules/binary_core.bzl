load(
    "@io_bazel_rules_dotnet//dotnet/private:context.bzl",
    "dotnet_context",
)

load(
    "@io_bazel_rules_dotnet//dotnet/private:providers.bzl",
    "DotnetLibrary",
    "DotnetResource",
)

load(
    "@io_bazel_rules_dotnet//dotnet/private:rules/launcher_gen.bzl",
    "dotnet_launcher_gen",
)

def _core_binary_impl(ctx):
  """dotnet_binary_impl emits actions for compiling dotnet executable assembly."""
  dotnet = dotnet_context(ctx)
  name = ctx.label.name
 
  executable = dotnet.binary(dotnet,
      name = name,
      srcs = ctx.attr.srcs,
      deps = ctx.attr.deps,
      resources = ctx.attr.resources,
      out = ctx.attr.out,
      defines = ctx.attr.defines,
      unsafe = ctx.attr.unsafe,
      data = ctx.attr.data,
  )


  return [
      DefaultInfo(
          files = depset([executable.result]),
          runfiles = ctx.runfiles(files = ctx.attr._native_deps.files.to_list() + [dotnet.runner], transitive_files = executable.runfiles),
          executable = executable.result,
      ),
  ]
  
_core_binary = rule(
    _core_binary_impl,
    attrs = {
        "deps": attr.label_list(providers=[DotnetLibrary]),
        "resources": attr.label_list(providers=[DotnetResource]),
        "srcs": attr.label_list(allow_files = FileType([".cs"])),        
        "out": attr.string(),
        "defines": attr.string_list(),
        "unsafe": attr.bool(default = False),
        "data": attr.label_list(allow_files = True),        
        "_dotnet_context_data": attr.label(default = Label("@io_bazel_rules_dotnet//:core_context_data")),
        "_native_deps": attr.label(default = Label("@core_sdk//:native_deps"))
    },
    toolchains = ["@io_bazel_rules_dotnet//dotnet:toolchain_core"],
    executable = True,
)

def core_binary(name, srcs, deps = [], defines = None, out = None, resources = None, data = None):
    _core_binary(name = "%s_exe" % name, deps = deps, srcs = srcs, out = out, defines = defines, resources = resources, data = data)
    exe = ":%s_exe" % name
    dotnet_launcher_gen(name = "%s_launcher" % name, exe = exe)

    native.cc_binary(
        name=name, 
        srcs = [":%s_launcher" % name],
        deps = ["@io_bazel_rules_dotnet//dotnet/tools/runner_core", "@io_bazel_rules_dotnet//dotnet/tools/common"],
        data = [exe],
    )