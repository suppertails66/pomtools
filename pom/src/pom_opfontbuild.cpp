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

int main(int argc, char* argv[]) {
  if (argc < 4) {
    cout << "Community Pom OP font builder" << endl;
    cout << "Usage: " << argv[0] << " <font> <outwidthfile> <outkerningfile>"
      << " [hacktype]"
      << endl;
    
    return 0;
  }
  
  string fontName(argv[1]);
  string outWidthFileName(argv[2]);
  string outKerningFileName(argv[3]);
  string hackType = "";
  if (argc >= 5) hackType = string(argv[4]);
  
  TBitmapFont font;
  font.load(fontName);
  
  // apply font-specific hacks
  if (hackType.compare("op") == 0) {
    // "fu"
    font.offsetKerning(0x2A, 0x39, -1);
    // "Ta"
    font.offsetKerning(0x1E, 0x25, -1);
    // "Ka"
//    font.offsetKerning(0x15, 0x25, -1);
    // "Wa"
    font.offsetKerning(0x21, 0x25, -1);
    // "Fi"
    font.offsetKerning(0x10, 0x2D, -1);
  }
  
  TBufStream widthofs;
  
  int maxChars = font.numFontChars();
  
  for (int i = 0; i < maxChars; i++) {
//  for (int i = 0; i < font.numFontChars(); i++) {
    const TBitmapFontChar& fontChar = font.fontChar(i);
    
    int width = fontChar.advanceWidth;
    widthofs.writeu8(width);
  }
  
  widthofs.save(outWidthFileName.c_str());
  
  TBufStream kerningOfs;
  font.exportKerningMatrix(kerningOfs);
  kerningOfs.save(outKerningFileName.c_str());
  
  return 0;
}
