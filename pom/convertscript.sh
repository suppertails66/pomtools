
set -o errexit

cd script

soffice --headless --convert-to csv --infilter=CSV:44,34,64 pom_script.ods
