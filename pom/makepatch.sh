versionnum="v1.0"

filenameredump_1997="patch/redump_patch/Community Pom EN [${versionnum}-1997] Redump.xdelta"
filenamesplitbin_1997="patch/splitbin_patch/Community Pom EN [${versionnum}-1997] SplitBin.xdelta"
filenameredump_1999="patch/redump_patch/Community Pom EN [${versionnum}-1999] Redump.xdelta"
filenamesplitbin_1999="patch/splitbin_patch/Community Pom EN [${versionnum}-1999] SplitBin.xdelta"

mkdir -p patch
mkdir -p patch/redump_patch
mkdir -p patch/splitbin_patch

./build.sh

rm -f "$filenameredump_1997"
xdelta3 -e -B 186579456 -s "patch/exclude/pom1997_redump.bin" "pom_build.bin" "$filenameredump_1997"

rm -f "$filenameredump_1999"
xdelta3 -e -B 186577104 -s "patch/exclude/pom1999_redump.bin" "pom_build.bin" "$filenameredump_1999"
