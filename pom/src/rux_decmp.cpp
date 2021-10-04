#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
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
    cout << "RUX decompressor" << endl;
    cout << "Usage: " << argv[0] << " <infile> <outfile>" << endl;
    
    return 1;
  }
  
  string infileName(argv[1]);
  string outfileName(argv[2]);
  
  TBufStream ifs;
  ifs.open(infileName.c_str());
  
  TBufStream ofs;
  
  PomCmp::decmpRux(ifs, ofs);
  
  ofs.save(outfileName.c_str());
  
  return 0;
}
