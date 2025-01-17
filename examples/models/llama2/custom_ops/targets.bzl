load("@fbsource//xplat/executorch/build:runtime_wrapper.bzl", "runtime")

def define_common_targets():
    """Defines targets that should be shared between fbcode and xplat.

    The directory containing this targets.bzl file should also contain both
    TARGETS and BUCK files that call this function.
    """

    runtime.cxx_library(
        name = "custom_ops",
        srcs = ["op_sdpa.cpp"],
        exported_headers = ["op_sdpa.h"],
        exported_deps = [
            "//executorch/runtime/kernel:kernel_includes",
            "//executorch/kernels/portable/cpu:scalar_utils",
            "//executorch/kernels/optimized:libblas",
            "//executorch/kernels/optimized:libvec",
            "//executorch/extension/kernel_util:kernel_util",
            "//executorch/extension/parallel:thread_parallel",
            "//executorch/backends/xnnpack/threadpool:threadpool",
        ],
        compiler_flags = ["-Wno-missing-prototypes", "-Wno-global-constructors"],
        visibility = [
            "//executorch/...",
            "//executorch/examples/models/llama2/custom_ops/...",
            "@EXECUTORCH_CLIENTS",
        ],
        # @lint-ignore BUCKLINT link_whole
        link_whole = True,
        force_static = True,
    )

    runtime.cxx_library(
        name = "custom_ops_aot_lib",
        srcs = [
            "op_sdpa_aot.cpp",
        ],
        visibility = [
            "//executorch/...",
            "@EXECUTORCH_CLIENTS",
        ],
        external_deps = [
            "libtorch",
        ],
        deps = [
            ":custom_ops",
            "//executorch/extension/aten_util:aten_bridge",
        ],
    )

    runtime.python_library(
        name = "custom_ops_aot_py",
        srcs = [
            "sdpa_with_kv_cache.py",
        ],
        visibility = ["//executorch/..."],
        deps = [
            "//caffe2:torch",
        ],
    )

    runtime.cxx_test(
        name = "op_sdpa_test",
        srcs = [
            "op_sdpa_test.cpp",
        ],
        visibility = ["//executorch/..."],
        deps = [
            "//executorch/runtime/core/exec_aten:lib",
            "//executorch/runtime/core/exec_aten/testing_util:tensor_util",
            "//executorch/kernels/test:test_util",
            ":custom_ops",
        ],
    )

    runtime.cxx_test(
        name = "op_sdpa_with_kv_cache_test",
        srcs = [
            "op_sdpa_with_kv_cache_test.cpp",
        ],
        visibility = ["//executorch/..."],
        deps = [
            "//executorch/runtime/core/exec_aten:lib",
            "//executorch/runtime/core/exec_aten/testing_util:tensor_util",
            "//executorch/kernels/test:test_util",
            ":custom_ops",
        ],
    )
