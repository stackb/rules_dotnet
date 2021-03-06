load(
    "@io_bazel_rules_dotnet//dotnet/private:actions/assembly.bzl",
    "emit_assembly",
)

def emit_binary(dotnet,
    name = "",
    srcs = None,
    deps = None,
    resources = None,
    out = None,
    defines = None,
    unsafe = False):

  return emit_assembly(
    dotnet = dotnet,
    name = name,
    srcs = srcs,
    deps = deps,
    resources = resources,
    out = out,
    executable = True,
    defines = defines,
    unsafe = unsafe,
  )
