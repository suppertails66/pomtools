
echo "*******************************************************************************"
echo "Setting up environment..."
echo "*******************************************************************************"

set -o errexit

# nonzero to boot to credits
ENDING_DEBUG_ON=0

BASE_PWD=$PWD
PATH=".:$PATH"

DISCASTER="../discaster/discaster"
ARMIPS="./armips/build/armips"

mkdir -p out

function remapPalette() {
  oldFile=$1
  palFile=$2
  newFile=$3
  
  if [ "$newFile" == "" ]; then
    newFile=$oldFile
  fi
  
  convert "$oldFile" -dither None -remap "$palFile" PNG32:$newFile
}

# function remapPaletteDithered() {
#   oldFile=$1
#   palFile=$2
#   newFile=$3
#   
#   convert "$oldFile" -dither Riemersma -remap "$palFile" PNG32:$newFile
# }

echo "*******************************************************************************"
echo "Copying game files..."
echo "*******************************************************************************"

#rm -r -f out/files
#if [ ! -e out/files ]; then
  mkdir -p out/files
  cp -r disc/files/* out/files
#fi

echo "*******************************************************************************"
echo "Building tools..."
echo "*******************************************************************************"

make

if [ ! -e $ARMIPS ]; then
  
  echo "********************************************************************************"
  echo "Building armips..."
  echo "********************************************************************************"
  
  cd armips
    mkdir build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make
  cd $BASE_PWD
  
fi

echo "*******************************************************************************"
echo "Refreshing archive directories..."
echo "*******************************************************************************"

cp -r rsrc_raw out
cp -r rsrc out
cp "rsrc/grp/op_font.png" "font/op/sheet.png"

echo "*******************************************************************************"
echo "Building font..."
echo "*******************************************************************************"

numFontChars=128

mkdir -p out/font

# HACK: convert font sheet's background from black to transparent so the
# automatic character width analysis will work properly
convert font/sheet.png -transparent black font/sheet.png


#remapPalette "font/end/sheet.png" "out/rsrc_raw/end_font_white.png"

pom_genchrompal 0x00 0x00 0x00 0xFF 0xFF 0xFF "out/rsrc_raw/pal/end_font_white.pal" "out/rsrc_raw/pal/end_font_white.png"
pom_genchrompal 0x00 0x00 0x00 0xDD 0xDD 0x00 "out/rsrc_raw/pal/end_font_karaoke_bg.pal" "out/rsrc_raw/pal/end_font_karaoke_fg.png"
pom_genchrompal 0x00 0x00 0x00 0x00 0x99 0xFF "out/rsrc_raw/pal/end_font_karaoke_fg.pal" "out/rsrc_raw/pal/end_font_karaoke_bg.png"
pom_genchrompal 0x00 0x00 0x00 0xB0 0xCD 0x33 "out/rsrc_raw/pal/end_font_fade1.pal" "out/rsrc_raw/pal/end_font_fade1.png"
pom_genchrompal 0x00 0x00 0x00 0x84 0xC0 0x66 "out/rsrc_raw/pal/end_font_fade2.pal" "out/rsrc_raw/pal/end_font_fade2.png"
pom_genchrompal 0x00 0x00 0x00 0x58 0xB3 0x99 "out/rsrc_raw/pal/end_font_fade3.pal" "out/rsrc_raw/pal/end_font_fade3.png"
pom_genchrompal 0x00 0x00 0x00 0x2C 0xA6 0xCC "out/rsrc_raw/pal/end_font_fade4.pal" "out/rsrc_raw/pal/end_font_fade4.png"

pom_fontbuild "font/" $numFontChars "out/font/font_raw.bin" "out/font/font_width.bin"
psx_rawimg_extr "out/font/font_raw.bin" "out/font/font_grp.png" 256 $numFontChars 4

pom_opfontbuild "font/op/" "out/font/op_width.bin" "out/font/op_kerning.bin" "op"
pom_opfontbuild "font/end/" "out/font/end_width.bin" "out/font/end_kerning.bin"

# too many damn files
convert "out/rsrc/grp/end_SPRITE_color.png"\
  \( "font/end/sheet.png" -crop 256x208+0+0 +repage \) -geometry +0+48 -composite\
  PNG32:"out/rsrc/grp/end_SPRITE_color.png"

#psx_img_decolorize "font/end/sheet.png" "rsrc_raw/pal/end_font_white.pal" "out/rsrc/grp/end_SPRITE.png" 4

# this "SPRITE" file mostly consists of random crap, including stick figure
# doodles, that i assume was used for debugging.
# but a bit at the top is used to generate the black/white fades
# during the credits sequence (with the corresponding palettes
# similarly in use), so we have to take care to leave those
# undisturbed while inserting the font and its palettes
psx_img_decolorize "out/rsrc/grp/end_SPRITE_color.png" "rsrc_raw/pal/end_font_white.pal" "out/rsrc/grp/end_SPRITE_color.png" 4
psx_img_bitconv "out/rsrc/grp/end_SPRITE_color.png" "out/rsrc/grp/end_SPRITE_color.png" 4 8
convert "out/rsrc/grp/end_SPRITE.png"\
  \( "out/rsrc/grp/end_SPRITE_color.png" -crop 128x208+0+48 +repage \) -geometry +128+48 -composite\
  PNG32:"out/rsrc/grp/end_SPRITE.png"
#psx_img_bitconv "out/rsrc/grp/end_SPRITE.png" "out/rsrc/grp/end_SPRITE.png" 4 8
psx_rawimg_conv "out/rsrc/grp/end_SPRITE.png" "out/rsrc/grp/end_SPRITE.bin" 8
datpatch "out/rsrc_raw/endpak/SPRITE.TIM" "out/rsrc_raw/endpak/SPRITE.TIM" "out/rsrc/grp/end_SPRITE.bin" 0x220

cat "out/rsrc_raw/pal/end_font_white.pal" "out/rsrc_raw/pal/end_font_karaoke_fg.pal" "out/rsrc_raw/pal/end_font_karaoke_bg.pal" "out/rsrc_raw/pal/end_font_fade1.pal" "out/rsrc_raw/pal/end_font_fade2.pal" "out/rsrc_raw/pal/end_font_fade3.pal" "out/rsrc_raw/pal/end_font_fade4.pal" > "out/rsrc_raw/pal/end_font.pal"
datpatch "out/rsrc_raw/endpak/SPRITE.TIM" "out/rsrc_raw/endpak/SPRITE.TIM" "out/rsrc_raw/pal/end_font.pal" 0x114

# end credits font
psx_img_decolorize "out/rsrc/grp/END_0_pal14.png" "out/rsrc_raw/endpak/END_0.TIM" "out/rsrc/grp/END_0.png" 4 -paloffset 0x14
psx_rawimg_conv "out/rsrc/grp/END_0.png" "out/rsrc/grp/END_0.bin" 4
datpatch "out/rsrc_raw/endpak/END_0.TIM" "out/rsrc_raw/endpak/END_0.TIM" "out/rsrc/grp/END_0.bin" 0x220

# end logo
psx_img_decolorize "out/rsrc/grp/END_1_pal54.png" "out/rsrc_raw/endpak/END_1.TIM" "out/rsrc/grp/END_1_pal54.png" 4 -paloffset 0x54
convert "out/rsrc/grp/END_1.png"\
  \( "out/rsrc/grp/END_1_pal54.png" -crop 64x48+160+0 +repage \) -geometry +160+0 -composite\
  PNG32:"out/rsrc/grp/END_1.png"
psx_rawimg_conv "out/rsrc/grp/END_1.png" "out/rsrc/grp/END_1.bin" 4
datpatch "out/rsrc_raw/endpak/END_1.TIM" "out/rsrc_raw/endpak/END_1.TIM" "out/rsrc/grp/END_1.bin" 0x220

echo "*******************************************************************************"
echo "Building extra map resources..."
echo "*******************************************************************************"

# these are really part of the image insertion workflow,
# but the script inserter also handles packing the maps,
# so this has to happen before the script is built

#================================
# map5 res9
#================================

#psx_img_decolorize "out/rsrc/grp/title_menu.png" "rsrc_raw/pal/map21_res9_pal474.bin" "out/rsrc/grp/title_menu.png" 4
  
#================================
# minigame maps
#================================

psx_img_decolorize "out/rsrc/grp/map21_res9_pal474.png" "rsrc_raw/pal/map21_res9_pal474.bin" "out/rsrc/grp/map21_res9_pal474.png" 4
psx_img_decolorize "out/rsrc/grp/map39_res9_pal454.png" "rsrc_raw/pal/map39_res9_pal454.bin" "out/rsrc/grp/map39_res9_pal454.png" 4

# map 21 = mining
convert "out/rsrc/grp/map21_res9.png"\
  \( "out/rsrc/grp/map21_res9_pal474.png" -crop 192x32+0+96 +repage \) -geometry +0+96 -composite\
  \( "out/rsrc/grp/map21_res9_pal474.png" -crop 184x96+0+128 +repage \) -geometry +0+128 -composite\
  PNG32:"out/rsrc/grp/map21_res9.png"
psx_rawimg_conv "out/rsrc/grp/map21_res9.png" "out/rsrc_raw/maps_decompressed/21/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/21/resources/9.bin" "out/rsrc_raw/maps/21/resources/9.bin"

# map 5 = ?
convert "out/rsrc/grp/map5_res9.png"\
  \( "out/rsrc/grp/map21_res9_pal474.png" -crop 184x96+0+128 +repage \) -geometry +0+128 -composite\
  PNG32:"out/rsrc/grp/map5_res9.png"
psx_rawimg_conv "out/rsrc/grp/map5_res9.png" "out/rsrc_raw/maps_decompressed/5/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/5/resources/9.bin" "out/rsrc_raw/maps/5/resources/9.bin"

# map 18 = whac-a-moom
convert "out/rsrc/grp/map18_res9.png"\
  \( "out/rsrc/grp/map21_res9_pal474.png" -crop 184x32+0+160 +repage \) -geometry +0+160 -composite\
  PNG32:"out/rsrc/grp/map18_res9.png"
psx_rawimg_conv "out/rsrc/grp/map18_res9.png" "out/rsrc_raw/maps_decompressed/18/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/18/resources/9.bin" "out/rsrc_raw/maps/18/resources/9.bin"

# map 39 = pom chase
convert "out/rsrc/grp/map39_res9.png"\
  \( "out/rsrc/grp/map21_res9_pal474.png" -crop 184x32+0+160 +repage \) -geometry +0+160 -composite\
  \( "out/rsrc/grp/map39_res9_pal454.png" -crop 96x32+40+192 +repage \) -geometry +40+192 -composite\
  PNG32:"out/rsrc/grp/map39_res9.png"
psx_rawimg_conv "out/rsrc/grp/map39_res9.png" "out/rsrc_raw/maps_decompressed/39/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/39/resources/9.bin" "out/rsrc_raw/maps/39/resources/9.bin"
  
#================================
# misc maps
#================================

# map 12 = not-mr-flea boss
psx_img_decolorize "out/rsrc/grp/map12_res9_pal4F4.png" "rsrc_raw/pal/map12_res9_pal4F4.bin" "out/rsrc/grp/map12_res9_pal4F4.png" 4
convert "out/rsrc/grp/map12_res9.png"\
  \( "out/rsrc/grp/map12_res9_pal4F4.png" -crop 48x16+184+224 +repage \) -geometry +184+224 -composite\
  PNG32:"out/rsrc/grp/map12_res9.png"
psx_rawimg_conv "out/rsrc/grp/map12_res9.png" "out/rsrc_raw/maps_decompressed/12/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/12/resources/9.bin" "out/rsrc_raw/maps/12/resources/9.bin"

# map 48 = mandrake 1
psx_img_decolorize "out/rsrc/grp/map48_res9_pal494.png" "rsrc_raw/pal/map48_res9_pal494.bin" "out/rsrc/grp/map48_res9_pal494.png" 4
convert "out/rsrc/grp/map48_res9.png"\
  \( "out/rsrc/grp/map48_res9_pal494.png" -crop 96x32+8+56 +repage \) -geometry +8+56 -composite\
  PNG32:"out/rsrc/grp/map48_res9.png"
psx_rawimg_conv "out/rsrc/grp/map48_res9.png" "out/rsrc_raw/maps_decompressed/48/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/48/resources/9.bin" "out/rsrc_raw/maps/48/resources/9.bin"

# map 45 = mandrake 2
convert "out/rsrc/grp/map45_res9.png"\
  \( "out/rsrc/grp/map48_res9_pal494.png" -crop 96x32+8+56 +repage \) -geometry +8+56 -composite\
  PNG32:"out/rsrc/grp/map45_res9.png"
psx_rawimg_conv "out/rsrc/grp/map45_res9.png" "out/rsrc_raw/maps_decompressed/45/resources/9.bin" 4
rux_cmp "out/rsrc_raw/maps_decompressed/45/resources/9.bin" "out/rsrc_raw/maps/45/resources/9.bin"
  
#================================
# fix castle vajra boss rematch
# minimaps
#================================

# rux_cmp "out/rsrc_raw/maps_decompressed/61/resources/16.bin" "out/rsrc_raw/maps/63/resources/16.bin"
# cp "out/rsrc_raw/maps/63/resources/16.bin" "out/rsrc_raw/maps/64/resources/16.bin"
# cp "out/rsrc_raw/maps/63/resources/16.bin" "out/rsrc_raw/maps/65/resources/16.bin"
# cp "out/rsrc_raw/maps/63/resources/16.bin" "out/rsrc_raw/maps/66/resources/16.bin"

rux_cmp "out/rsrc_raw/special/map63_minimap_fix.bin" "out/rsrc_raw/maps/63/resources/16.bin"
rux_cmp "out/rsrc_raw/special/map64_minimap_fix.bin" "out/rsrc_raw/maps/64/resources/16.bin"
rux_cmp "out/rsrc_raw/special/map65_minimap_fix.bin" "out/rsrc_raw/maps/65/resources/16.bin"
rux_cmp "out/rsrc_raw/special/map66_minimap_fix.bin" "out/rsrc_raw/maps/66/resources/16.bin"

echo "*******************************************************************************"
echo "Generating script..."
echo "*******************************************************************************"

mkdir -p out/scripttxt
mkdir -p out/scriptwrap
mkdir -p out/script

pom_scriptimport

for file in out/scripttxt/*.txt; do
  name=$(basename $file)
  pom_scriptwrap "$file" "out/scriptwrap/$name"
done

# ugh
pom_scriptwrap "out/scripttxt/spec_end.txt" "out/scriptwrap/spec_end.txt" "table/pom_end.tbl"
pom_scriptwrap "out/scripttxt/spec_endnew.txt" "out/scriptwrap/spec_endnew.txt" "table/pom_end.tbl"

pom_scriptbuild "out/scriptwrap/" "out/script/"

echo "*******************************************************************************"
echo "Converting graphics..."
echo "*******************************************************************************"

function cropImg() {
  oldFile=$1
  cropX=$2
  cropY=$3
  cropW=$4
  cropH=$5
  newFile=$6
  
  convert "$oldFile" -crop ${cropW}x${cropH}+${cropX}+${cropY} +repage   PNG32:$newFile
}



# composite new packed font onto second page of font sheet
convert "out/rsrc/grp/font2.png"\
  "out/font/font_grp.png" -geometry +0+0 -composite\
  "PNG32:out/rsrc/grp/font2.png"
  
#================================
# generate title logo
#================================

cropImg "out/rsrc/grp/title_logo_full.png" 0 0 160 32 "out/rsrc/grp/title_logo_upper.png"
cropImg "out/rsrc/grp/title_logo_full.png" 0 32 160 32 "out/rsrc/grp/title_logo_middle.png"
cropImg "out/rsrc/grp/title_logo_full.png" 0 64 160 48 "out/rsrc/grp/title_logo_lower.png"

remapPalette "out/rsrc/grp/title_logo_upper.png" "out/rsrc/grp/orig/title_logo_upper.png" "out/rsrc/grp/title_logo_upper.png"
remapPalette "out/rsrc/grp/title_logo_middle.png" "out/rsrc/grp/orig/title_logo_middle.png" "out/rsrc/grp/title_logo_middle.png"
remapPalette "out/rsrc/grp/title_logo_lower.png" "out/rsrc/grp/orig/title_logo_lower.png" "out/rsrc/grp/title_logo_lower.png"

# convert -size 160x112 xc:transparent\
#   "out/rsrc/grp/title_logo_upper.png" -geometry +0+0 -composite\
#   "out/rsrc/grp/title_logo_middle.png" -geometry +0+32 -composite\
#   "out/rsrc/grp/title_logo_lower.png" -geometry +0+64 -composite\
#   PNG32:out/rsrc/grp/title_logo_full_convert.png

# combine all three images (this is just for "debugging")
convert -size 160x112 xc:transparent\
  "out/rsrc/grp/title_logo_upper.png" -geometry +0+0 -composite\
  "out/rsrc/grp/title_logo_middle.png" -geometry +0+32 -composite\
  "out/rsrc/grp/title_logo_lower.png" -geometry +0+64 -composite\
  PNG32:"out/rsrc/grp/title_logo_full.png"

psx_img_decolorize "out/rsrc/grp/title_logo_upper.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/title_logo_upper.png" 4 -paloffset 0x54
psx_img_decolorize "out/rsrc/grp/title_logo_middle.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/title_logo_middle.png" 4 -paloffset 0x74
psx_img_decolorize "out/rsrc/grp/title_logo_lower.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/title_logo_lower.png" 4 -paloffset 0x94

# combine all three decolorized images
convert -size 160x112 xc:transparent\
  "out/rsrc/grp/title_logo_upper.png" -geometry +0+0 -composite\
  "out/rsrc/grp/title_logo_middle.png" -geometry +0+32 -composite\
  "out/rsrc/grp/title_logo_lower.png" -geometry +0+64 -composite\
  PNG32:"out/rsrc/grp/title_logo_full_convert.png"

# place onto target page
convert "out/rsrc/grp/op1_5.png"\
  "out/rsrc/grp/title_logo_full_convert.png" -geometry +0+80 -composite\
  PNG32:"out/rsrc/grp/op1_5.png"
  
#================================
# generate title menu options
#================================

remapPalette "out/rsrc/grp/title_menu.png" "out/rsrc/grp/orig/title_start.png"
psx_img_decolorize "out/rsrc/grp/title_menu.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/title_menu.png" 4 -paloffset 0xB4
# convert "out/rsrc/grp/op1_5.png"\
#   "out/rsrc/grp/title_start.png" -geometry +48+64 -composite\
#   PNG32:"out/rsrc/grp/op1_5.png"
convert "out/rsrc/grp/op1_5.png"\
  \( "out/rsrc/grp/title_menu.png" -crop 144x16+0+0 +repage \) -geometry +48+64 -composite\
  \( "out/rsrc/grp/title_menu.png" -crop 88x16+0+16 +repage \) -geometry +160+48 -composite\
  \( "out/rsrc/grp/title_menu.png" -crop 72x16+88+16 +repage \) -geometry +160+80 -composite\
  PNG32:"out/rsrc/grp/op1_5.png"
  
#================================
# generate title font
#================================

psx_img_decolorize "out/rsrc/grp/op_font.png" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/op_font.png" 4 -paloffset 0x14

# a bunch of separate blocks...
convert "out/rsrc/grp/op1_5.png"\
  \( "out/rsrc/grp/op_font.png" -crop 256x48+0+0 +repage \) -geometry +0+0 -composite\
  \( "out/rsrc/grp/op_font.png" -crop 160x16+0+48 +repage \) -geometry +0+48 -composite\
  \( "out/rsrc/grp/op_font.png" -crop 32x16+0+64 +repage \) -geometry +0+64 -composite\
  \( "out/rsrc/grp/op_font.png" -crop 64x16+192+64 +repage \) -geometry +192+64 -composite\
  \( "out/rsrc/grp/op_font.png" -crop 96x48+160+144 +repage \) -geometry +160+144 -composite\
  PNG32:"out/rsrc/grp/op1_5.png"
  
#================================
# generate std1
#================================

psx_img_decolorize "out/rsrc/grp/std1_7_pal4.png" "rsrc_raw/pal/std1_7_4.bin" "out/rsrc/grp/std1_7_pal4.png" 4
psx_img_decolorize "out/rsrc/grp/std1_7_palA.png" "rsrc_raw/pal/std1_7_A.bin" "out/rsrc/grp/std1_7_palA.png" 4

convert "out/rsrc/grp/std1_7.png"\
  \( "out/rsrc/grp/std1_7_pal4.png" -crop 64x24+192+216 +repage \) -geometry +192+216 -composite\
  \( "out/rsrc/grp/std1_7_pal4.png" -crop 256x16+0+240 +repage \) -geometry +0+240 -composite\
  PNG32:"out/rsrc/grp/std1_7.png"

convert "out/rsrc/grp/std1_7.png"\
  \( "out/rsrc/grp/std1_7_palA.png" -crop 192x48+0+192 +repage \) -geometry +0+192 -composite\
  PNG32:"out/rsrc/grp/std1_7.png"
  
#================================
# generate std2
#================================

psx_img_decolorize "out/rsrc/grp/std2_0_pal1.png" "rsrc_raw/pal/std2_0_1.bin" "out/rsrc/grp/std2_0_pal1.png" 4
psx_img_decolorize "out/rsrc/grp/std2_0_pal6.png" "rsrc_raw/pal/std2_0_6.bin" "out/rsrc/grp/std2_0_pal6.png" 4
psx_img_decolorize "out/rsrc/grp/std2_0_palE.png" "rsrc_raw/pal/std2_0_E.bin" "out/rsrc/grp/std2_0_palE.png" 4

convert "out/rsrc/grp/std2_0.png"\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 96x40+112+0 +repage \) -geometry +112+0 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 192x32+64+40 +repage \) -geometry +64+40 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 72x8+0+152 +repage \) -geometry +0+152 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 144x16+0+160 +repage \) -geometry +0+160 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 48x16+208+176 +repage \) -geometry +208+176 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 56x16+200+208 +repage \) -geometry +200+208 -composite\
  \( "out/rsrc/grp/std2_0_pal1.png" -crop 256x16+0+240 +repage \) -geometry +0+240 -composite\
  PNG32:"out/rsrc/grp/std2_0.png"

convert "out/rsrc/grp/std2_0.png"\
  \( "out/rsrc/grp/std2_0_pal6.png" -crop 96x24+144+152 +repage \) -geometry +144+152 -composite\
  PNG32:"out/rsrc/grp/std2_0.png"

convert "out/rsrc/grp/std2_0.png"\
  \( "out/rsrc/grp/std2_0_palE.png" -crop 184x16+0+72 +repage \) -geometry +0+72 -composite\
  \( "out/rsrc/grp/std2_0_palE.png" -crop 240x32+0+88 +repage \) -geometry +0+88 -composite\
  PNG32:"out/rsrc/grp/std2_0.png"

#================================
# convert graphics to data and overwrite as needed
#================================

psx_rawimg_conv "out/rsrc/grp/std1_7.png" "out/rsrc/grp/std1_7.bin" 4
datpatch "out/rsrc_raw/pak/STD1/7.bin" "out/rsrc_raw/pak/STD1/7.bin" "out/rsrc/grp/std1_7.bin" 0x220

psx_rawimg_conv "out/rsrc/grp/std2_0.png" "out/rsrc/grp/std2_0.bin" 4
datpatch "out/rsrc_raw/pak/STD2/0.bin" "out/rsrc_raw/pak/STD2/0.bin" "out/rsrc/grp/std2_0.bin" 0x220

psx_rawimg_conv "out/rsrc/grp/font1.png" "out/rsrc/grp/font1.bin" 4
datpatch "out/rsrc_raw/pak/STD2/4.bin" "out/rsrc_raw/pak/STD2/4.bin" "out/rsrc/grp/font1.bin" 0x220

psx_rawimg_conv "out/rsrc/grp/font2.png" "out/rsrc/grp/font2.bin" 4
datpatch "out/rsrc_raw/pak/STD2/5.bin" "out/rsrc_raw/pak/STD2/5.bin" "out/rsrc/grp/font2.bin" 0x220

psx_rawimg_conv "out/rsrc/grp/op1_5.png" "out/rsrc/grp/op1_5.bin" 4
datpatch "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc_raw/pak/OP1/5.bin" "out/rsrc/grp/op1_5.bin" 0x220

#================================
# ending
#================================

# i could write a whole repacker for the ending files and
# list them all out here... but we're not actually changing
# the size of anything, so why not just do it in place
datpatch "out/files/PICT/POM_END.PCK" "out/files/PICT/POM_END.PCK" "out/rsrc_raw/endpak/SPRITE.TIM" 0x800
datpatch "out/files/PICT/POM_END.PCK" "out/files/PICT/POM_END.PCK" "out/rsrc_raw/endpak/END_0.TIM" 0x11000
datpatch "out/files/PICT/POM_END.PCK" "out/files/PICT/POM_END.PCK" "out/rsrc_raw/endpak/END_1.TIM" 0x7A000

echo "*******************************************************************************"
echo "Applying special fixes..."
echo "*******************************************************************************"

# fix to make trading card 41 obtainable in the same manner
# that it is in the 1999 rerelease of the game.
#
# trading card 41 is supposed to be received by inspecting a
# dresser in lunaire. however, in the original 1997 release,
# this simply gives the same "nothing interesting here" message
# as the other dresser in the town. this is clearly an error,
# as it leaves the card totally unobtainable.
# when the game was rereleased in 1999 under a different publisher,
# the game was modified to correctly give the card...
# but this patch is based on the 1997 release, so we'll have to
# do something about it ourself
# 
# to fix this, we alter the script ID for the dresser
# so that it targets script 0x12 instead of 0x14.
# this is a very esoteric operation and i don't expect to have to
# repeat it, so i've taken a very blunt and ugly route here.
#
# this bug was concealed thanks to the fact that card 22 is bugged and
# awards itself twice, so collecting the 41 cards actually available
# still resulted in credit for 42 of them and being able to purchase
# everything at the trade shop, which fooled the testers into
# thinking everything was okay.
# card 22 has also been fixed for the patch (see pom_scriptbuild)
datpatch "out/rsrc_raw/special/moon_house_mapstuff.bin" "out/rsrc_raw/special/moon_house_mapstuff.bin" "out/rsrc_raw/special/cardfix_patch.bin" 0x85F4
rux_cmp "out/rsrc_raw/special/moon_house_mapstuff.bin" "out/rsrc_raw/special/moon_house_mapstuff_cmp.bin"
datpatch "out/files/GRAPHIC/MAP.PAK" "out/files/GRAPHIC/MAP.PAK" "out/rsrc_raw/special/moon_house_mapstuff_cmp.bin" 0x213D800

echo "*******************************************************************************"
echo "Building ASM..."
echo "*******************************************************************************"

mkdir -p out/asm

# copy original executables
cp "out/files/SLPS_008.17" "out/asm"
cp "out/files/MAIN.EXE" "out/asm"
cp "out/files/POM_END.EXE" "out/asm"

# build  
$ARMIPS asm/pom.asm -temp out/asm/temp.txt -sym out/asm/symbols.sym -sym2 out/asm/symbols.sym2
$ARMIPS asm/pom_op.asm -temp out/asm/temp_op.txt -sym out/asm/symbols_op.sym -sym2 out/asm/symbols_op.sym2
$ARMIPS asm/pom_end.asm -temp out/asm/temp_end.txt -sym out/asm/symbols_end.sym -sym2 out/asm/symbols_end.sym2

# copy to output folder
cp "out/asm/SLPS_008.17" "out/files"
cp "out/asm/MAIN.EXE" "out/files"
cp "out/asm/POM_END.EXE" "out/files"

echo "*******************************************************************************"
echo "Packing archives..."
echo "*******************************************************************************"

pom_pakrux "out/rsrc_raw/pak/STD1/" "out/files/GRAPHIC/STD1.PAK"
pom_pakrux "out/rsrc_raw/pak/STD2/" "out/files/GRAPHIC/STD2.PAK"
pom_pakrux "out/rsrc_raw/pak/OP1/" "out/files/GRAPHIC/OP1.PAK"

if [ ! $ENDING_DEBUG_ON == 0 ]; then

  echo "*******************************************************************************"
  echo " *** ENABLING ENDING DEBUG ***"
  echo "*******************************************************************************"
  
  cp "rsrc_raw/ed_debug/SYSTEM.CNF" "out/files"

fi

echo "*******************************************************************************"
echo "Building disc..."
echo "*******************************************************************************"

$DISCASTER "pom.dsc"

echo "*******************************************************************************"
echo "Success!"
echo "*******************************************************************************"
