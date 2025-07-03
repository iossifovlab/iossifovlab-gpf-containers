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
        iossifovlab.gpf-conda-packaging
    libmain_save_build_env_on_exit
    libbuild_init stage:"$stage" registry.seqpipe.org

    defer_ret build_run_ctx_reset_all_persistent
    defer_ret build_run_ctx_reset

    build_stage "Cleanup"
    {
        build_run_ctx_init "container" "ubuntu:24.04"
        defer_ret build_run_ctx_reset
        build_run rm -rf \
            ./conda-channel \
            ./iossifovlab-gpf-base/gpf \
            ./iossifovlab-gpfjs-base/gpfjs \
            ./iossifovlab-gpf-base/conda-channel \
            ./iossifovlab-gpf/gpf \
            ./iossifovlab-gpf/conda-channel \
            ./iossifovlab-gpf-full/gpfjs
    }


    local gpfjs_package_image
    gpfjs_package_image=$(e docker_data_img_gpfjs_production_package)

    local gpf_conda_packaging_channel
    gpf_conda_packaging_channel=$(e docker_data_img_gpf_conda_packaging_channel)

    build_stage "Draw build dependencies"
    {
        build_deps_graph_write_image 'build-env/dependency-graph.svg'
    }

    build_stage "Get conda channel"
    {
        build_docker_image_cp_from "$gpf_conda_packaging_channel" . /conda-channel/
    }

    local docker_img_iossifovlab_mamba_base_tag
    docker_img_iossifovlab_mamba_base_tag="$(e docker_img_iossifovlab_mamba_base_tag)"

    echo "docker_img_iossifovlab_mamba_base_tag=$docker_img_iossifovlab_mamba_base_tag"

    build_stage "Build iossifovlab-gpfjs-base"
    {
        # copy gpfjs package
        build_run_local mkdir ./iossifovlab-gpfjs-base/gpfjs
        build_docker_image_cp_from "$gpfjs_package_image" \
            ./iossifovlab-gpfjs-base/ /gpfjs

        build_docker_image_create \
            "iossifovlab-gpfjs-base" \
            "iossifovlab-gpfjs-base" \
            "iossifovlab-gpfjs-base/Dockerfile" \
            "latest"

    }

    build_stage "Build iossifovlab-gpf-base"
    {

        build_run_local bash -c 'cd ./iossifovlab-gpf-base/ && 
            cp -rf ../conda-channel .'

        build_docker_image_create \
        "iossifovlab-gpf-base" \
        "iossifovlab-gpf-base" \
        "iossifovlab-gpf-base/Dockerfile" \
        "$docker_img_iossifovlab_mamba_base_tag"
        
    }

    build_stage "Build iossifovlab-gpf"
    {

        local gpf_base_tag
        gpf_base_tag="$(e docker_img_iossifovlab_gpf_base_tag)"

        local python_version
        python_version=$(e gpf_conda_packaging_python_version)

        build_docker_image_create \
            "iossifovlab-gpf" \
            "iossifovlab-gpf" \
            "iossifovlab-gpf/Dockerfile" \
            "${gpf_base_tag}" \
            PYTHON_VERSION="${python_version}"
    }

    build_stage "Build iossifovlab-gpf-import"
    {

        local gpf_base_tag
        gpf_base_tag="$(e docker_img_iossifovlab_gpf_base_tag)"

        build_docker_image_create \
            "iossifovlab-gpf-import" \
            "iossifovlab-gpf-import" \
            "iossifovlab-gpf-import/Dockerfile" \
            "${gpf_base_tag}"
    }

    build_stage "Build gpf-full"
    {

        local python_version
        python_version=$(e gpf_conda_packaging_python_version)

        local gpf_base_tag
        gpf_base_tag="$(e docker_img_iossifovlab_gpf_base_tag)"

        build_docker_image_create \
            "iossifovlab-gpf-full" \
            "iossifovlab-gpf-full" \
            ./iossifovlab-gpf-full/Dockerfile \
            "${gpf_base_tag}" \
            PYTHON_VERSION="${python_version}"

    }

    build_stage "Build iossifovlab-http"
    {
        build_run_local docker pull ubuntu:24.04

        build_docker_image_create \
            "iossifovlab-http" \
            "iossifovlab-http" \
            "iossifovlab-http/Dockerfile" \
            "latest"
    }

}

main "$@"
