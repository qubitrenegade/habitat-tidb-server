pkg_name=tidb
pkg_origin=qbr
pkg_version=2.0.3
pkg_maintainer="QubitRenegade <qubitrenegade@gmail.com>"
pkg_license=("MPL-2")
pkg_source=http://download.pingcap.org/tidb-v${pkg_version}-linux-amd64.tar.gz
pkg_shasum=be725a370345504ed9dc495ec3bec1876b099eedf29486afe2e3da61b2bea038
pkg_deps=(core/bash core/glibc)
pkg_build_deps=(core/patchelf)
pkg_bin_dirs=(bin)

# pkg_exports=(
#   [client-port]=client-port
#   [peer-port]=peer-port
# )

# pkg_exposes=(client-port peer-port)

# Optional.
# pkg_svc_user="hab"
# pkg_svc_group="$pkg_svc_user"

pkg_description="TiDB - A Distributed SQL Database; https://github.com/qubitrenegade/habitat-tidb-pd-server"
pkg_upstream_url="https://github.com/pingcap/tidb"

do_clean() {
  # remove any old binaries
  build_line $(rm -rf ${HAB_CACHE_SRC_PATH}/tidb-v${pkg_version}-linux-amd64/)
  do_default_clean
}

do_prepare() {
  # the binaries are distributed together.  We'll separate them out now
  build_line $(cp -v ${HAB_CACHE_SRC_PATH}/tidb-v${pkg_version}-linux-amd64/bin/${pkg_name}* \
    ${HAB_CACHE_SRC_PATH}/$pkg_dirname)
}

do_build() {
  # Update glibc path for tidb-ctl
  attach
  patchelf --interpreter "$(pkg_path_for glibc)/lib64/ld-linux-x86-64.so.2" ./tidb-ctl
  return 0
}

do_install() {
  # iterate through all of the files in ${HAB_CACHE_SRC_PATH}/$pkg_dirname
  for i in ./${pkg_name}*; do
    install_path=${pkg_prefix}/bin/${i}
    build_line "installing ${i} to ${install_path}"
    install -D ${i} ${install_path}
  done
}
