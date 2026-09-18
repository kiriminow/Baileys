#!/bin/sh
# Generate the static protobuf module (index.js + index.d.ts) from WAProto.proto.
#
# The upstream version of this script used relative paths that disagreed with
# each other: `./WAProto.proto` implied the repo root, while `./fix-imports.js`
# (which hardcodes './index.js') implied this directory. It also invoked `yarn
# pbjs`, which cannot resolve from here because WAProto/ has no package.json.
# The result was that `yarn gen:protobuf` always failed with ENOENT.
#
# This version is cwd-independent: it resolves its own directory, calls the
# tooling by absolute path from the repo root, and runs the file operations here.
set -e

DIR=$(cd "$(dirname "$0")" && pwd)
ROOT=$(dirname "$DIR")

PBJS="$ROOT/node_modules/.bin/pbjs"
PBTS="$ROOT/node_modules/.bin/pbts"

if [ ! -x "$PBJS" ] || [ ! -x "$PBTS" ]; then
	echo "pbjs/pbts not found under $ROOT/node_modules/.bin — run 'yarn install' first" >&2
	exit 1
fi

cd "$DIR"

"$PBJS" -t static-module --no-beautify -w es6 --no-bundle --no-delimited --no-verify --no-comments -o ./index.js ./WAProto.proto
"$PBJS" -t static-module --no-beautify -w es6 --no-bundle --no-delimited --no-verify ./WAProto.proto | "$PBTS" --no-comments -o ./index.d.ts -
node ./fix-imports.js
