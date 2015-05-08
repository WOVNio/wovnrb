#ifndef DOM_H
#define DOM_H

#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <stack>
#include <unordered_map>

using namespace std;

typedef unordered_map<string, string> valCandidate; 
typedef vector<valCandidate> valCandidates;
typedef unordered_map<string, valCandidates> candidatesByLang;
typedef unordered_map<string, candidatesByLang> stringIndex;
typedef unordered_map<string, int> stringCount;

class Dom {
  private:
    stringstream out;
    stringIndex textVals;
    string in, targetLang;
    int c;
    stringCount voidTags;

    void processElement (string, stringCount&);
    void processTextNode (string);
    string getByVal(const string&, const string&);
    int matchScore(const string&, const string&);
    string getBestMatch(valCandidates&, const string&, const string&);
    void updateXpath(string&, string, stringCount&);
    void copyToNextChar(stringstream&);
    bool compareToStringEnd(string, int);

  public:
    Dom(stringIndex, string, string);
    string transform();
};

#endif
