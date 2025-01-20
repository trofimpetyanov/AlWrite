#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR


# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")


variant_for_slice()
{
  case "$1" in
  "libMyScript2D.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScript2D.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScript2D.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptDocument.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptDocument.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptDocument.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptGesture.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptGesture.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptGesture.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptInk.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptInk.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptInk.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptMath.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptMath.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptMath.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptShape.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptShape.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptShape.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptText.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptText.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptText.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libMyScriptEngine.xcframework/ios-arm64")
    echo ""
    ;;
  "libMyScriptEngine.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libMyScriptEngine.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  "libiink.xcframework/ios-arm64")
    echo ""
    ;;
  "libiink.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "maccatalyst"
    ;;
  "libiink.xcframework/ios-arm64_x86_64-simulator")
    echo "simulator"
    ;;
  esac
}

archs_for_slice()
{
  case "$1" in
  "libMyScript2D.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScript2D.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScript2D.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptAnalyzer.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptDocument.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptDocument.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptDocument.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptGesture.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptGesture.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptGesture.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptInk.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptInk.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptInk.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptMath.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptMath.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptMath.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptMLOrt.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptPrediction.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptShape.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptShape.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptShape.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptText.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptText.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptText.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libMyScriptEngine.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libMyScriptEngine.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libMyScriptEngine.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  "libiink.xcframework/ios-arm64")
    echo "arm64"
    ;;
  "libiink.xcframework/ios-arm64_x86_64-maccatalyst")
    echo "arm64 x86_64"
    ;;
  "libiink.xcframework/ios-arm64_x86_64-simulator")
    echo "arm64 x86_64"
    ;;
  esac
}

copy_dir()
{
  local source="$1"
  local destination="$2"

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" \"${source}*\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --links --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" "${source}"/* "${destination}"
}

SELECT_SLICE_RETVAL=""

select_slice() {
  local xcframework_name="$1"
  xcframework_name="${xcframework_name##*/}"
  local paths=("${@:2}")
  # Locate the correct slice of the .xcframework for the current architectures
  local target_path=""

  # Split archs on space so we can find a slice that has all the needed archs
  local target_archs=$(echo $ARCHS | tr " " "\n")

  local target_variant=""
  if [[ "$PLATFORM_NAME" == *"simulator" ]]; then
    target_variant="simulator"
  fi
  if [[ ! -z ${EFFECTIVE_PLATFORM_NAME+x} && "$EFFECTIVE_PLATFORM_NAME" == *"maccatalyst" ]]; then
    target_variant="maccatalyst"
  fi
  for i in ${!paths[@]}; do
    local matched_all_archs="1"
    local slice_archs="$(archs_for_slice "${xcframework_name}/${paths[$i]}")"
    local slice_variant="$(variant_for_slice "${xcframework_name}/${paths[$i]}")"
    for target_arch in $target_archs; do
      if ! [[ "${slice_variant}" == "$target_variant" ]]; then
        matched_all_archs="0"
        break
      fi

      if ! echo "${slice_archs}" | tr " " "\n" | grep -F -q -x "$target_arch"; then
        matched_all_archs="0"
        break
      fi
    done

    if [[ "$matched_all_archs" == "1" ]]; then
      # Found a matching slice
      echo "Selected xcframework slice ${paths[$i]}"
      SELECT_SLICE_RETVAL=${paths[$i]}
      break
    fi
  done
}

install_xcframework() {
  local basepath="$1"
  local name="$2"
  local package_type="$3"
  local paths=("${@:4}")

  # Locate the correct slice of the .xcframework for the current architectures
  select_slice "${basepath}" "${paths[@]}"
  local target_path="$SELECT_SLICE_RETVAL"
  if [[ -z "$target_path" ]]; then
    echo "warning: [CP] $(basename ${basepath}): Unable to find matching slice in '${paths[@]}' for the current build architectures ($ARCHS) and platform (${EFFECTIVE_PLATFORM_NAME-${PLATFORM_NAME}})."
    return
  fi
  local source="$basepath/$target_path"

  local destination="${PODS_XCFRAMEWORKS_BUILD_DIR}/${name}"

  if [ ! -d "$destination" ]; then
    mkdir -p "$destination"
  fi

  copy_dir "$source/" "$destination"
  echo "Copied $source to $destination"
}

install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScript2D.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptAnalyzer.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptDocument.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptGesture.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptInk.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptMath.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptMLOrt.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptPrediction.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptShape.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptText.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libMyScriptEngine.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"
install_xcframework "${PODS_ROOT}/MyScriptInteractiveInk-Runtime/libiink.xcframework" "MyScriptInteractiveInk-Runtime" "library" "ios-arm64" "ios-arm64_x86_64-maccatalyst" "ios-arm64_x86_64-simulator"

