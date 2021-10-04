
set -o errexit

# BASE_PWD=$PWD
# PATH=".:$PATH"
# 
# mkdir -p out/scripttxt
# mkdir -p out/scriptwrap
# mkdir -p out/script
# 
# pom_scriptimport
# 
# for file in out/scripttxt/*.txt; do
#   name=$(basename $file)
#   pom_scriptwrap "$file" "out/scriptwrap/$name"
# done
# 
# pom_scriptbuild "out/scriptwrap/" "out/script/"

make pom_scriptwrap
./pom_scriptwrap "testscript_input.txt" "testscript_output.txt"
