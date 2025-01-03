#!/usr/bin/env bash

VERSION="$1"
if [ -z "${VERSION}" ]; then echo "VERSION is not set. Use ./release.sh 0.0.0 stage" >&2; exit 1; fi

STAGE="$2"
if [ -z "${STAGE}" ]; then STAGE="prod"; fi

MOD_NAME="PermanentEffectsDrinks"
if [ "${STAGE}" == "test" ]; then MOD_NAME="${MOD_NAME}Test"; fi
if [ "${STAGE}" == "local" ]; then MOD_NAME="${MOD_NAME}Local"; fi

RELEASE_NAME="${MOD_NAME}-${VERSION}"

rm -r .tmp/release
mkdir -p .tmp/release
touch .tmp/release/checksum.txt

function make_release() {
  local dir_workshop=".tmp/release/${RELEASE_NAME}"
  local dir="${dir_workshop}/Contents/mods/${MOD_NAME}"
  local dir_common="${dir}/common"
  local dir_42="${dir}/42"

  mkdir -p "${dir}"
  mkdir -p "${dir_common}"
  mkdir -p "${dir_42}"

  case $STAGE in
    local|test|prod)
      cp workshop/$STAGE/workshop.txt "${dir_workshop}"
      cp workshop/$STAGE/mod.info "${dir}"
      cp workshop/$STAGE/mod.info "${dir_42}"
      ;;
    *)
      echo "incorrect stage" >&2
      exit 1
      ;;
  esac

  cp workshop/preview.png "${dir_workshop}/preview.png"
  cp workshop/preview.png "${dir}"
  cp workshop/preview.png "${dir_42}"
  cp src -r "${dir}/media"
  cp src -r "${dir_42}/media"

  find "${dir}/media" -name '*_test.lua' -type f -delete
  find "${dir_42}/media" -name '*_test.lua' -type f -delete

  # TODO: think about this.
  find "${dir}/media" -name '*_b42.txt' -type f -delete
  find "${dir_42}/media" -name '*_b41.txt' -type f -delete

  cp LICENSE "${dir}"
  cp LICENSE "${dir_42}"
  cp README.md "${dir}"
  cp README.md "${dir_42}"
  cp CHANGELOG.md "${dir}"
  cp CHANGELOG.md "${dir_42}"

  cd "${dir_workshop}/Contents/mods/" && {
    tar -zcvf "../../../${RELEASE_NAME}.tar.gz" "${MOD_NAME}"
    zip -r "../../../${RELEASE_NAME}.zip" "${MOD_NAME}"
  }

  cd ../../../ && {
    md5sum "${RELEASE_NAME}.tar.gz" >> checksum.txt;
    md5sum "${RELEASE_NAME}.zip" >> checksum.txt;
    cd ../../;
  }
}

function install_release() {
  rm -r ~/Zomboid/Workshop/"${MOD_NAME}"
  cp -r  .tmp/release/"${RELEASE_NAME}" ~/Zomboid/Workshop/"${MOD_NAME}"
  rm -r .tmp/release/"${RELEASE_NAME}"
}

make_release && install_release
