#include "psx/PsxPalette.h"
#include "util/TGraphic.h"
#include "util/TPngConversion.h"
#include "util/TIniFile.h"
#include "util/TBufStream.h"
#include "util/TOfstream.h"
#include "util/TIfstream.h"
#include "util/TStringConversion.h"
#include "util/TBitmapFont.h"
#include "util/TOpt.h"
#include "util/MiscMath.h"
#include <iostream>
#include <vector>

using namespace std;
using namespace BlackT;
using namespace Psx;

const int numColors = 16;
const int previewBlockW = 16;
const int previewBlockH = 16;

int main(int argc, char* argv[]) {
  if (argc < 9) {
    cout << "4-bit chromatic palette generator" << endl;
    cout << "Usage: " << argv[0]
      << " <minR> <minG> <minB> <maxR> <maxG> <maxB> <outpal> <outimg>"
      << endl;
    cout << "Options:" << endl;
    cout << "   --trans     Force slot 0 to transparent" << endl;
    
    return 0;
  }
  
  int minR = TStringConversion::stringToInt(std::string(argv[1]));
  int minG = TStringConversion::stringToInt(std::string(argv[2]));
  int minB = TStringConversion::stringToInt(std::string(argv[3]));
  int maxR = TStringConversion::stringToInt(std::string(argv[4]));
  int maxG = TStringConversion::stringToInt(std::string(argv[5]));
  int maxB = TStringConversion::stringToInt(std::string(argv[6]));
  std::string outPalName(argv[7]);
  std::string outImgName(argv[8]);
  
//  TOpt::readNumericOpt(argc, argv, "-paloffset", &palOffset);

  bool transparency = false;
  if (TOpt::hasFlag(argc, argv, "--trans")) {
    transparency = true;
  }
  
  int rRange = maxR - minR;
  int gRange = maxG - minG;
  int bRange = maxB - minB;
  double rFactor = (double)rRange / (double)(numColors - 1);
  double gFactor = (double)gRange / (double)(numColors - 1);
  double bFactor = (double)bRange / (double)(numColors - 1);
  
  PsxPalette pal;
  TGraphic grp(previewBlockW * numColors, previewBlockH);
  grp.clearTransparent();
  for (int i = 0; i < numColors; i++) {
    int r = minR + (rFactor * i);
    int g = minG + (gFactor * i);
    int b = minB + (bFactor * i);
    
    MiscMath::clamp(r, 0, 255);
    MiscMath::clamp(g, 0, 255);
    MiscMath::clamp(b, 0, 255);
    
    TColor color(r, g, b);
    PsxColor psxColor;
    psxColor.fromTColor(color);
    
    if (transparency && (i == 0)) psxColor.fromNativeColor(0);
    
    pal.setColor(i, psxColor);
    
    if (!(transparency && (i == 0))) {
      grp.fillRect(i * previewBlockW, 0, previewBlockW, previewBlockH,
                   psxColor.asTColor());
    }
  }
  
  TBufStream ofs;
  pal.write(ofs, numColors);
  ofs.save(outPalName.c_str());
  
  TPngConversion::graphicToRGBAPng(outImgName, grp);
  
  return 0;
}
