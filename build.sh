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
    stage:all preset:fast clobber:allow_if_matching_values \
    build_no:0 generate_jenkins_init:no expose_ports:no -- "$@"

  local preset="${options["preset"]}"
  local stage="${options["stage"]}"
  local clobber="${options["clobber"]}"
  local build_no="${options["build_no"]}"
  local generate_jenkins_init="${options["generate_jenkins_init"]}"
  local expose_ports="${options["expose_ports"]}"

  libmain_init iossifovlab.iossifovlab-gpf-containers igc
  libmain_init_build_env clobber:"$clobber" preset:"$preset" build_no:"$build_no" \
    generate_jenkins_init:"$generate_jenkins_init" expose_ports:"$expose_ports" \
    iossifovlab.gpf-conda-packaging iossifovlab.sfari-frontpage
  libmain_save_build_env_on_exit
  libbuild_init stage:"$stage" registry.seqpipe.org

  defer_ret build_run_ctx_reset_all_persistent
  defer_ret build_run_ctx_reset

  build_stage "Cleanup"
  {
    build_run_ctx_init "container" "ubuntu:22.04"
    defer_ret build_run_ctx_reset
    build_run rm -rf \
      ./conda-channel \
      ./iossifovlab-gpf-base/gpf \
      ./iossifovlab-gpf-base/conda-channel \
      ./iossifovlab-gpf/gpf \
      ./iossifovlab-gpf/conda-channel \
      ./iossifovlab-gpf-full/gpfjs \
      ./iossifovlab-sfari-frontpage/sfari-frontpage
  }

  local gpf_package_image
  gpf_package_image=$(e docker_data_img_gpf_package)

  local gpfjs_package_image
  gpfjs_package_image=$(e docker_data_img_gpfjs_production_package)

  local sfari_frontpage_package_image
  sfari_frontpage_package_image=$(e docker_data_img_sfari_frontpage_package)

  local gpf_conda_packaging_channel
  gpf_conda_packaging_channel=$(e docker_data_img_gpf_conda_packaging_channel)

  build_stage "Draw build dependencies"
  {

    build_deps_graph_write_image 'build-env/dependency-graph.svg'
  }

  build_stage "Build iossifovlab-http"
  {
    build_run_local docker pull ubuntu:22.04

    build_docker_image_create \
      "iossifovlab-http" \
      "iossifovlab-http" \
      "iossifovlab-http/Dockerfile" \
      "latest"
  }

  build_stage "Get conda channel"
  {
    build_docker_image_cp_from "$gpf_conda_packaging_channel" . /conda-channel/
    tar zcvf ./results/conda-channel.tar.gz ./conda-channel
  }


  local docker_img_iossifovlab_mamba_base_tag
  docker_img_iossifovlab_mamba_base_tag="$(e docker_img_iossifovlab_mamba_base_tag)"

  echo "docker_img_iossifovlab_mamba_base_tag=$docker_img_iossifovlab_mamba_base_tag"


  build_stage "Build iossifovlab-gpf-base"
  {
    # copy gpf package
    build_run_local mkdir ./iossifovlab-gpf-base/gpf
    build_run_local bash -c 'cd ./iossifovlab-gpf-base/ && 
        tar zxf ../results/conda-channel.tar.gz'

    build_docker_image_create \
      "iossifovlab-gpf-base" \
      "iossifovlab-gpf-base" \
      "iossifovlab-gpf-base/Dockerfile" \
      "$docker_img_iossifovlab_mamba_base_tag"
  }

  local docker_img_iossifovlab_gpf_base_tag
  docker_img_iossifovlab_gpf_base_tag="$(e docker_img_iossifovlab_gpf_base_tag)"

  build_stage "Build iossifovlab-gpf"
  {

    build_docker_image_create \
      "iossifovlab-gpf" \
      "iossifovlab-gpf" \
      "iossifovlab-gpf/Dockerfile" \
      "$docker_img_iossifovlab_gpf_base_tag"
  }

  build_stage "Build iossifovlab-gpf-import"
  {

    build_docker_image_create \
      "iossifovlab-gpf-import" \
      "iossifovlab-gpf-import" \
      "iossifovlab-gpf-import/Dockerfile" \
      "$docker_img_iossifovlab_gpf_base_tag"
  }

  build_stage "Build gpf-full"
  {

    # copy gpfjs package
    build_run_local mkdir ./iossifovlab-gpf-full/gpfjs
    build_docker_image_cp_from "$gpfjs_package_image" ./iossifovlab-gpf-full/ /gpfjs

    local docker_repo
    docker_repo=$(ee docker_repo)

    local docker_img_iossifovlab_gpf_tag
    docker_img_iossifovlab_gpf_tag=$(e docker_img_iossifovlab_gpf_tag)

    build_docker_image_create "iossifovlab-gpf-full" "iossifovlab-gpf-full" \
      ./iossifovlab-gpf-full/Dockerfile "${docker_img_iossifovlab_gpf_tag}"


  }

  build_stage "Build sfari-frontpage"
  {
    # copy sfari-frontpage package
    build_run_local mkdir ./iossifovlab-sfari-frontpage/sfari-frontpage
    build_docker_image_cp_from "$sfari_frontpage_package_image" \
        ./iossifovlab-sfari-frontpage/ /sfari-frontpage

    local docker_repo
    docker_repo=$(ee docker_repo)

    local docker_img_iossifovlab_http_tag
    docker_img_iossifovlab_http_tag=$(e docker_img_iossifovlab_http_tag)

    build_docker_image_create \
      "iossifovlab-sfari-frontpage" \
      "iossifovlab-sfari-frontpage" \
      "iossifovlab-sfari-frontpage/Dockerfile" \
      "$docker_img_iossifovlab_http_tag"
  }

  build_stage "Build gpf fronting proxy"
  {
    local docker_repo
    docker_repo=$(ee docker_repo)

    local docker_img_iossifovlab_http_tag
    docker_img_iossifovlab_http_tag=$(e docker_img_iossifovlab_http_tag)

    build_docker_image_create \
      "iossifovlab-gpf-fronting-proxy" \
      "iossifovlab-gpf-fronting-proxy" \
      "iossifovlab-gpf-fronting-proxy/Dockerfile" \
      "$docker_img_iossifovlab_http_tag"
  }

}

main "$@"
