#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TSort.h"
#include "util/TGraphic.h"
#include "util/TColor.h"
#include "util/TPngConversion.h"
#include "util/TBitmapFont.h"
#include "util/TThingyTable.h"
#include "util/TParse.h"
#include "exception/TException.h"
#include "exception/TGenericException.h"
#include "dandy/DandyPac.h"
#include "dandy/DandyScriptScanner.h"
#include <algorithm>
#include <vector>
#include <string>
#include <map>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <cmath>

using namespace std;
using namespace BlackT;
//using namespace Discaster;
using namespace Psx;
  
TThingyTable table;

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

bool checkString(TStream& ifs) {
  if (ifs.peek() == 0x00) return false;
  
  int pos = ifs.tell();
  
  ostringstream oss;
  
  while (!ifs.eof()) {
    if (ifs.peek() == 0x00) {
      ifs.get();
      cout << "#string("
        << TStringConversion::intToString(pos,
            TStringConversion::baseHex)
        << ")"
        << endl;
      cout << oss.str() << endl << endl;
      return true;
    }
    
    TThingyTable::MatchResult result = table.matchId(ifs);
    if (result.id == -1) break;
    
    oss << table.getEntry(result.id);
    
    // HACK
    if (table.getEntry(result.id).compare("\\n") == 0) {
      oss << endl;
    }
  }
  
  return false;
}

int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "String searcher" << endl;
    cout << "Usage: " << argv[0] << " <infile> <table>" << endl;
    return 0;
  }
  
  std::string infileName(argv[1]);
  std::string tableName(argv[2]);

  TBufStream ifs;
  ifs.open(infileName.c_str());
  
  table.readSjis(tableName.c_str());
  
  while (!ifs.eof()) {
    int basepos = ifs.tell();
    bool result = checkString(ifs);
    if (!result) {
      ifs.seek(basepos + 1);
      continue;
    }
  }
  
  return 0;
}
