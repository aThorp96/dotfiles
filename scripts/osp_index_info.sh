#!/usr/bin/env bash
# Dependencies:
#   - podman
#   - jq
#   - fzf

set -euo pipefail

function parse_component_image() {
    IMAGE="${1:?No component image provided}"
	IMAGE_REF=$(echo "${IMAGE}" | rev | cut -d '/' -f 1 | rev)
	DOWNSTREAM_COMMIT=""
	UPSTREAM_COMMIT=""

	OUT="- ${IMAGE_REF}:"

	if [[ "${IMAGE}" == quay.io/openshift-pipeline/* ]]; then
    	CONTAINER=$(podman create -q "${IMAGE}")
    	DOWNSTREAM_COMMIT=$(podman inspect "${CONTAINER}" | jq -r '.[0].Config.Labels."vcs-ref"')
    	[[ "${DOWNSTREAM_COMMIT}" == "" ]] || OUT="${OUT}\n    downstream_commit: ${DOWNSTREAM_COMMIT}"

    	podman cp "${CONTAINER}:/kodata/HEAD" "${CONTAINER}_head" 2>/dev/null && UPSTREAM_COMMIT=$(cat "${CONTAINER}_head") || echo -n ""
    	[[ "${UPSTREAM_COMMIT}" == "" ]] || OUT="${OUT}\n    upstream_commit: ${UPSTREAM_COMMIT}"
	fi

	if [[ "${OUT}" == *: ]]; then
    	OUT="${OUT} {}"
	fi

	echo -e "${OUT}"
}

export IMAGE="${1:?No image provided}"

TMPDIR=$(mktemp -d)
cd "${TMPDIR}"

echo "Pulling index image ${IMAGE}"
INDEX_CONTAINER=$(podman create "${IMAGE}")

INDEX_CATALOG_PATH="/configs/openshift-pipelines-operator-rh/catalog.json"
CATALOG_FILE="catalog.json"
podman cp "${INDEX_CONTAINER}:${INDEX_CATALOG_PATH}" "${CATALOG_FILE}"

RELEASE_CHANNEL=$(jq -r 'select(.schema == "olm.channel").name' "${CATALOG_FILE}" | fzf --prompt "Release Channel> ")
NUM_ENTRIES=$(jq -r "select(.schema == \"olm.channel\" and .name == \"${RELEASE_CHANNEL}\").entries | length" "${CATALOG_FILE}")
if [[ "${NUM_ENTRIES}" == "1" ]]; then
    BUNDLE=$(jq -r "select(.schema == \"olm.channel\" and .name == \"${RELEASE_CHANNEL}\").entries[0].name" "${CATALOG_FILE}")
    echo "Only available version"
else
    BUNDLE=$(jq -r "select(.schema == \"olm.channel\" and .name == \"${RELEASE_CHANNEL}\").entries[].name" "${CATALOG_FILE}" | fzf --prompt "Release version> ")
fi
jq "select(.schema == \"olm.bundle\" and .name == \"${BUNDLE}\")" "${CATALOG_FILE}" > bundle.json
VERSION=$(jq -r ".properties[] | select(.type == \"olm.package\" and .value.packageName == \"openshift-pipelines-operator-rh\").value.version" bundle.json)
echo "Using version ${VERSION}"

echo "---"
for image in $(jq -r '.relatedImages[].image' bundle.json | sort | uniq); do
    parse_component_image "${image}" || echo "Cannot get image info for ${image}" >&2
done
