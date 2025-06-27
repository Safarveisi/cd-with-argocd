#!/bin/bash

STARTING_PATH=$(git rev-parse --show-toplevel)
IDENTIFIER_COMMENT="# LATEST_IMAGE_TAG"


function get_project_version {
    echo "v$(cat pyproject.toml | grep 'version =' | sed -E 's/version = //' | tr -d '"=')"
}

function get_required_python_version {
    cat pyproject.toml | grep 'requires-python =' | sed -E 's/requires-python = //' | tr -d '">='
}

function update_docker_image_tag {
    VERSION_TAG=$(get_project_version)
    # Update docker image tags in the manifest files for Spark application and airflow dags
    find "$STARTING_PATH" -type f \( -name "*.yml" \) -exec grep -l "$IDENTIFIER_COMMENT" {} \; | while read -r file; do
        echo "Updating: $file"
        sed -i "s|\(\s*.*:\s*\).* \($IDENTIFIER_COMMENT\)|\1"${@:-$VERSION_TAG}" \2|" "$file";
    done
}

function help {
    echo "$0 <task> [args]"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}
