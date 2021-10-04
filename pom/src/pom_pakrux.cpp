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

std::string getInName(std::string prefix, int num) {
  std::string inname = prefix
    + TStringConversion::intToString(num)
    + ".bin";
  return inname;
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Pom PAK packer" << endl;
    cout << "Usage: " << argv[0] << " <inprefix> <outfile> [numfiles]"
      << endl;
    
    return 1;
  }
  
  string inprefixName(argv[1]);
  string outfileName(argv[2]);
  
  int numFiles = -1;
  if (argc >= 4)
    numFiles = TStringConversion::stringToInt(std::string(argv[3]));
  else {
    for (numFiles = 0; ; numFiles++) {
      std::string name = getInName(inprefixName, numFiles);
      if (!TFileManip::fileExists(name.c_str())) break;
    }
  }
  
  TBufStream ofs;
  
  // reserve space for index
  ofs.seekoff(numFiles * 4);
  
  int fileNum = 0;
  while (true) {
    std::string inname = getInName(inprefixName, fileNum);
    
    if (numFiles == -1) {
      if (!TFileManip::fileExists(inname.c_str())) break;
    }
    
    TBufStream inifs;
    inifs.open(inname.c_str());
    TBufStream cmpofs;
    PomCmp::cmpRux(inifs, cmpofs);
    cmpofs.seek(0);
    
    int outPos = ofs.tell();
    ofs.seek(fileNum * 4);
    ofs.writeu32le(outPos);
    ofs.seek(outPos);
    
    ofs.writeFrom(cmpofs, cmpofs.size());
    
    ++fileNum;
    if ((numFiles != -1) && (fileNum >= numFiles)) break;
  }
  
  ofs.save(outfileName.c_str());
  
  return 0;
}
