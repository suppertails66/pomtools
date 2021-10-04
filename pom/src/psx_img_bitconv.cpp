#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TSort.h"
#include "util/TGraphic.h"
#include "util/TPngConversion.h"
#include "exception/TException.h"
#include "exception/TGenericException.h"
#include "psx/PsxBitmap.h"
#include <algorithm>
#include <vector>
#include <string>
#include <iostream>
#include <iomanip>
#include <cmath>

using namespace std;
using namespace BlackT;
//using namespace Discaster;
using namespace Psx;

string as3bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 3) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHexPrefix(int num) {
  return "$" + as2bHex(num) + "";
}

PsxBitmap::Format getFormatOfNumber(int num) {
  switch (num) {
  case 16:
    return PsxBitmap::format_rgb;
    break;
  case 2:
    return PsxBitmap::format_2bit;
    break;
  case 4:
    return PsxBitmap::format_4bit;
    break;
  case 8:
    return PsxBitmap::format_8bit;
    break;
  default:
    throw TGenericException(T_SRCANDLINE,
                            "getFormatOfNumber()",
                            std::string("Unknown format code: ")
                            + TStringConversion::intToString(num));
    break;
  }
}

int main(int argc, char* argv[]) {
  if (argc < 5) {
    cout << "PlayStation image bit width converter" << endl;
    cout << "Usage: " << argv[0] << " [infile] [outfile] [inwidth] [outwidth]" << endl;
    cout << "Input images must be grayscale." << endl;
    cout << "Supported widths are 2, 4, 8, and 16 (RGB)." << endl;
    
    return 0;
  }
  
  string inFile(argv[1]);
  string outFile(argv[2]);
  int inWidth = TStringConversion::stringToInt(std::string(argv[3]));
  int outWidth = TStringConversion::stringToInt(std::string(argv[4]));
  
  PsxBitmap::Format inFormat = getFormatOfNumber(inWidth);
  PsxBitmap::Format outFormat = getFormatOfNumber(outWidth);
  PsxBitmap img;
  
  // read image
  img.setFormat(inFormat);
  {
    TGraphic grp;
    TPngConversion::RGBAPngToGraphic(inFile, grp);
    img.fromGrayscaleGraphic(grp);
  }
  
  // convert to raw data
//  img.setFormat(outFormat);
  TBufStream raw;
  img.writePixelData(raw);
  raw.seek(0);
  
  // read back in target format
  PsxBitmap convertedImg;
  // ratio of old image width to new
  double scaleFactor = (double)inWidth / (double)outWidth;
  convertedImg.readPixelData(raw, outFormat,
                             (double)img.w() * scaleFactor, img.h());
  
  // save as graphic
  {
    TGraphic grp;
    if (outFormat == PsxBitmap::format_rgb) {
      convertedImg.toGraphic(grp, true, false);
    }
    else {
      convertedImg.toGrayscaleGraphic(grp);
    }
    TPngConversion::graphicToRGBAPng(outFile, grp);
  }
  
  return 0;
}
