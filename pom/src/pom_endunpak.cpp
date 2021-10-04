#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TGraphic.h"
#include "util/TColor.h"
#include "util/TPngConversion.h"
#include "exception/TException.h"
#include "exception/TGenericException.h"
#include <vector>
#include <string>
#include <map>
#include <iostream>

using namespace std;
using namespace BlackT;

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
    std::cout << "Community Pom ending archive extractor" << std::endl;
    std::cout << "Usage: " << argv[0] << " <infile> <outprefix>" << std::endl;
    return 0;
  }
  
  std::string inFile = std::string(argv[1]);
  std::string outPrefix = std::string(argv[2]);
  
  TBufStream ifs;
  ifs.open(inFile.c_str());
  
  while (true) {
    int basePos = ifs.tell();
    std::string name;
    ifs.readCstrString(name, 0x10);
    if (name.empty()) break;
    
    ifs.seek(basePos + 0x10);
    int offset = ifs.readu32le();
    int size = ifs.readu32le();
    
//    std::cout << name << " " << offset << " " << size << std::endl;
    
    ifs.seek(offset);
    TBufStream temp;
    temp.writeFrom(ifs, size);
    temp.save((outPrefix + name).c_str());
    
    ifs.seek(basePos + 0x18);
  }
  
  return 0;
}
