##!/bin/sh

export DOCC_JSON_PRETTYPRINT="YES"

xcrun xcodebuild docbuild \
    -scheme Horoscope \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.derivedData"

xcrun docc process-archive transform-for-static-hosting \
    "$PWD/.derivedData/Build/Products/Debug-iphonesimulator/Horoscope.doccarchive" \
    --output-path "docs" \
    --hosting-base-path "horoscope"

echo '<script>window.location.href += "/documentation/horoscope"</script>' > docs/index.html

# Copy updated favicons to docs folder
cp -f "$PWD/favicon.ico" "$PWD/docs/favicon.ico"
cp -f "$PWD/favicon.svg" "$PWD/docs/favicon.svg"


# Remove the derived data directory
rm -rf "$PWD/.derivedData"
