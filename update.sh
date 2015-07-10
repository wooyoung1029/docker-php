#!/bin/bash
set -e

cd versions
versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
    versions=( */ )
fi
versions=( "${versions[@]%/}" )
cd ..

for version in "${versions[@]}"; do
    echo "Updating $version"
    (
      set -x
      rsync -auh --delete template/ versions/$version
      cp README.md versions/$version/
      sed -i '' -e 's/{{ version }}/'$version'/g' versions/$version/Dockerfile
    )
done

echo "Fix PHP 5.3"
(
  set -x;
  sed -i '' \
      -e '1s|.*|FROM helder/php-5.3|' \
      -e '/--with-freetype-dir/i\
        \  && mkdir /usr/include/freetype2/freetype \\ \
        \  && ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h \\' \
    versions/5.3/Dockerfile
)
