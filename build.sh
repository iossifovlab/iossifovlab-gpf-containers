#!/bin/bash

shopt -s extdebug
shopt -s inherit_errexit
set -e

. build-scripts/loader-extended.bash

loader_addpath build-scripts/

# shellcheck source=build-scripts/libmain.sh
include libmain.sh
# shellcheck source=build-scripts/libbuild.sh
include libbuild.sh
# shellcheck source=build-scripts/libdefer.sh
include libdefer.sh
# shellcheck source=build-scripts/liblog.sh
include liblog.sh
# shellcheck source=build-scripts/libopt.sh
include libopt.sh

function main() {
  local -A options
  libopt_parse options \
    stage:all preset:fast clobber:allow_if_matching_values build_no:0 generate_jenkins_init:no expose_ports:no -- "$@"

  local preset="${options["preset"]}"
  local stage="${options["stage"]}"
  local clobber="${options["clobber"]}"
  local build_no="${options["build_no"]}"
  local generate_jenkins_init="${options["generate_jenkins_init"]}"
  local expose_ports="${options["expose_ports"]}"

  libmain_init iossifovlab.iossifovlab-gpf-containers sgc
  libmain_init_build_env \
    clobber:"$clobber" preset:"$preset" build_no:"$build_no" \
    generate_jenkins_init:"$generate_jenkins_init" expose_ports:"$expose_ports" \
    iossifovlab.gpf iossifovlab.gpfjs
  libmain_save_build_env_on_exit
  libbuild_init stage:"$stage" registry.seqpipe.org

  defer_ret build_run_ctx_reset_all_persistent
  defer_ret build_run_ctx_reset

  build_stage "Cleanup"
  {
    build_run_ctx_init "container" "ubuntu:20.04"
    defer_ret build_run_ctx_reset
    build_run rm -rf \
      ./iossifovlab-gpf/gpf
  }

  local gpf_package_image
  gpf_package_image=$(e docker_data_img_gpf_package)

  local gpfjs_package_image
  gpfjs_package_image=$(e docker_data_img_gpfjs_package)

  local gpf_tag
  gpf_tag=$(e gpf_git_describe)

  local public_image_tag
  public_image_tag="$gpf_tag-$build-no"

  build_stage "Build iossifovlab-http"
  {
    build_docker_image_create "iossifovlab-http" "iossifovlab-http" \
      "iossifovlab-http/Dockerfile" "latest" "iossifovlab"

    build_docker_image_push "iossifovlab-http" "iossifovlab/iossifovlab-http:$public_image_tag"
  }

  build_stage "Build iossifovlab-gpf"
  {
    # copy gpf package
    build_run_local mkdir -p ./iossifovlab-gpf/gpf
    build_docker_image_cp_from "$gpf_package_image" ./iossifovlab-gpf/ /gpf

    build_docker_image_create "iossifovlab-gpf" "iossifovlab-gpf" \
      "iossifovlab-gpf/Dockerfile" "no_tag"
    
    build_docker_image_push "iossifovlab-gpf" "iossifovlab/iossifovlab-gpf:$public_image_tag"
  }

  build_stage "Build gpf-full"
  {

    # copy gpfjs package
    build_run_local mkdir -p ./iossifovlab-gpf-full/gpfjs
    build_docker_image_cp_from "$gpfjs_package_image" ./iossifovlab-gpf-full/ /gpfjs

    build_run_ctx_init "local"
    defer_ret build_run_ctx_reset

    build_run cd iossifovlab-gpf-full

    local docker_img_iossifovlab_gpf_tag
    docker_img_iossifovlab_gpf_tag=$(e docker_img_iossifovlab_gpf_tag)

    build_docker_image_create "iossifovlab-gpf-full" "iossifovlab-gpf-full" \
      ./iossifovlab-gpf-full/Dockerfile "${docker_img_iossifovlab_gpf_tag}" "iossifovlab"

    build_docker_image_push "iossifovlab-gpf-full" "iossifovlab/iossifovlab-gpf-full:$public_image_tag"
  }
}

main "$@"
