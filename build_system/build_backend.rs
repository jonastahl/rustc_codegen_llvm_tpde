use std::{env, fs};
use std::path::PathBuf;

use crate::path::{Dirs, RelPath};
use crate::rustc_info::{get_default_sysroot, get_file_name};
use crate::shared_utils::{rustflags_from_config_files, rustflags_from_env, rustflags_to_cmd_env};
use crate::utils::{CargoProject, Compiler, LogGroup};

static CG_TPDE: CargoProject = CargoProject::new(&RelPath::source("."), "cg_tpde");

/// Where scripts/build_llvm.sh installs the LLVM built from deps/llvm.
static LLVM_INSTALL: RelPath = RelPath::source("build/llvm");

pub(crate) fn build_backend(
    dirs: &Dirs,
    bootstrap_host_compiler: &Compiler,
    debug: bool,
) -> PathBuf {
    let _group = LogGroup::guard("Build backend");

    let mut cmd = CG_TPDE.build(bootstrap_host_compiler, dirs, "rustc_codegen_tpde");

    let mut rustflags = rustflags_from_env("RUSTFLAGS");
    rustflags
        .extend(rustflags_from_config_files(&bootstrap_host_compiler.triple, &dirs.source_dir));
    rustflags.push("-Zallow-features=extern_types,file_buffered,impl_trait_in_assoc_type,iter_intersperse,macro_derive,once_cell_try,rustc_private,trim_prefix_suffix,try_blocks".to_owned());
    rustflags.extend(ambiguous_sysroot_externs(bootstrap_host_compiler));
    rustflags_to_cmd_env(&mut cmd, "RUSTFLAGS", &rustflags);

    if env::var_os("LLVM_CONFIG").is_none() {
        let llvm_config = LLVM_INSTALL.to_path(dirs).join("bin/llvm-config");
        if !llvm_config.exists() {
            eprintln!(
                "{} not found. Run the build through y.sh, run scripts/build_llvm.sh or set LLVM_CONFIG.",
                llvm_config.display()
            );
            std::process::exit(1);
        }
        cmd.env("LLVM_CONFIG", llvm_config);
    }

    if env::var("CG_TPDE_EXPENSIVE_CHECKS").is_ok() {
        cmd.env("CARGO_PROFILE_RELEASE_DEBUG_ASSERTIONS", "true");
        cmd.env("CARGO_PROFILE_RELEASE_OVERFLOW_CHECKS", "true");
    }

    if !debug {
        cmd.arg("--release");
    }

    eprintln!("[BUILD] rustc_codegen_tpde");
    crate::utils::spawn_and_wait(cmd);

    CG_TPDE
        .target_dir(dirs)
        .join(&bootstrap_host_compiler.triple)
        .join(if debug { "debug" } else { "release" })
        .join(get_file_name(&bootstrap_host_compiler.rustc, "rustc_codegen_tpde", "dylib"))
}

/// The sysroot contains two builds of some crates: the ones that std was built against (with an
/// rlib) and the ones that the compiler crates from rustc-dev were built against (rmeta only).
/// rustc refuses to pick one for a plain `extern crate`, so explicitly select the latter, as
/// the types must match those used by the rustc_* crates.
fn ambiguous_sysroot_externs(compiler: &Compiler) -> Vec<String> {
    let lib_dir = get_default_sysroot(&compiler.rustc)
        .join("lib/rustlib")
        .join(&compiler.triple)
        .join("lib");
    let mut flags = Vec::new();
    for krate in ["gimli", "libc", "object", "rustc_demangle"] {
        let prefix = format!("lib{krate}-");
        let mut candidates = Vec::new();
        for entry in fs::read_dir(&lib_dir).unwrap().map(|e| e.unwrap().path()) {
            let name = entry.file_name().unwrap().to_string_lossy().into_owned();
            if name.starts_with(&prefix) && name.ends_with(".rmeta") {
                candidates.push(entry);
            }
        }
        // Only an rmeta without an accompanying rlib belongs to the compiler crates.
        candidates.retain(|rmeta| !rmeta.with_extension("rlib").exists());
        if let [rmeta] = candidates.as_slice() {
            flags.push("--extern".to_owned());
            flags.push(format!("{krate}={}", rmeta.display()));
        }
    }
    flags
}
