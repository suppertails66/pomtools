#include "psx/PsxPalette.h"
#include "pom/PomScriptReader.h"
#include "pom/PomLineWrapper.h"
#include "pom/PomMapData.h"
#include "pom/PomPlmData.h"
#include "pom/PomCmp.h"
#include "util/TBufStream.h"
#include "util/TIfstream.h"
#include "util/TOfstream.h"
#include "util/TGraphic.h"
#include "util/TStringConversion.h"
#include "util/TFileManip.h"
#include "util/TPngConversion.h"
#include "util/TFreeSpace.h"
#include <cctype>
#include <string>
#include <vector>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;
using namespace BlackT;
using namespace Psx;


const static int textCharsStart = 0x10;
const static int textCharsEnd = 0x90;
const static int textEncodingMax = 0x100;
const static int maxDictionarySymbols = textEncodingMax - textCharsEnd;

const static unsigned int mainExeBaseAddr = 0x80010000;
const static int mainExeHeaderSize = 0x800;

const static unsigned int mapDataOffsetTableAddr = 0x8012335C;
const static unsigned int numMaps = 0x46;

// have to account for offset of exe from base
const static int creditsFreeStrSpaceStart = 0x100000 - 0x10000;
const static int creditsFreeStrSpaceEnd = 0x101000 - 0x10000;



TThingyTable table;
TThingyTable tableEnd;

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

std::string getNumStr(int num) {
  std::string str = TStringConversion::intToString(num);
  while (str.size() < 2) str = string("0") + str;
  return str;
}

std::string getHexByteNumStr(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 2) str = string("0") + str;
  return string("$") + str;
}

std::string getHexWordNumStr(int num) {
  std::string str = TStringConversion::intToString(num,
    TStringConversion::baseHex).substr(2, string::npos);
  while (str.size() < 4) str = string("0") + str;
  return string("$") + str;
}
                      

void binToDcb(TStream& ifs, std::ostream& ofs) {
  int constsPerLine = 16;
  
  while (true) {
    if (ifs.eof()) break;
    
    ofs << "  .db ";
    
    for (int i = 0; i < constsPerLine; i++) {
      if (ifs.eof()) break;
      
      TByte next = ifs.get();
      ofs << as2bHexPrefix(next);
      if (!ifs.eof() && (i != constsPerLine - 1)) ofs << ",";
    }
    
    ofs << std::endl;
  }
}




typedef std::map<std::string, int> UseCountTable;
//typedef std::map<std::string, double> EfficiencyTable;
typedef std::map<double, std::string> EfficiencyTable;

bool isCompressible(std::string& str) {
  for (int i = 0; i < str.size(); i++) {
    if (str[i] < textCharsStart) return false;
    if (str[i] >= textCharsEnd) return false;
  }
  
  return true;
}

void addStringToUseCountTable(std::string& input,
                        UseCountTable& useCountTable,
                        int minLength, int maxLength) {
  int total = input.size() - minLength;
  if (total <= 0) return;
  
  for (int i = 0; i < total; ) {
    int basePos = i;
    for (int j = minLength; j < maxLength; j++) {
      int length = j;
      if (basePos + length >= input.size()) break;
      
      std::string str = input.substr(basePos, length);
      if (!isCompressible(str)) break;
      
      ++(useCountTable[str]);
    }
    
    // skip literal arguments to ops
/*    if ((unsigned char)input[i] < textCharsStart) {
      ++i;
      int opSize = numOpParamWords((unsigned char)input[i]);
      i += opSize;
    }
    else {
      ++i;
    } */
    ++i;
  }
}

void addRegionsToUseCountTable(PomScriptReader::RegionToResultMap& input,
                        UseCountTable& useCountTable,
                        int minLength, int maxLength) {
  for (PomScriptReader::RegionToResultMap::iterator it = input.begin();
       it != input.end();
       ++it) {
    PomScriptReader::ResultCollection& results = it->second;
    for (PomScriptReader::ResultCollection::iterator jt = results.begin();
         jt != results.end();
         ++jt) {
//      std::cerr << jt->srcOffset << std::endl;
      if (jt->isLiteral) continue;
      if (jt->isNotCompressible) continue;
      
      addStringToUseCountTable(jt->str, useCountTable,
                               minLength, maxLength);
    }
  }
}

void buildEfficiencyTable(UseCountTable& useCountTable,
                        EfficiencyTable& efficiencyTable) {
  for (UseCountTable::iterator it = useCountTable.begin();
       it != useCountTable.end();
       ++it) {
    std::string str = it->first;
    // penalize by 1 byte (length of the dictionary code)
    double strLen = str.size() - 1;
    double uses = it->second;
//    efficiencyTable[str] = strLen / uses;
    
    efficiencyTable[strLen / uses] = str;
  }
}

void applyDictionaryEntry(std::string entry,
                          PomScriptReader::RegionToResultMap& input,
                          std::string replacement) {
  for (PomScriptReader::RegionToResultMap::iterator it = input.begin();
       it != input.end();
       ++it) {
    PomScriptReader::ResultCollection& results = it->second;
    int index = -1;
    for (PomScriptReader::ResultCollection::iterator jt = results.begin();
         jt != results.end();
         ++jt) {
      ++index;
      
      if (jt->isNotCompressible) continue;
      
      std::string str = jt->str;
      if (str.size() < entry.size()) continue;
      
      std::string newStr;
      int i;
      for (i = 0; i < str.size() - entry.size(); ) {
        if ((unsigned char)str[i] < textCharsStart) {
/*          int numParams = numOpParamWords((unsigned char)str[i]);
          
          newStr += str[i];
          for (int j = 0; j < numParams; j++) {
            newStr += str[i + 1 + j];
          }
          
          ++i;
          i += numParams; */
          newStr += str[i];
          ++i;
          continue;
        }
        
        if (entry.compare(str.substr(i, entry.size())) == 0) {
          newStr += replacement;
          i += entry.size();
        }
        else {
          newStr += str[i];
          ++i;
        }
      }
      
      while (i < str.size()) newStr += str[i++];
      
      jt->str = newStr;
    }
  }
}

void generateCompressionDictionary(
    PomScriptReader::RegionToResultMap& results,
    std::string outputDictFileName) {
  TBufStream dictOfs;
  for (int i = 0; i < maxDictionarySymbols; i++) {
//    cerr << i << endl;
    UseCountTable useCountTable;
    addRegionsToUseCountTable(results, useCountTable, 2, 3);
    EfficiencyTable efficiencyTable;
    buildEfficiencyTable(useCountTable, efficiencyTable);
    
//    std::cout << efficiencyTable.begin()->first << std::endl;
    
    // if no compressions are possible, give up
    if (efficiencyTable.empty()) break;  
    
    int symbol = i + textCharsEnd;
    applyDictionaryEntry(efficiencyTable.begin()->second,
                         results,
                         std::string() + (char)symbol);
    
    // debug
/*    TBufStream temp;
    temp.writeString(efficiencyTable.begin()->second);
    temp.seek(0);
//    binToDcb(temp, cout);
    std::cout << "\"";
    while (!temp.eof()) {
      std::cout << table.getEntry(temp.get());
    }
    std::cout << "\"" << std::endl; */
    
    dictOfs.writeString(efficiencyTable.begin()->second);
  }
  
//  dictOfs.save((outPrefix + "dictionary.bin").c_str());
  dictOfs.save(outputDictFileName.c_str());
}

// merge a set of RegionToResultMaps into a single RegionToResultMap
void mergeResultMaps(
    std::vector<PomScriptReader::RegionToResultMap*>& allSrcPtrs,
    PomScriptReader::RegionToResultMap& dst) {
  int targetOutputId = 0;
  for (std::vector<PomScriptReader::RegionToResultMap*>::iterator it
        = allSrcPtrs.begin();
       it != allSrcPtrs.end();
       ++it) {
    PomScriptReader::RegionToResultMap& src = **it;
    for (PomScriptReader::RegionToResultMap::iterator jt = src.begin();
         jt != src.end();
         ++jt) {
      dst[targetOutputId++] = jt->second;
    }
  }
}

// undo the effect of mergeResultMaps(), applying any changes made to
// the merged maps back to the separate originals
void unmergeResultMaps(
    PomScriptReader::RegionToResultMap& src,
    std::vector<PomScriptReader::RegionToResultMap*>& allSrcPtrs) {
  int targetInputId = 0;
  for (std::vector<PomScriptReader::RegionToResultMap*>::iterator it
        = allSrcPtrs.begin();
       it != allSrcPtrs.end();
       ++it) {
    PomScriptReader::RegionToResultMap& dst = **it;
    for (PomScriptReader::RegionToResultMap::iterator jt = dst.begin();
         jt != dst.end();
         ++jt) {
      jt->second = src[targetInputId++];
    }
  }
}

void freeResultSpace(PomScriptReader::RegionToResultMap& src,
                     BlackT::TFreeSpace& dst) {
  for (PomScriptReader::RegionToResultMap::iterator it
        = src.begin();
       it != src.end();
       ++it) {
    PomScriptReader::ResultCollection& results = it->second;
    for (PomScriptReader::ResultCollection::iterator it
          = results.begin();
         it != results.end();
         ++it) {
      PomScriptReader::ResultString str = *it;
      // free anything flagged for auto-insertion
      if ((str.pointerRefs.size() > 0)
//          && str.overwriteAddresses.empty()
          ) {
        dst.free(str.srcOffset, str.srcSize);
      }
    }
  }
}

void autoInsertStrings(PomScriptReader::RegionToResultMap& src,
                       TStream& dst,
                       BlackT::TFreeSpace& freeSpace,
                       unsigned int pointerOffset) {
  for (PomScriptReader::RegionToResultMap::iterator it
        = src.begin();
       it != src.end();
       ++it) {
    PomScriptReader::ResultCollection& results = it->second;
    for (PomScriptReader::ResultCollection::iterator it
          = results.begin();
         it != results.end();
         ++it) {
      PomScriptReader::ResultString str = *it;
      
      if (str.pointerRefs.size() > 0) {
        // insert to file
        int target = freeSpace.claim(str.str.size());
        unsigned int targetPointer = target + pointerOffset;
        dst.seek(target);
        dst.write(str.str.c_str(), str.str.size());
        
/*        if (str.srcOffset == 0x3DAC) {
          std::cerr << std::hex << str.str.size() << std::endl;
          std::cerr << std::hex << target << std::endl;
          std::cerr << std::hex << targetPointer << std::endl;
          for (int i = 0; i < str.str.size(); i++) {
            std::cerr << std::hex << (int)(unsigned char)str.str[i] << " ";
          }
          std::cerr << std::endl;
        }
        
        if (target == 0x8424) {
          std::cerr << std::hex << str.str.size() << std::endl;
          std::cerr << std::hex << target << std::endl;
          std::cerr << std::hex << targetPointer << std::endl;
        } */
        
        // update pointer references
        for (int i = 0; i < str.pointerRefs.size(); i++) {
          int pointerOffset = str.pointerRefs[i];
          
//          std::cerr << str.id << ": updating pointer at "
//            << std::hex << pointerOffset
//            << " to "
//            << std::hex << targetPointer
//            << std::endl;
          
          dst.seek(pointerOffset);
          dst.writeu32le(targetPointer);
        }
      }
      
      // overwrite where specified
      for (unsigned int i = 0; i < str.overwriteAddresses.size(); i++) {
        dst.seek(str.overwriteAddresses[i]);
        dst.write(str.str.c_str(), str.str.size());
      }
    }
  }
}

TFreeSpace generateMapFreeSpace(
    const PomScriptReader::ResultCollection& mapStrings) {
  TFreeSpace freeSpace;
  
  int lowestPos = 0;
  int highestPos = 0;
  if (!mapStrings.empty()) {
    lowestPos = mapStrings.front().srcOffset;
    highestPos = mapStrings.front().srcOffset
                  + mapStrings.front().srcSize;
  }
  
  for (PomScriptReader::ResultCollection::const_iterator it
        = mapStrings.cbegin();
       it != mapStrings.cend();
       ++it) {
    const PomScriptReader::ResultString& str = *it;
    
    int endPos = str.srcOffset + str.srcSize;
    if (str.srcOffset < lowestPos) lowestPos = str.srcOffset;
    if (endPos > highestPos) highestPos = endPos;
    
    // free the original locations of all strings
//    freeSpace.free(str.srcOffset, str.srcSize);
    
    // if string uses a standard print sequence
    // (scriptRefEnd != -1).
    // if it does, and there are consecutive print sequences
    // following it, free everything beyond what we need to
    // do one sequence followed by a jump.
    if ((str.scriptRefEnd >= 0)) {
      int newCmdSize = PomPlmData::printSequenceFullSize
        + PomPlmData::jumpSequenceFullSize;
      int additionalSpace = (str.scriptRefEnd - str.scriptRefStart)
                              - newCmdSize;
      if (additionalSpace > 0) {
        freeSpace.free(str.scriptRefStart + newCmdSize,
                       additionalSpace);
      }
    }
  }
  
  // FIXME: very lazy and might not work,
  // but it's easier than trying to separately track all the strings
  // we're merging just to make sure we allocate them one at a time
//  std::cerr << std::hex << lowestPos << " " << highestPos << std::endl;
  freeSpace.free(lowestPos, highestPos - lowestPos);
  
  return freeSpace;
}

void patchMapStrings(const PomScriptReader::ResultCollection& mapStrings,
                     TStream& ofs) {
  // set up free space
  TFreeSpace freeSpace = generateMapFreeSpace(mapStrings);
  
  for (PomScriptReader::ResultCollection::const_iterator it
        = mapStrings.cbegin();
       it != mapStrings.cend();
       ++it) {
    const PomScriptReader::ResultString& str = *it;
    
    // find space for string
    int newStrOffset = freeSpace.claim(str.str.size());
    if (newStrOffset < 0) {
      throw TGenericException(T_SRCANDLINE,
                              "patchMapStrings()",
                              "Ran out of space for map strings");
    }
    
    // write string to new position
    ofs.seek(newStrOffset);
    ofs.writeString(str.str);
    
    // update script reference
    ofs.seek(str.scriptRefStart + 1);
    ofs.writeu16le(newStrOffset);
    
    // if this is a standard print sequence,
    // and this is a multi-part merged string,
    // insert a jump command after the sequence
    // that jumps to the next script command following
    // the merged sequence
    if ((str.scriptRefEnd >= 0)) {
      int areaSize = str.scriptRefEnd - str.scriptRefStart;
      if (areaSize > (PomPlmData::printSequenceFullSize
                        + PomPlmData::jumpSequenceFullSize)) {
        ofs.seek(str.scriptRefStart + PomPlmData::printSequenceFullSize);
        ofs.writeu8(PomPlmData::op_jump);
        ofs.writeu16le(str.scriptRefEnd);
      }
    }
  }
  
//  for (TFreeSpace::FreeSpaceMap::iterator it = freeSpace.freeSpace_.begin();
//       it != freeSpace.freeSpace_.end();
//       ++it) {
//    std::cerr << std::hex << it->first << " " << it->second
//      << " " << it->first + it->second << std::endl;
//  }
}

void doNumberDisplayFix(TStream& ifs,
                        int startOffset, int valueOffset, int endOffset) {
  ifs.seek(startOffset);
  
  // "illegal" opcode, now mapped to our fix routine
  ifs.writeu8(0x84);
    // param: signed byte indicating offset of target value
    // from some storage location
    ifs.writeu8(valueOffset);
  // push the value prepared in the previous op to the text stack
  ifs.writeu8(0x40);
  // execute command 0x107 = print number
  ifs.writeu8(0x48);
    ifs.writeu16le(0x107);
  ifs.writeu8(0x79);
    ifs.writeu16le(0x14);
  ifs.writeu8(0x7E);
    ifs.writeu8(0x04);
  // unconditional branch to end of this horrible, horrible
  // number print script
  ifs.writeu8(0x77);
    ifs.writeu16le(endOffset);
}
                        



int main(int argc, char* argv[]) {
  if (argc < 3) {
    cout << "Community Pom script builder" << endl;
    cout << "Usage: " << argv[0] << " [inprefix] [outprefix]"
      << endl;
    return 0;
  }
  
//  string infile(argv[1]);
  string inPrefix(argv[1]);
  string outPrefix(argv[2]);

  table.readSjis("table/pom_en.tbl");
  tableEnd.readSjis("table/pom_end.tbl");
  
  //=====
  // read script
  //=====
  
  PomScriptReader::RegionToResultMap scriptResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_main.txt").c_str());
    PomScriptReader(ifs, scriptResults, table)();
  }
  
  PomScriptReader::RegionToResultMap systemResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_system.txt").c_str());
    PomScriptReader(ifs, systemResults, table)();
  }
  
  PomScriptReader::RegionToResultMap sjisResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_sjis.txt").c_str());
    PomScriptReader(ifs, sjisResults, table)();
  }
  
  PomScriptReader::RegionToResultMap newResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_new.txt").c_str());
    PomScriptReader(ifs, newResults, table)();
  }
  
  PomScriptReader::RegionToResultMap endResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_end.txt").c_str());
    PomScriptReader(ifs, endResults, tableEnd)();
  }
  
  PomScriptReader::RegionToResultMap endNewResults;
  {
    TBufStream ifs;
    ifs.open((inPrefix + "spec_endnew.txt").c_str());
    PomScriptReader(ifs, endNewResults, tableEnd)();
  }
  
//  generateCompressionDictionary(
//    scriptResults, outPrefix + "script_dictionary.bin");
  
  //=====
  // compress
  //=====
  
  {
    PomScriptReader::RegionToResultMap allStrings;
    
    std::vector<PomScriptReader::RegionToResultMap*> allSrcPtrs;
    allSrcPtrs.push_back(&scriptResults);
    allSrcPtrs.push_back(&systemResults);
    allSrcPtrs.push_back(&sjisResults);
    allSrcPtrs.push_back(&newResults);
    
    // merge everything into one giant map for compression
    mergeResultMaps(allSrcPtrs, allStrings);
    
    // compress
    generateCompressionDictionary(
      allStrings, outPrefix + "script_dictionary.bin");
    
    // restore results from merge back to individual containers
    unmergeResultMaps(allStrings, allSrcPtrs);
  }
  
  //=====
  // read MAIN.EXE
  //=====
  
  TBufStream mainIfs;
  {
    TBufStream ifs;
    ifs.open("out/files/MAIN.EXE");
    ifs.seek(mainExeHeaderSize);
    mainIfs.writeFrom(ifs, ifs.remaining());
  }
  
  //=====
  // update map scripts
  //=====
  
  {
    for (int i = 0; i < numMaps; i++) {
      //=====
      // patch script chunk with new strings
      //=====
      
      const PomScriptReader::ResultCollection& mapStrings
        = scriptResults.at(i);
      if (mapStrings.size() <= 0)
        continue;
      
      int mapChunkNum = mapStrings[0].mapSubNum;
      
      // open target map
      TBufStream ifs;
      ifs.open((std::string("out/rsrc_raw/maps_decompressed/")
        + TStringConversion::intToString(i)
        + "/resources/"
        + TStringConversion::intToString(mapChunkNum)
        + ".bin").c_str());
      
      // patch strings
      patchMapStrings(mapStrings, ifs);
      
      //=====
      // do special hacks for pom community
      //=====
      
      //=====
      // pom community modifications
      //=====
      
      if (i == 0) {
        //=====
        // interchange the order of Pom introductions
        // 
        // original game:
        // 「こんちわ。〈job〉の\n〈name〉だみょ。
        // 
        // hack:
        // "Hi there. I'm <name> the <job>"
        //=====
        
        // swap these two lines' op 48 args
        // (changing the string param function code)
        ifs.seek(0x182A);
        ifs.writeu16le(0x10B);
        ifs.seek(0x184A);
        ifs.writeu16le(0x10D);
        
        //=====
        // don't use "auto" brackets for skill name in
        // pom self-introductions
        //=====
        
        // jump past the "print thing in brackets" call
//        ifs.seek(0x1889);
//        ifs.writeu8(0x77);
//        ifs.writeu16le(0x1890);
        
        //=====
        // interchange order of object/target messages
        // when using an item on a building
        //=====
        
        // 0x4 0x64
        // 0x6 0x5C
        
        ifs.seek(0x127B);
        ifs.writeu8(0x06);
        ifs.seek(0x127F);
        ifs.writeu8(0x5C);
        
        ifs.seek(0x12A2);
        ifs.writeu8(0x04);
        ifs.seek(0x12A6);
        ifs.writeu8(0x64);
        
      }
      
      //=====
      // trading card fix
      //=====
      
      // haunted mansion maps
      if ((i == 30) || (i == 31) || (i == 32)) {
        // prevent trading card 22 from getting awarded twice.
        // it looks like they for some reason manually add 1 to
        // the trading card item quantity, then call a standard
        // function that increments it again.
        
        // skip the manual increment operation
        ifs.seek(0x1792);
        // unconditional branch
        ifs.writeu8(0x77);
        // target
        ifs.writeu16le(0x17A0);
      }
      
      //=====
      // number display bug fixes
      //=====
      
      // community church
      if ((i == 5)) {
        // prompt
        doNumberDisplayFix(ifs, 0x4D4, 0xFB, 0x4F2);
        // after healed
        doNumberDisplayFix(ifs, 0x593, 0xFB, 0x5B1);
      }
      // woolly village church
      else if ((i == 17)) {
        // after healed
        doNumberDisplayFix(ifs, 0x12AF, 0xFB, 0x12CD);
      }
      // splashire church
      else if ((i == 18)) {
        // prompt
        doNumberDisplayFix(ifs, 0x91B, 0xFB, 0x939);
      }
      // dwarf village church
      else if ((i == 20) || (i == 21)) {
        // after healed
        doNumberDisplayFix(ifs, 0x17D9, 0xFB, 0x17F7);
      }
      // cruela church
      else if ((i == 24)) {
        // after healed
        doNumberDisplayFix(ifs, 0xE2A, 0xFB, 0xE48);
      }
      // burnhot church
      else if ((i == 43) || (i == 44)) {
        // prompt
        doNumberDisplayFix(ifs, 0x1579, 0xFB, 0x1597);
        // after healed
        doNumberDisplayFix(ifs, 0x1638, 0xFB, 0x1656);
      }
      // fantasy land church
      else if ((i == 50) || (i == 51)) {
        // after healed
        doNumberDisplayFix(ifs, 0x1D5F, 0xFB, 0x1D7D);
      }
      // lunaire church
      else if ((i == 55) || (i == 56) || (i == 57)) {
        // after healed
        doNumberDisplayFix(ifs, 0x118E, 0xFB, 0x11AC);
      }
      
      //=====
      // save map
      //=====
      
      // save uncompressed map (don't actually need this,
      // but it's much easier for debugging)
      ifs.save((std::string("out/rsrc_raw/maps_decompressed/")
        + TStringConversion::intToString(i)
        + "/resources/"
        + TStringConversion::intToString(mapChunkNum)
        + ".bin").c_str());
      
      // compress and save updated map
      {
        TBufStream cmpifs;
        ifs.seek(0);
        PomCmp::cmpRux(ifs, cmpifs);
        cmpifs.save((std::string("out/rsrc_raw/maps/")
          + TStringConversion::intToString(i)
          + "/resources/"
          + TStringConversion::intToString(mapChunkNum)
          + ".bin").c_str());
      }
    }
  }
  
  //=====
  // regenerate maps and patch to map file
  //=====
  
  {
    TBufStream mapOfs;
    mapOfs.open("out/files/GRAPHIC/MAP.PAK");
    
    // patch over each map
    mainIfs.seek(mapDataOffsetTableAddr - mainExeBaseAddr);
    for (int i = 0; i < numMaps; i++) {
//      std::cerr << "patching map " << i << std::endl;
//      mainIfs.seek((mapDataOffsetTableAddr - mainExeBaseAddr) + (i * 4));
      int mapDataOffset = mainIfs.readu32le();
      
      PomMapData mapData;
      mapData.load(std::string("out/rsrc_raw/maps/")
        + TStringConversion::intToString(i)
        + "/");
      TBufStream ofs;
//      mapData.write(ofs);
      // data is pre-compressed, so pass in "false" as param
      // to prevent it from being compressed again.
      // this is done because, of the ~16 compressed resource files
      // per map, we usually only need to modify the script file.
      // the compression process is slow, so it's massively faster
      // to just leave everything else compressed to begin with.
      mapData.write(ofs, false);
      
      mapOfs.seek(mapDataOffset);
      ofs.seek(0);
      mapOfs.writeFrom(ofs, ofs.size());
    }
    
    mapOfs.save("out/files/GRAPHIC/MAP.PAK");
  }
  
  //=====
  // create merge of system/sjis strings as "generic" string set
  // for common handling
  //=====
  
  PomScriptReader::RegionToResultMap genericStrings;
  {
    std::vector<PomScriptReader::RegionToResultMap*> allSrcPtrs;
    allSrcPtrs.push_back(&systemResults);
    allSrcPtrs.push_back(&sjisResults);
    allSrcPtrs.push_back(&newResults);
    mergeResultMaps(allSrcPtrs, genericStrings);
  }
  
  //=====
  // output auto-inserted generic strings
  //=====
  
  {
    
    // free space from original strings
    TFreeSpace mainFreeSpace;
    freeResultSpace(genericStrings, mainFreeSpace);
    
    // TODO: additional space needed?
    // note that most/all of these strings occur in blocks that are padded
    // to the next 4-byte boundary between each string, so freeing those
    // as one big unit will create extra space
    
    // insert strings
    autoInsertStrings(genericStrings, mainIfs, mainFreeSpace,
                      mainExeBaseAddr);
  }
  
  //=====
  // output generic strings to disk for external use
  //=====
  
  TFileManip::createDirectory((outPrefix + "generic").c_str());
  {
    for (PomScriptReader::RegionToResultMap::iterator it
          = genericStrings.begin();
         it != genericStrings.end();
         ++it) {
      PomScriptReader::ResultCollection& results = it->second;
      for (PomScriptReader::ResultCollection::iterator it
            = results.begin();
           it != results.end();
           ++it) {
        PomScriptReader::ResultString str = *it;
        TBufStream ofs;
        ofs.writeString(str.str);
        ofs.save((outPrefix + "generic/" + str.id + ".bin").c_str());
      }
    }
  }
  
  //=====
  // write modified MAIN.EXE to disk
  //=====
  
  {
    TBufStream ifs;
    ifs.open("out/files/MAIN.EXE");
    ifs.seek(mainExeHeaderSize);
    mainIfs.seek(0);
    ifs.writeFrom(mainIfs, mainIfs.remaining());
    ifs.save("out/files/MAIN.EXE");
  }
  
  //=====
  // read POM_END.EXE
  //=====
  
  TBufStream endIfs;
  {
    TBufStream ifs;
    ifs.open("out/files/POM_END.EXE");
    ifs.seek(mainExeHeaderSize);
    endIfs.writeFrom(ifs, ifs.remaining());
  }
  
  //=====
  // insert credits strings
  //=====
  
  {
    // free space
    TFreeSpace endFreeSpace;
    endFreeSpace.free(creditsFreeStrSpaceStart, creditsFreeStrSpaceEnd);
    
    // insert strings
    autoInsertStrings(endResults, endIfs, endFreeSpace,
                      mainExeBaseAddr);
  }
  
  //=====
  // output generic strings to disk for external use
  //=====
  
  TFileManip::createDirectory((outPrefix + "endnew").c_str());
  {
    for (PomScriptReader::RegionToResultMap::iterator it
          = endNewResults.begin();
         it != endNewResults.end();
         ++it) {
      PomScriptReader::ResultCollection& results = it->second;
      for (PomScriptReader::ResultCollection::iterator it
            = results.begin();
           it != results.end();
           ++it) {
        PomScriptReader::ResultString str = *it;
        TBufStream ofs;
        ofs.writeString(str.str);
        ofs.save((outPrefix + "endnew/" + str.id + ".bin").c_str());
      }
    }
  }
  
  //=====
  // write modified POM_END.EXE to disk
  //=====
  
  {
    TBufStream ifs;
    ifs.open("out/files/POM_END.EXE");
    ifs.seek(mainExeHeaderSize);
    endIfs.seek(0);
    ifs.writeFrom(endIfs, endIfs.remaining());
    ifs.save("out/files/POM_END.EXE");
  }
  
  return 0;
}
