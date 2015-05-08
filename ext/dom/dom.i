/* dom.i */
%module dom
%rename(valCadidate) unordered_map<string, string>; 
%rename(valCandidates) vector<valCandidate>;
%rename(candidatesByLang) unordered_map<string, valCandidates>;
%rename(stringIndex) unordered_map<string, candidatesByLang>;
%rename(stringCount) unordered_map<string, int>;

%{
/* Put header files here or function declarations like below */
#include "dom.h"
/*extern double My_variable;
extern int fact(int n);
extern int my_mod(int x, int y);
extern char *get_time();*/
%}

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
/*extern double My_variable;
extern int fact(int n);
extern int my_mod(int x, int y);
extern char *get_time();*/
