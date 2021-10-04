
set -o errexit

tempFontFile=".fontrender_temp"



function renderString() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
  ./fontrender "font/" "$tempFontFile" "font/table.tbl" "$1.png"
}

function renderStringOp() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
  ./fontrender "font/op/" "$tempFontFile" "font/op/table.tbl" "$1.png"
}

function renderStringEnd() {
  printf "$2" > $tempFontFile
  
#  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
  ./fontrender "font/end/" "$tempFontFile" "font/end/table.tbl" "$1.png"
}

# function renderStringNarrow() {
#   printf "$2" > $tempFontFile
#   
# #  ./fontrender "font/12px_outline/" "$tempFontFile" "font/12px_outline/table.tbl" "$1.png"
#   ./fontrender "rsrc/font/" "$tempFontFile" "table/dandy_en_narrow.tbl" "$1.png"
# }



make blackt && make fontrender

#renderString intro_render_1 "1999. Mankind is attacked by superweapons of unknown origin."
#renderString intro_render_2 "Four robots, appearing suddenly out of nowhere."
#renderString intro_render_3 "Are they a country's secret weapons? The start of an alien invasion?"
#renderString intro_render_4 "The identity of these mysterious robots remains unknown..."

#renderString test_render "Village City Nation"

#renderStringOp test_render "Fill in Cafe Co., Ltd."
renderStringEnd test_render "saiteta hana sae mo"

rm $tempFontFile