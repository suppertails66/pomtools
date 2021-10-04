#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "exception/TGenericException.h"
#include "pom/PomCmp.h"
#include <string>
#include <iostream>

using namespace std;
using namespace BlackT;
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

string as1bHex(int num) {
  string str = TStringConversion::intToString(num,
                  TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 1) str = string("0") + str;
  
//  return "<$" + str + ">";
  return str;
}

string as2bHexPrefix(int num) {
  return "$" + as2bHex(num) + "";
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Pom PAK extractor" << endl;
    cout << "Usage: " << argv[0] << " <infile> <outprefix>" << endl;
    
    return 1;
  }
  
  string infileName(argv[1]);
  string outprefixName(argv[2]);
  
  TBufStream ifs;
  ifs.open(infileName.c_str());
  
  int firstFilePos = ifs.readu32le();
  int numFiles = firstFilePos / 4;
  
  for (int i = 0; i < numFiles; i++) {
    ifs.seek(i * 4);
    int offset = ifs.readu32le();
    
    int endPos;
    if (i < (numFiles - 1)) {
      int nextOffset = ifs.readu32le();
      endPos = nextOffset;
    }
    else {
      endPos = ifs.size();
    }
    
    int fileSize = endPos - offset;
    
    ifs.seek(offset);
    TBufStream ofs;
    ofs.writeFrom(ifs, fileSize);
    
    TBufStream outofs;
    ofs.seek(0);
    PomCmp::decmpRux(ofs, outofs);
    
    std::string outname = outprefixName
//      + "_"
      + TStringConversion::intToString(i)
      + ".bin";
    TFileManip::createDirectoryForFile(outname.c_str());
    
    outofs.save(outname.c_str());
  }
  
  return 0;
}
