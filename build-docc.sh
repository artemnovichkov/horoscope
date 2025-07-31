##!/bin/sh

xcrun xcodebuild docbuild \
    -scheme Horoscope \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$PWD/.derivedData"

xcrun docc process-archive transform-for-static-hosting \
    "$PWD/.derivedData/Build/Products/Debug-iphonesimulator/Horoscope.doccarchive" \
    --output-path "docs" \
    --hosting-base-path "horoscope"

echo '<script>window.location.href += "/documentation/horoscope"</script>' > docs/index.html
