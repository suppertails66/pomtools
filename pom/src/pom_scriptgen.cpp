#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TStringConversion.h"
#include "util/TThingyTable.h"
#include "util/TFileManip.h"
#include "util/TStringSearch.h"
#include "exception/TGenericException.h"
#include "pom/PomCmp.h"
#include "pom/PomMapData.h"
#include "pom/PomPlmData.h"
#include "pom/PomTranslationSheet.h"
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

//const static unsigned int mainExeLoadAddr = 0x8000F800;
const static unsigned int mainExeBaseAddr = 0x80010000;
const static unsigned int mapDataOffsetTableAddr = 0x8012335C;
const static unsigned int numMaps = 0x46;

TThingyTable tableScript;
TThingyTable tableFixed;
TThingyTable tableSjis;
TThingyTable tableEnd;

class PomGenericString {
public:
  enum Type {
    type_none,
    type_string,
    type_mapString,
    type_setRegion,
    type_setMap,
    type_setNotCompressible,
    type_addOverwrite,
    type_genericLine,
    type_comment,
    type_marker
  };
  
  Type type;
  
  std::string content;
  int offset;
  int size;
  
  std::string idOverride;
  
  int scriptRefStart;
  int scriptRefEnd;
  int scriptRefCode;
  
  int regionId;
  
  int mapMainId;
  int mapSubId;
  
  bool notCompressible;
  
  std::vector<int> pointerRefs;
//  int pointerBaseAddr;

  std::string translationPlaceholder;
  
  std::vector<int> overwriteAddresses;
  
protected:
  
};

typedef std::vector<PomGenericString> PomGenericStringCollection;

class PomGenericStringSet {
public:
    
  PomGenericStringCollection strings;
  
  static PomGenericString readString(TStream& src, const TThingyTable& table,
                              int offset) {
    PomGenericString result;
    result.type = PomGenericString::type_string;
    result.offset = offset;
    
    src.seek(offset);
    while (!src.eof()) {
      if (src.peek() == 0x00) {
        src.get();
        result.size = src.tell() - offset;
        return result;
      }
      
      TThingyTable::MatchResult matchCheck
        = table.matchId(src);
      if (matchCheck.id == -1) break;
      
      std::string newStr = table.getEntry(matchCheck.id);
      result.content += newStr;
      
      // HACK
      if (newStr.compare("\\n") == 0) result.content += "\n";
    }
    
    throw TGenericException(T_SRCANDLINE,
                            "PomGenericStringSet::readString()",
                            std::string("bad string at ")
                            + TStringConversion::intToString(offset));
  }
  
  void addString(TStream& src, const TThingyTable& table,
                 int offset) {
    PomGenericString result = readString(src, table, offset);
    strings.push_back(result);
  }
  
  void addOverwriteString(TStream& src, const TThingyTable& table,
                 int offset) {
    PomGenericString result = readString(src, table, offset);
    result.overwriteAddresses.push_back(offset);
    strings.push_back(result);
  }
  
  void addMarker(std::string content) {
    PomGenericString result;
    result.type = PomGenericString::type_marker;
    result.content = content;
    strings.push_back(result);
  }
  
  void addPointerTableString(TStream& src, const TThingyTable& table,
                             int offset, int pointerOffset) {
    // check if string already exists, and add pointer ref if so
    for (unsigned int i = 0; i < strings.size(); i++) {
      PomGenericString& checkStr = strings[i];
      // mapStrings need not apply
      if (checkStr.type == PomGenericString::type_string) {
        if (checkStr.offset == offset) {
          checkStr.pointerRefs.push_back(pointerOffset);
          return;
        }
      }
    }
    
    // new string needed
    PomGenericString result = readString(src, table, offset);
    result.pointerRefs.push_back(pointerOffset);
    strings.push_back(result);
  }
  
  void addComment(std::string comment) {
    PomGenericString result;
    result.type = PomGenericString::type_comment;
    result.content = comment;
    strings.push_back(result);
  }
  
  void addSetNotCompressible(bool notCompressible) {
    PomGenericString result;
    result.type = PomGenericString::type_setNotCompressible;
    result.notCompressible = notCompressible;
    strings.push_back(result);
  }
  
  void addAddOverwrite(int offset) {
    PomGenericString result;
    result.type = PomGenericString::type_addOverwrite;
    result.offset = offset;
    strings.push_back(result);
  }
  
  void exportToSheet(
      PomTranslationSheet& dst,
      std::ostream& ofs,
      std::string idPrefix) const {
    int strNum = 0;
    for (unsigned int i = 0; i < strings.size(); i++) {
      const PomGenericString& item = strings[i];
      
      if ((item.type == PomGenericString::type_string)
          || (item.type == PomGenericString::type_mapString)) {
        std::string idString = idPrefix
//          + TStringConversion::intToString(strNum)
//          + "-"
          + TStringConversion::intToString(strings[i].offset,
              TStringConversion::baseHex);
        if (!item.idOverride.empty()) idString = item.idOverride;
        
        dst.addStringEntry(
          idString, item.content, "", "", item.translationPlaceholder);
        
        ofs << "#STARTSTRING("
          << "\"" << idString << "\""
          << ", "
          << TStringConversion::intToString(item.offset,
              TStringConversion::baseHex)
          << ", "
          << TStringConversion::intToString(item.size,
              TStringConversion::baseHex)
          << ")" << endl;
        
        if (item.type == PomGenericString::type_mapString) {
          ofs << "#SETSCRIPTREF("
            << TStringConversion::intToString(item.scriptRefStart,
              TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.scriptRefEnd,
              TStringConversion::baseHex)
            << ", "
            << TStringConversion::intToString(item.scriptRefCode,
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.pointerRefs.size(); i++) {
          ofs << "#ADDPOINTERREF("
            << TStringConversion::intToString(item.pointerRefs[i],
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        for (unsigned int i = 0; i < item.overwriteAddresses.size(); i++) {
          ofs << "#ADDOVERWRITE("
            << TStringConversion::intToString(item.overwriteAddresses[i],
              TStringConversion::baseHex)
            << ")"
            << endl;
        }
        
        ofs << "#IMPORT(\"" << idString << "\")" << endl;
        
        ofs << "#ENDSTRING()" << endl;
        ofs << endl;
        
        ++strNum;
      }
      else if (item.type == PomGenericString::type_setRegion) {
        ofs << "#STARTREGION("
          << item.regionId
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_setMap) {
        ofs << "#SETMAP("
          << item.mapMainId
          << ", "
          << item.mapSubId
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_setNotCompressible) {
        ofs << "#SETNOTCOMPRESSIBLE("
          << (item.notCompressible ? 1 : 0)
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_addOverwrite) {
        ofs << "#ADDOVERWRITE("
          << TStringConversion::intToString(item.offset,
            TStringConversion::baseHex)
          << ")" << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_genericLine) {
        ofs << item.content << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_comment) {
        dst.addCommentEntry(item.content);
        
        ofs << "//===================================" << endl;
        ofs << "// " << item.content << endl;
        ofs << "//===================================" << endl;
        ofs << endl;
      }
      else if (item.type == PomGenericString::type_marker) {
        dst.addMarkerEntry(item.content);
        
        ofs << "// === MARKER: " << item.content << endl;
        ofs << endl;
      }
    }
  }
  
protected:
  
};

void readGenericMainPtrTable(TStream& src, PomGenericStringSet& dst,
                             const TThingyTable& table,
                             int start, int end) {
  int size = (end - start) / 4;
  for (int i = 0; i < size; i++) {
    int target = start + (i * 4);
    src.seek(target);
    int offset = src.readu32le() - mainExeBaseAddr;
//    if (offset >= src.size()) continue;
//    dst.addString(src, table, offset);
    dst.addPointerTableString(src, table, offset, target);
  }
}

void readGenericMainPtrTableRev(TStream& src, PomGenericStringSet& dst,
                             const TThingyTable& table,
                             int start, int end) {
  int size = (end - start) / 4;
  // these tables are in reverse order for whatever compiler-related reason
  for (int i = size - 1; i >= 0; i--) {
    int target = start + (i * 4);
    src.seek(target);
    int offset = src.readu32le() - mainExeBaseAddr;
//    if (offset >= src.size()) continue;
//    dst.addString(src, table, offset);
    dst.addPointerTableString(src, table, offset, target);
  }
}

void readGenericStringBlock(TStream& src, PomGenericStringSet& dst,
                             const TThingyTable& table,
                             int start, int end) {
  src.seek(start);
  while (src.tell() < end) {
    int offset = src.tell();
    dst.addString(src, table, offset);
    
    // ignore null padding
    // (strings are padded to next word boundary)
    while (!src.eof() && (src.peek() == 0x00)) src.get();
  }
}

void readGenericStringBlockPtrOvr(TStream& src, PomGenericStringSet& dst,
                             const TThingyTable& table,
                             int start, int end) {
  src.seek(start);
  while (src.tell() < end) {
    int offset = src.tell();
//    dst.addString(src, table, offset);
    
    // new string needed
    PomGenericString result = dst.readString(src, table, offset);
    result.pointerRefs.push_back(offset);
    dst.strings.push_back(result);
    
    // ignore null padding
    // (strings are padded to next word boundary)
    while (!src.eof() && (src.peek() == 0x00)) src.get();
  }
}

/*void addGenericStringToSet(TStream& src, PomGenericStringSet& dst,
                      const TThingyTable& table,
                      int offset
//                      std::string idPrefix
                      ) {
//  std::string idString = idPrefix
//    + "-"
//    + TStringConversion::intToString(offset);
  
  PomGenericString result;
  result.offset = offset;
  
  src.seek(offset);
  while (!src.eof()) {
    if (src.peek() == 0x00) {
      src.get();
      result.size = src.tell() - offset;
      dst.strings.push_back(result);
      return;
    }
    
    TThingyTable::MatchResult matchCheck
      = table.matchId(src);
    if (matchCheck.id == -1) break;
    
    result.content += table.getEntry(matchCheck.id);
  }
  
  throw TGenericException(T_SRCANDLINE,
                          "addGenericString()",
                          std::string("bad string at ")
                          + TStringConversion::intToString(offset));
} */

int main(int argc, char* argv[]) {
  if (argc < 1) {
    cout << "Pom script generator" << endl;
//    cout << "Usage: " << argv[0] << " <outprefix>" << endl;
    cout << "Usage: " << argv[0] << endl;
    
    return 1;
  }
  
//  string outprefixName(argv[1]);

  TFileManip::createDirectory("script/orig");
  
  tableScript.readSjis("table/pom.tbl");
  tableFixed.readSjis("table/pom_fixedstr.tbl");
  tableSjis.readSjis("table/sjis_pom.tbl");
  tableEnd.readSjis("table/pom_end.tbl");
  
  // main executable
  TBufStream mainifs;
  {
    // read exe, removing header so pointers match up correctly
    TBufStream tempifs;
    tempifs.open("disc/files/MAIN.EXE");
    tempifs.seek(0x800);
    mainifs.writeFrom(tempifs, tempifs.remaining());
  }
  
  // end credits executable
  TBufStream endifs;
  {
    // read exe, removing header so pointers match up correctly
    TBufStream tempifs;
    tempifs.open("disc/files/POM_END.EXE");
    tempifs.seek(0x800);
    endifs.writeFrom(tempifs, tempifs.remaining());
  }
  
//  TBufStream mapTestOfs;
  
  PomTranslationSheet scriptSheet;
  
  //========================================================================
  // MAIN EXE
  //========================================================================
  
  {
//    mainifs.seek(mapDataOffsetTableAddr - mainExeLoadAddr);
    mainifs.seek(mapDataOffsetTableAddr - mainExeBaseAddr);
    
    TBufStream mapifs;
    mapifs.open("disc/files/GRAPHIC/MAP.PAK");
    
    //=======================================
    // read map scripts
    //=======================================
    
    PomGenericStringSet strings;
    
    // DEBUG: enable automatic failure on dialogue box overflow
    // for standard map strings
    // (line wrapping is done dynamically in-game, so no need for this
    // once the static verification has been done)
    {
      PomGenericString str;
      str.type = PomGenericString::type_genericLine;
//      str.content = "#SETSIZE(192, 4)";
      str.content = "//#SETSIZE(200, 4)";
      strings.strings.push_back(str);
    }
    {
      PomGenericString str;
      str.type = PomGenericString::type_genericLine;
      str.content = "//#SETFAILONBOXOVERFLOW(1)";
      strings.strings.push_back(str);
    }
    
    for (unsigned int i = 0; i < numMaps; i++) {
      int mapOffset = mainifs.readu32le();
      
      mapifs.seek(mapOffset);
      PomMapData mapData;
      mapData.read(mapifs);
      mapData.save(std::string("rsrc_raw/maps_decompressed/")
          + TStringConversion::intToString(i)
          + "/");
      
      mapifs.seek(mapOffset);
      PomMapData mapDataCompressed;
      mapDataCompressed.read(mapifs, false);
      mapDataCompressed.save(std::string("rsrc_raw/maps/")
          + TStringConversion::intToString(i)
          + "/");
      
/*      std::cerr << i << std::endl;
      TBufStream test;
      mapData.write(test);
      test.seek(0);
      mapTestOfs.writeFrom(test, test.size()); */
      
//      PomMapData test;
//      test.load(mapOutDir);
//      test.save(std::string("rsrc_raw/mapstest/")
//          + TStringConversion::intToString(i)
//          + "/");
      
//      std::cout << std::hex << i << " " << mapData.resources.size()
//        << std::endl;
//      std::cout << std::hex << "map: " << i
//        << std::endl;

//      scriptSheet.addCommentEntry(std::string("Map ")
//        + TStringConversion::intToString(i));
      strings.addComment(std::string("Map ")
        + TStringConversion::intToString(i));
//      std::cerr << "map " << std::dec << i << std::endl;
      
      for (unsigned int j = 0; j < mapData.resources.size(); j++) {
        TArray<TByte>& data = mapData.resources[j];
        if ((data.size() >= 4)
            && (data[0] == 'P')
            && (data[1] == 'L')
            && (data[2] == 'M')) {
//          std::cout << "PLM" << data[3] << ": " << i << std::endl;
//          std::cout << std::hex << (int)data[0x10]
//            << " " << (int)data[0x11]
//            << " " << (int)data[0x12]
//            << " " << (int)data[0x13]
//            << std::endl;
          
          TBufStream ifs;
          ifs.write((char*)data.data(), data.size());
          ifs.seek(0);
          
//          TStringSearchResultList searchResults =
//            TStringSearch::searchFullStream(ifs, "48 09 01");
//          for (unsigned int i = 0; i < searchResults.size(); i++) {
//            std::cout << "arb sjis print: " << searchResults[i].offset << std::endl;
//          }
          
//          TStringSearchResultList searchResults =
//            TStringSearch::searchFullStream(ifs, "48 07 01");
//          for (unsigned int i = 0; i < searchResults.size(); i++) {
//            std::cout << "num print: " << searchResults[i].offset << std::endl;
//          }
          
//          TStringSearchResultList searchResults =
//            TStringSearch::searchFullStream(ifs, "48 06 01");
//          for (unsigned int i = 0; i < searchResults.size(); i++) {
//            std::cout << "cmd 106: " << searchResults[i].offset << std::endl;
//          }
          
          ifs.seek(0);
          
          std::string outFileName =
            std::string("testdata/mapscripts/map")
            + as2bHex(i)
            + "_"
            + as2bHex(j)
            + ".bin";
//          TFileManip::createDirectoryForFile(outFileName);
//          ifs.save(outFileName.c_str());
          
          PomPlmStringScanResults scanResults;
          PomPlmData::stringScan(ifs, tableScript, scanResults);
          
//          for (unsigned int k = 0; k < scanResults.results.size(); k++) {
//            std::string idString = "plm_"
//              + TStringConversion::intToString(i)
//              + "-"
//              + TStringConversion::intToString(j)
//              + "-"
//              + TStringConversion::intToString(k);
//            scriptSheet.addStringEntry(
//              idString, scanResults.results[k].content);
//          }
          
          PomPlmScriptStringSet outputStrings;
          PomPlmData::formOutputStrings(ifs, scanResults, outputStrings);
          
          {
            PomGenericString str;
            str.type = PomGenericString::type_setRegion;
            str.regionId = i;
            strings.strings.push_back(str);
          }
          
          {
            PomGenericString str;
            str.type = PomGenericString::type_setMap;
            str.mapMainId = i;
            str.mapSubId = j;
            strings.strings.push_back(str);
          }
          
          for (unsigned int k = 0; k < outputStrings.strings.size(); k++) {
            std::string idString = "plm_"
              + TStringConversion::intToString(i)
              + "-"
              + TStringConversion::intToString(j)
//              + "-"
//              + TStringConversion::intToString(k);
              + "-"
              + TStringConversion::intToString(
                  outputStrings.strings[k].origOffset,
                    TStringConversion::baseHex);
            
            PomGenericString str;
            str.type = PomGenericString::type_mapString;
            str.content = outputStrings.strings[k].content;
            str.offset = outputStrings.strings[k].origOffset;
            str.size = outputStrings.strings[k].origSize;
            str.idOverride = idString;
            str.scriptRefStart = outputStrings.strings[k].scriptRefStart;
            str.scriptRefEnd = outputStrings.strings[k].scriptRefEnd;
            str.scriptRefCode = outputStrings.strings[k].scriptRefStartCode;
            str.translationPlaceholder
              = outputStrings.strings[k].translationPlaceholder;
            strings.strings.push_back(str);
            
//            scriptSheet.addStringEntry(
//              idString, outputStrings.strings[k].content);
          }
        }
      }
    }
    
//    scriptSheet.exportCsv("script/orig/script_main.csv");
    
    std::ofstream ofs("script/orig/spec_main.txt");
    strings.exportToSheet(scriptSheet, ofs, "");
//    scriptSheet.exportCsv("script/orig/script_main.csv");
  }
  
  //=======================================
  // read hardcoded fixed strings
  //=======================================
  
  {
    PomGenericStringSet strings;
//    strings.addString(mainifs, tableFixed,
//                      0x800112E8 - mainExeBaseAddr);
    
    strings.addComment("Location name labels");
    readGenericMainPtrTableRev(mainifs, strings, tableFixed,
                            0x1064E4, 0x1066EC);
    
    strings.addComment("Naming screen, save/load menus");
    readGenericMainPtrTableRev(mainifs, strings, tableFixed,
                            0x11502C - (11 * 4), 0x11502C);
    {
      PomGenericString str;
      str.type = PomGenericString::type_genericLine;
      str.content = "#SETSIZE(192, 3)";
      strings.strings.push_back(str);
    }
    readGenericMainPtrTableRev(mainifs, strings, tableFixed,
                            0x114FAC, 0x11502C - (11 * 4));
    {
      PomGenericString str;
      str.type = PomGenericString::type_genericLine;
      str.content = "#SETSIZE(-1, -1)";
      strings.strings.push_back(str);
    }
    
    
    strings.addComment("Default names for player-nameable stuff");
    strings.addSetNotCompressible(true);
    readGenericMainPtrTable(mainifs, strings, tableFixed,
                            0x11502C, 0x115074);
    strings.addSetNotCompressible(false);
    
//    PomTranslationSheet scriptSheet;
    std::ofstream ofs("script/orig/spec_system.txt");
    strings.exportToSheet(scriptSheet, ofs, "system_");
//    scriptSheet.exportCsv("script/orig/script_system.csv");
  }
  
  //=======================================
  // read hardcoded SJIS strings
  //=======================================
  
  {
    PomGenericStringSet strings;
    
    strings.addMarker("dict_section_start");
      strings.addComment("Item names");
      readGenericMainPtrTable(mainifs, strings, tableSjis,
                              0x1138F4, 0x113BDC);
    strings.addMarker("dict_section_end");
    
    strings.addComment("Pom Community building names");
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x113BDC, 0x113C14);
    
    strings.addComment("Item descriptions and use messages");
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x113C14, 0x113F70);
    
    strings.addComment("Default Pom names + something");
    strings.addSetNotCompressible(true);
    for (int i = 0; i < 18; i++) {
//      strings.addString(mainifs, tableSjis,
//                        0x7A1D + (0x80 * i));
      strings.addOverwriteString(mainifs, tableSjis,
                        0x7A1D + (0x80 * i));
    }
    strings.addSetNotCompressible(false);
    
    strings.addComment("?");
//    strings.addString(mainifs, tableSjis,
//                      0x8418);
//    strings.addString(mainifs, tableSjis,
//                      0x8424);
    strings.addSetNotCompressible(true);
    strings.addOverwriteString(mainifs, tableSjis,
                      0x8418);
    strings.addOverwriteString(mainifs, tableSjis,
                      0x8424);
    strings.addSetNotCompressible(false);
    
    strings.addComment("Lulu default name (dupe, gets overwritten)");
//    strings.addString(mainifs, tableSjis,
//                      0x11BC84);
    strings.addSetNotCompressible(true);
    strings.addOverwriteString(mainifs, tableSjis,
                      0x11BC84);
    strings.addSetNotCompressible(false);
    
    strings.addComment("Pom occupations");
//    readGenericMainPtrTable(mainifs, strings, tableSjis,
//                            0x116278, 0x1162C0);
    // FIXME: the last entry in this table, 王様,
    // is in some way not valid.
    // it occupies memory that is overwritten with the last 4 bytes
    // of Lulu's name (max 12 bytes) during gameplay.
    // presumably, it is not used (or the game somehow gets away with it).
    // exclude for now.
//    readGenericMainPtrTable(mainifs, strings, tableSjis,
//                            0x116278, 0x1162BC);
    // the pointers at 0x1162A4 and 0x1162B0 correspond to overwrite strings.
    // we must not add them (otherwise, the strings will be both auto-inserted
    // and overwritten, with poor results)
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x116278, 0x1162A4);
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x1162A8, 0x1162B0);
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x1162B4, 0x1162BC);
    
//    strings.addComment("some building names for some reason...");
//    strings.addString(mainifs, tableSjis,
//                      0x9CC8);
//    strings.addString(mainifs, tableSjis,
//                      0x9CD4);
//    strings.addString(mainifs, tableSjis,
//                      0x9CE0);
//    strings.addString(mainifs, tableSjis,
//                      0x9CEC);
    
    strings.addComment("some building names and stuff...");
    for (int i = 0; i < 14; i++) {
      mainifs.seek(0x9BB0 + (i * 0x14));
      int offset = mainifs.readu32le() - mainExeBaseAddr;
      strings.addString(mainifs, tableSjis,
                        offset);
    }
    
    strings.addComment("Header for tip messages");
    strings.addString(mainifs, tableSjis,
                      0xA164);
    
    strings.addComment("Tip messages");
    strings.addString(mainifs, tableSjis,
                      0x115A28);
    strings.addString(mainifs, tableSjis,
                      0x115AB8);
    strings.addString(mainifs, tableSjis,
                      0x115B74);
    strings.addString(mainifs, tableSjis,
                      0x115BD0);
    strings.addString(mainifs, tableSjis,
                      0x115C60);
    strings.addString(mainifs, tableSjis,
                      0x115D0C);
    strings.addString(mainifs, tableSjis,
                      0x115D8C);
    strings.addString(mainifs, tableSjis,
                      0x115E3C);
    strings.addString(mainifs, tableSjis,
                      0x115E98);
    strings.addString(mainifs, tableSjis,
                      0x115F50);
    strings.addString(mainifs, tableSjis,
                      0x115FB4);
    
    strings.addComment("Game over menu");
    readGenericMainPtrTable(mainifs, strings, tableSjis,
                            0x1064CC, 0x1064E4);
    
//    PomTranslationSheet scriptSheet;
    std::ofstream ofs("script/orig/spec_sjis.txt");
    strings.exportToSheet(scriptSheet, ofs, "sjis_");
//    scriptSheet.exportCsv("script/orig/script_sjis.csv");
  }
  
  //=======================================
  // add placeholders for new strings
  //=======================================
  
  {
    PomGenericStringSet strings;

    PomGenericString blankStr;
    blankStr.type = PomGenericString::type_string;
    blankStr.offset = 0;
    blankStr.size = -1;
        
    strings.addComment("NEW: Ranks for Pom Community");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
        
    strings.addComment("NEW: pluralizing suffix for trading cards");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
        
    strings.addComment("NEW: game over message");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
        
    strings.addComment("NEW: extra name screen strings");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
        
    strings.addComment("NEW: name screen confirmation concat strings");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
        
    strings.addComment("NEW: inventory plural messages");
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    strings.strings.push_back(blankStr);
    blankStr.offset++;
    
//    PomTranslationSheet scriptSheet;
    std::ofstream ofs("script/orig/spec_new.txt");
    strings.exportToSheet(scriptSheet, ofs, "new_");
  }
  
  //========================================================================
  // ENDING CREDITS
  //========================================================================
  
  //=======================================
  // existing content
  //=======================================
  
  {
    PomGenericStringSet strings;
        
    strings.addComment("ending credits");
    
    endifs.seek(0x14);
    readGenericStringBlockPtrOvr(endifs, strings, tableEnd,
                           0x14, 0xA10);
    readGenericStringBlockPtrOvr(endifs, strings, tableEnd,
                           0x1AE28, 0x1AEE8);
    
    std::ofstream ofs("script/orig/spec_end.txt");
    strings.exportToSheet(scriptSheet, ofs, "end_");
  }
  
  //=======================================
  // add placeholders for new strings
  //=======================================
  
  {
    PomGenericStringSet strings;

    PomGenericString blankStr;
    blankStr.type = PomGenericString::type_string;
    blankStr.offset = 0;
    blankStr.size = -1;
        
    strings.addComment("NEW: placeholders for new credits strings");
    
    for (int i = 0; i < 32; i++) {
      strings.strings.push_back(blankStr);
      blankStr.offset++;
    }
    
//    PomTranslationSheet scriptSheet;
    std::ofstream ofs("script/orig/spec_endnew.txt");
    strings.exportToSheet(scriptSheet, ofs, "endnew_");
  }
  
//  mapTestOfs.save("test_map.bin");
  
//  scriptSheet.exportCsv("script/orig/script_main.csv");
  scriptSheet.exportCsv("script/orig/pom_script.csv");
  
  return 0;
}
