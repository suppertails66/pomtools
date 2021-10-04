
set -o errexit

make




# function remapPalette() {
#   oldFile=$1
#   palFile=$2
#   newFile=$3
#   
#   convert "$oldFile" -dither None -remap "$palFile" PNG32:$newFile
# }
# 
# function cropImg() {
#   oldFile=$1
#   cropX=$2
#   cropY=$3
#   cropW=$4
#   cropH=$5
#   newFile=$6
#   
#   convert "$oldFile" -crop ${cropW}x${cropH}+${cropX}+${cropY} +repage   PNG32:$newFile
# }
# # "rsrc/grp/orig/title_logo_upper.png"
# cropImg "rsrc/grp/title_logo_full.png" 0 0 160 32 "rsrc/grp/title_logo_upper.png"
# cropImg "rsrc/grp/title_logo_full.png" 0 32 160 32 "rsrc/grp/title_logo_middle.png"
# cropImg "rsrc/grp/title_logo_full.png" 0 64 160 48 "rsrc/grp/title_logo_lower.png"
# 
# remapPalette "rsrc/grp/title_logo_upper.png" "rsrc/grp/orig/title_logo_upper.png" "rsrc/grp/title_logo_upper.png"
# remapPalette "rsrc/grp/title_logo_middle.png" "rsrc/grp/orig/title_logo_middle.png" "rsrc/grp/title_logo_middle.png"
# remapPalette "rsrc/grp/title_logo_lower.png" "rsrc/grp/orig/title_logo_lower.png" "rsrc/grp/title_logo_lower.png"
# 
# convert -size 160x112 xc:transparent\
#   "rsrc/grp/title_logo_upper.png" -geometry +0+0 -composite\
#   "rsrc/grp/title_logo_middle.png" -geometry +0+32 -composite\
#   "rsrc/grp/title_logo_lower.png" -geometry +0+64 -composite\
#   PNG32:rsrc/grp/title_logo_full_convert.png
# 
# #./psx_img_decolorize "rsrc/grp/title_logo_upper.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/title_logo_upper.png" 4 -paloffset 0x54
# 
# exit

mkdir -p mapimg

for file in rsrc_raw/maps_decompressed/*/resources/*.bin; do
  mapNum=$(basename $(dirname $(dirname $file)))
  resNum=$(basename $file .bin)
#  echo $file $mapNum $resNum

  mkdir -p "mapimg/${mapNum}"
  ./psx_rawimg_extr "$file" "mapimg/${mapNum}/${resNum}.png" 256 256 4 -i 0x0
done;

