
set -o errexit

make


# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0xFF 0xFF "rsrc_raw/pal/end_font_white.pal" "rsrc_raw/pal/end_font_white.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0x00 0x00 "rsrc_raw/pal/end_font_red.pal" "rsrc_raw/pal/end_font_red.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0x33 0x33 "rsrc_raw/pal/end_font_fade1.pal" "rsrc_raw/pal/end_font_fade1.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0x66 0x66 "rsrc_raw/pal/end_font_fade2.pal" "rsrc_raw/pal/end_font_fade2.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0x99 0x99 "rsrc_raw/pal/end_font_fade3.pal" "rsrc_raw/pal/end_font_fade3.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0xCC 0xCC "rsrc_raw/pal/end_font_fade4.pal" "rsrc_raw/pal/end_font_fade4.png"

# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0xFF 0xFF "rsrc_raw/pal/end_font_white.pal" "rsrc_raw/pal/end_font_white.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x00 0x77 0xFF "rsrc_raw/pal/end_font_karaoke_fg.pal" "rsrc_raw/pal/end_font_karaoke_bg.png"
# #./pom_genchrompal 0x00 0x00 0x00 0xFF 0x77 0x00 "rsrc_raw/pal/end_font_karaoke_fg.pal" "rsrc_raw/pal/end_font_karaoke_fg.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xDD 0xDD 0x00 "rsrc_raw/pal/end_font_karaoke_bg.pal" "rsrc_raw/pal/end_font_karaoke_fg.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xDC 0xDD 0x33 "rsrc_raw/pal/end_font_fade1.pal" "rsrc_raw/pal/end_font_fade1.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xA5 0xC2 0x66 "rsrc_raw/pal/end_font_fade2.pal" "rsrc_raw/pal/end_font_fade2.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x6E 0xA9 0x99 "rsrc_raw/pal/end_font_fade3.pal" "rsrc_raw/pal/end_font_fade3.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x37 0x90 0xCC "rsrc_raw/pal/end_font_fade4.pal" "rsrc_raw/pal/end_font_fade4.png"

# ./pom_genchrompal 0x00 0x00 0x00 0xFF 0xFF 0xFF "rsrc_raw/pal/end_font_white.pal" "rsrc_raw/pal/end_font_white.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xDD 0xDD 0x00 "rsrc_raw/pal/end_font_karaoke_bg.pal" "rsrc_raw/pal/end_font_karaoke_fg.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x00 0x99 0xFF "rsrc_raw/pal/end_font_karaoke_fg.pal" "rsrc_raw/pal/end_font_karaoke_bg.png"
# ./pom_genchrompal 0x00 0x00 0x00 0xB0 0xCD 0x33 "rsrc_raw/pal/end_font_fade1.pal" "rsrc_raw/pal/end_font_fade1.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x84 0xC0 0x66 "rsrc_raw/pal/end_font_fade2.pal" "rsrc_raw/pal/end_font_fade2.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x58 0xB3 0x99 "rsrc_raw/pal/end_font_fade3.pal" "rsrc_raw/pal/end_font_fade3.png"
# ./pom_genchrompal 0x00 0x00 0x00 0x2C 0xA6 0xCC "rsrc_raw/pal/end_font_fade4.pal" "rsrc_raw/pal/end_font_fade4.png"
# exit

function remapPalette() {
  oldFile=$1
  palFile=$2
  newFile=$3
  
  if [ "$newFile" == "" ]; then
    newFile=$oldFile
  fi
  
  convert "$oldFile" -dither None -remap "$palFile" PNG32:$newFile
}

# remapPalette "rsrc/grp/map48_res9_pal494.png" "rsrc/grp/orig/map48_res9_pal494.png"
# exit

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

# #remapPalette "out/rsrc/grp/map5_res9_pal454.png" "out/rsrc/grp/orig/map5_res9_pal454.png"
# #remapPalette "rsrc/grp/map5_res9_pal454.png" "rsrc/grp/map5_res9_pal454_remap_grad.png"
# #remapPalette "rsrc/grp/map5_res9_pal454.png" "rsrc/grp/map5_res9_pal454_remap_outline.png"
# remapPalette "rsrc/grp/map5_res9_pal454.png" "rsrc/grp/map5_res9_pal454_orig.png"
# remapPalette "rsrc/grp/map21_res9_pal474.png" "rsrc/grp/map5_res9_pal454_remap_outlineglow.png"
# remapPalette "rsrc/grp/map39_res9_pal454.png" "rsrc/grp/map5_res9_pal454_remap_outlineglow.png"
# remapPalette "font/end/sheet.png" "rsrc_raw/pal/end_font_white.png"
# exit






mkdir -p rsrc_raw/pak
mkdir -p rsrc_raw/endpak

./pom_unpakrux "disc/files/GRAPHIC/STD0.PAK" "rsrc_raw/pak/STD0/"
./pom_unpakrux "disc/files/GRAPHIC/STD1.PAK" "rsrc_raw/pak/STD1/"
./pom_unpakrux "disc/files/GRAPHIC/STD2.PAK" "rsrc_raw/pak/STD2/"
./pom_unpakrux "disc/files/GRAPHIC/OP0.PAK" "rsrc_raw/pak/OP0/"
./pom_unpakrux "disc/files/GRAPHIC/OP1.PAK" "rsrc_raw/pak/OP1/"
./pom_unpakrux "disc/files/GRAPHIC/OP2.PAK" "rsrc_raw/pak/OP2/"

./pom_endunpak "disc/files/PICT/POM_END.PCK" "rsrc_raw/endpak/"

mkdir -p rsrc/grp
mkdir -p rsrc/grp/orig
#mkdir -p rsrc/grp/orig/rawsheets
mkdir -p rsrc_raw/pal

#========================
# OP1 5
#========================

./psx_rawimg_extr "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/op1_5.png" 256 256 4 -i 0x220

# title logo is internally split into 3 pieces vertically in order to achieve
# a gradient effect with 4bpp graphics.
# it's about as awful as it sounds.
./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/title_logo_upper.png" 4 -paloffset 0x54 -crop 0 80 160 32
./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/title_logo_middle.png" 4 -paloffset 0x74 -crop 0 112 160 32
./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/title_logo_lower.png" 4 -paloffset 0x94 -crop 0 144 160 48

./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/title_start.png" 4 -paloffset 0xB4 -crop 48 64 144 16

./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/op_font_ref_normal.png" 4 -paloffset 0x14
./psx_img_colorize "rsrc/grp/orig/op1_5.png" "rsrc_raw/pak/OP1/5.bin" "rsrc/grp/orig/op_font_ref_header.png" 4 -paloffset 0x34

#========================
# STD1 7
#========================

./psx_rawimg_extr "rsrc_raw/pak/STD1/7.bin" "rsrc/grp/orig/std1_7.png" 256 256 4 -i 0x220

# menu options
./datsnip "rsrc_raw/pak/STD1/7.bin" 0x94 0x20 "rsrc_raw/pal/std1_7_4.bin"
# community status icons
./datsnip "rsrc_raw/pak/STD1/7.bin" 0x154 0x20 "rsrc_raw/pal/std1_7_A.bin"

./psx_img_colorize "rsrc/grp/orig/std1_7.png" "rsrc_raw/pal/std1_7_4.bin" "rsrc/grp/orig/std1_7_pal4.png" 4
./psx_img_colorize "rsrc/grp/orig/std1_7.png" "rsrc_raw/pal/std1_7_A.bin" "rsrc/grp/orig/std1_7_palA.png" 4

#========================
# STD2 0
#========================

./psx_rawimg_extr "rsrc_raw/pak/STD2/0.bin" "rsrc/grp/orig/std2_0.png" 256 256 4 -i 0x220

# most stuff
./datsnip "rsrc_raw/pak/STD2/0.bin" 0x34 0x20 "rsrc_raw/pal/std2_0_1.bin"
# kaisan/shuugou
./datsnip "rsrc_raw/pak/STD2/0.bin" 0xD4 0x20 "rsrc_raw/pal/std2_0_6.bin"
# text options
./datsnip "rsrc_raw/pak/STD2/0.bin" 0x1D4 0x20 "rsrc_raw/pal/std2_0_E.bin"

./psx_img_colorize "rsrc/grp/orig/std2_0.png" "rsrc_raw/pal/std2_0_1.bin" "rsrc/grp/orig/std2_0_pal1.png" 4
./psx_img_colorize "rsrc/grp/orig/std2_0.png" "rsrc_raw/pal/std2_0_6.bin" "rsrc/grp/orig/std2_0_pal6.png" 4
./psx_img_colorize "rsrc/grp/orig/std2_0.png" "rsrc_raw/pal/std2_0_E.bin" "rsrc/grp/orig/std2_0_palE.png" 4

#========================
# STD2 4/5 (font)
#========================

./psx_rawimg_extr "rsrc_raw/pak/STD2/4.bin" "rsrc/grp/orig/font1.png" 256 256 4 -i 0x220
./psx_rawimg_extr "rsrc_raw/pak/STD2/5.bin" "rsrc/grp/orig/font2.png" 256 256 4 -i 0x220

#===================================================================
# minigames
#===================================================================

#========================
# map 5
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/5/resources/9.bin" "rsrc/grp/orig/map5_res9.png" 256 256 4 -i 0x0

./datsnip "rsrc_raw/maps_decompressed/5/resources/0.bin" 0x454 0x20 "rsrc_raw/pal/map5_res9_pal454.bin"
./datsnip "rsrc_raw/maps_decompressed/5/resources/0.bin" 0x4D4 0x20 "rsrc_raw/pal/map5_res9_pal4D4.bin"

./psx_img_colorize "rsrc/grp/orig/map5_res9.png" "rsrc_raw/pal/map5_res9_pal454.bin" "rsrc/grp/orig/map5_res9_pal454.png" 4
./psx_img_colorize "rsrc/grp/orig/map5_res9.png" "rsrc_raw/pal/map5_res9_pal4D4.bin" "rsrc/grp/orig/map5_res9_pal4D4.png" 4

#========================
# map 18
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/18/resources/9.bin" "rsrc/grp/orig/map18_res9.png" 256 256 4 -i 0x0

./datsnip "rsrc_raw/maps_decompressed/18/resources/0.bin" 0x454 0x20 "rsrc_raw/pal/map18_res9_pal454.bin"

./psx_img_colorize "rsrc/grp/orig/map18_res9.png" "rsrc_raw/pal/map18_res9_pal454.bin" "rsrc/grp/orig/map18_res9_pal454.png" 4

#========================
# map 21
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/21/resources/9.bin" "rsrc/grp/orig/map21_res9.png" 256 256 4 -i 0x0

./datsnip "rsrc_raw/maps_decompressed/21/resources/0.bin" 0x474 0x20 "rsrc_raw/pal/map21_res9_pal474.bin"

./psx_img_colorize "rsrc/grp/orig/map21_res9.png" "rsrc_raw/pal/map21_res9_pal474.bin" "rsrc/grp/orig/map21_res9_pal474.png" 4

#========================
# map 39
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/39/resources/9.bin" "rsrc/grp/orig/map39_res9.png" 256 256 4 -i 0x0

./datsnip "rsrc_raw/maps_decompressed/39/resources/0.bin" 0x454 0x20 "rsrc_raw/pal/map39_res9_pal454.bin"

./psx_img_colorize "rsrc/grp/orig/map39_res9.png" "rsrc_raw/pal/map39_res9_pal454.bin" "rsrc/grp/orig/map39_res9_pal454.png" 4

#===================================================================
# misc maps
#===================================================================

#========================
# map 12 (splashire dungeon)
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/12/resources/9.bin" "rsrc/grp/orig/map12_res9.png" 256 256 4 -i 0x0

./datsnip "rsrc_raw/maps_decompressed/12/resources/0.bin" 0x4F4 0x20 "rsrc_raw/pal/map12_res9_pal4F4.bin"

./psx_img_colorize "rsrc/grp/orig/map12_res9.png" "rsrc_raw/pal/map12_res9_pal4F4.bin" "rsrc/grp/orig/map12_res9_pal4F4.png" 4

#========================
# map 45 (desert tower)
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/45/resources/9.bin" "rsrc/grp/orig/map45_res9.png" 256 256 4 -i 0x0

#========================
# map 48 (desert minidungeon)
#========================

./psx_rawimg_extr "rsrc_raw/maps_decompressed/48/resources/9.bin" "rsrc/grp/orig/map48_res9.png" 256 256 4 -i 0x0
./datsnip "rsrc_raw/maps_decompressed/48/resources/0.bin" 0x494 0x20 "rsrc_raw/pal/map48_res9_pal494.bin"
./psx_img_colorize "rsrc/grp/orig/map48_res9.png" "rsrc_raw/pal/map48_res9_pal494.bin" "rsrc/grp/orig/map48_res9_pal494.png" 4

#===================================================================
# ending
#===================================================================

mkdir -p temp



# function extrcolorize() {
#   infile=$1
#   width=$2
#   height=$3
#   bpp=$4
#   paloffset=$5
#   
#   if [ "$paloffset" = "" ]; then
#     paloffset=0x14
#   fi
#   
#   outfile=temp/$(basename $infile .TIM).png
# 
#   ./psx_rawimg_extr "$infile" "$outfile" $width $height $bpp -i 0x220
#   ./psx_img_colorize "$outfile" "$infile" "$outfile" $bpp -paloffset $paloffset
# }
# 
# for file in rsrc_raw/endpak/ENDING_*.TIM; do
#   extrcolorize "$file" 0x80 0xF0 8
# done
# 
# extrcolorize "rsrc_raw/endpak/BG00ED_0.TIM" 0x70 0x90 4 0x94
# extrcolorize "rsrc_raw/endpak/BG00ED_1.TIM" 0x70 0x90 4 0x94
# extrcolorize "rsrc_raw/endpak/BG00ED_2.TIM" 0x70 0x90 4 0x94
# extrcolorize "rsrc_raw/endpak/BG00ED_3.TIM" 0x70 0x90 4 0x94
# extrcolorize "rsrc_raw/endpak/BG00ED_4.TIM" 0x70 0x90 4 0x94
# extrcolorize "rsrc_raw/endpak/BG00ED_5.TIM" 0x100 0x100 8
# extrcolorize "rsrc_raw/endpak/NOWLOAD.TIM" 0x100 0x100 8
# # extrcolorize "disc/files/GRAPHIC/NOWLOAD.TIM" 0x100 0x100 8


./psx_rawimg_extr "rsrc_raw/endpak/BG00ED_T.TIM" "rsrc/grp/orig/BG00ED_T.png" 0x100 0x100 4 -i 0x220
./psx_img_colorize "rsrc/grp/orig/BG00ED_T.png" "rsrc_raw/endpak/BG00ED_T.TIM" "rsrc/grp/orig/BG00ED_T_pal14.png" 4 -paloffset 0x14

./psx_rawimg_extr "rsrc_raw/endpak/END_0.TIM" "rsrc/grp/orig/END_0.png" 0x100 0x100 4 -i 0x220
./psx_img_colorize "rsrc/grp/orig/END_0.png" "rsrc_raw/endpak/END_0.TIM" "rsrc/grp/orig/END_0_pal14.png" 4 -paloffset 0x14

./psx_rawimg_extr "rsrc_raw/endpak/END_1.TIM" "rsrc/grp/orig/END_1.png" 0x100 0x100 4 -i 0x220
./psx_img_colorize "rsrc/grp/orig/END_1.png" "rsrc_raw/endpak/END_1.TIM" "rsrc/grp/orig/END_1_pal54.png" 4 -paloffset 0x54

# ./psx_rawimg_extr "rsrc_raw/endpak/BG00ED_5.TIM" "rsrc/grp/orig/BG00ED_5.png" 0x100 0x100 8 -i 0x220
# ./psx_img_colorize "rsrc/grp/orig/BG00ED_5.png" "rsrc_raw/endpak/BG00ED_5.TIM" "rsrc/grp/orig/BG00ED_5_color.png" 8 -paloffset 0x14

# ./psx_rawimg_extr "rsrc_raw/endpak/NOWLOAD.TIM" "rsrc/grp/orig/end_NOWLOAD.png" 0x100 0x100 8 -i 0x220
# ./psx_img_colorize "rsrc/grp/orig/end_NOWLOAD.png" "rsrc_raw/endpak/NOWLOAD.TIM" "rsrc/grp/orig/end_NOWLOAD_color.png" 8 -paloffset 0x14

./psx_rawimg_extr "rsrc_raw/endpak/SPRITE.TIM" "rsrc/grp/orig/end_SPRITE.png" 0x100 0x100 8 -i 0x220
./psx_img_colorize "rsrc/grp/orig/end_SPRITE.png" "rsrc_raw/endpak/SPRITE.TIM" "rsrc/grp/orig/end_SPRITE_color.png" 8 -paloffset 0x14
