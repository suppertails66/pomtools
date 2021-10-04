#include "util/TGraphic.h"
#include "util/TPngConversion.h"
#include "util/TIniFile.h"
#include "util/TBufStream.h"
#include "util/TOfstream.h"
#include "util/TIfstream.h"
#include "util/TStringConversion.h"
#include "util/TBitmapFont.h"
#include <iostream>
#include <vector>

using namespace std;
using namespace BlackT;

const static int charW = 12;
const static int charH = 12;

void charToData(const TGraphic& src,
                int xOffset, int yOffset,
                TStream& ofs) {
  for (int j = 0; j < charH; j++) {
    
/*    for (int i = 0; i < charW / 2; i++) {
      int x = xOffset + (i * 2);
      int y = yOffset + j;
      TColor color1 = src.getPixel(x + 0, y);
      TColor color2 = src.getPixel(x + 1, y);
      
      int output = 0;
      if ((color1.a() != TColor::fullAlphaTransparency))
        output |= ((color1.r() / 16) << 0);
      if ((color2.a() != TColor::fullAlphaTransparency))
        output |= ((color2.r() / 16) << 4);
      
      ofs.writeu8(output);
    } */
    
    for (int i = 0; i < charW / 4; i++) {
      int x = xOffset + (i * 4);
      int y = yOffset + j;
      TColor color1 = src.getPixel(x + 0, y);
      TColor color2 = src.getPixel(x + 1, y);
      TColor color3 = src.getPixel(x + 2, y);
      TColor color4 = src.getPixel(x + 3, y);
      
      int output = 0;
      if ((color1.a() != TColor::fullAlphaTransparency))
        output |= ((color1.r() / 16) << 0);
      if ((color2.a() != TColor::fullAlphaTransparency))
        output |= ((color2.r() / 16) << 4);
      if ((color3.a() != TColor::fullAlphaTransparency))
        output |= ((color3.r() / 16) << 8);
      if ((color4.a() != TColor::fullAlphaTransparency))
        output |= ((color4.r() / 16) << 12);
      
      ofs.writeu16le(output);
    }
    
    // output a word of padding: this is used when compositing
    // a new character with existing content
    ofs.writeu16le(0);
  }
}

int main(int argc, char* argv[]) {
  if (argc < 4) {
    cout << "Community Pom font builder" << endl;
    cout << "Usage: " << argv[0] << " <font> <maxchars> <outfontfile>"
      << " <outwidthfile>"
      << endl;
    
    return 0;
  }
  
  string fontName(argv[1]);
//  string outFontFileName(argv[2]);
  int maxChars = TStringConversion::stringToInt(string(argv[2]));
  string outFontFileName(argv[3]);
  string outWidthFileName(argv[4]);
  
  TBitmapFont font;
  font.load(fontName);
  
  TBufStream fontofs;
  TBufStream widthofs;
  
  if (font.numFontChars() < maxChars) maxChars = font.numFontChars();
  
  for (int i = 0; i < maxChars; i++) {
//  for (int i = 0; i < font.numFontChars(); i++) {
    const TBitmapFontChar& fontChar = font.fontChar(i);
    
    int width = fontChar.advanceWidth;
    fontofs.writeu32le(width);
    widthofs.writeu8(width);
    charToData(fontChar.grp, 0, 0, fontofs);
    
    // align to 128-byte boundary for insertion into bitmap
    fontofs.alignToBoundary(128);
  }
  
  fontofs.save(outFontFileName.c_str());
  widthofs.save(outWidthFileName.c_str());
  
  return 0;
}
