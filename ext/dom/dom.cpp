 #include "dom.h"

/*int main() {
  valCandidate enVal;
  enVal["xpath"] = "/html/body/p/text()";
  enVal["data"] = "TEST";
  valCandidates enVals(2);
  enVals[0] = enVal;
  valCandidate esVal;
  esVal["xpath"] = "/html/body/p/text()";
  esVal["data"] = "EXAMEN";
  valCandidates esVals(2);
  esVals[0] = esVal;

  valCandidate enVal2;
  enVal2["xpath"] = "/html/head/title/text()";
  enVal2["data"] = "TEST";
  enVals[1] = enVal2;
  valCandidate esVal2;
  esVal2["xpath"] = "/html/head/title/text()";
  esVal2["data"] = "EXAMEN TITULO";
  esVals[1] = esVal2;

  candidatesByLang langs;
  langs["en"] = enVals;
  langs["es"] = esVals;

  stringIndex textVals;
  textVals["TEST"] = langs;

  string response = "<!doctype html>\n<html>\n\t<head>\n\t\t<title>TEST</title>\n\t</head>\n\t<body>\n\t\t<p id=\"test\">TEST</p>\n\t</body>\n</html>";

  Dom dt(textVals, response, "es");
  string result = dt.transform();
  cout << "|" << result << "|" << endl;
}*/

Dom::Dom (stringIndex tVals, string html, string target) {
  in = html;
  targetLang = target;
  textVals = tVals;
  c = 0;
  voidTags["area"] = 1;
  voidTags["base"] = 1;
  voidTags["br"] = 1;
  voidTags["col"] = 1;
  voidTags["command"] = 1;
  voidTags["embed"] = 1;
  voidTags["hr"] = 1;
  voidTags["img"] = 1;
  voidTags["input"] = 1;
  voidTags["link"] = 1;
  voidTags["meta"] = 1;
  voidTags["param"] = 1;
  voidTags["source"] = 1;
}

string Dom::transform () {
  stringCount childrenTagCount;

  // guess it starts with <!doctype
  if (in.size() > 8 && in[1] == '!' && compareToStringEnd("<!doctype", c)) {
      do {
        copyToNextChar(out);
      } while (in[c] && in[c - 1] != 'e');
  }
  
  // consume text outside of top level elements (<html>)
  while (in[c]) {
    if (in[c] == '<')
      processElement("", childrenTagCount);
    if (in[c])
      copyToNextChar(out);
  }

  return out.str();
}

void Dom::processElement (string xpath, stringCount &tagCount) {
  stringstream tagName, val;
  string newVal;
  stringCount childrenTagCount;

  // copy '<'
  copyToNextChar(out);
  // inside opening tag
  while (in[c] && in[c - 1] != '>') {
    // get tag name
    while (in[c] && in[c] != ' ' && in[c] != '>') {
      copyToNextChar(tagName);
    }
    out << tagName.str();
    tagCount[tagName.str()] = tagCount.count(tagName.str()) ? tagCount[tagName.str()] + 1 : 1;
    updateXpath(xpath, tagName.str(), tagCount);

    // attributes
    while (in[c] && in[c] != '>') {
      // copy directly to out stream
      copyToNextChar(out);
    }
    // copy closing '>'
    if (in[c])
      copyToNextChar(out);
  }
  bool selfClosed = in[c - 2] == '/' && in[c - 1] == '>';


  // if this is not a self-closing tag (void tag)
  if (!selfClosed && !voidTags[tagName.str()]) {
    // In between the opening and closing tag
    while (in[c]) {
      if (in[c] == '<') {
        if (in[c + 1] == '/')
          break;
        else
          processElement(xpath, childrenTagCount);
      }
      else {
        childrenTagCount["text()"] = childrenTagCount.count("text()") ? childrenTagCount["text()"] + 1 : 1;
        processTextNode(xpath + "/text()" + (childrenTagCount["text()"] > 1 ? "[" + to_string(childrenTagCount["text()"]) + "]" : ""));
      }
    }
  }

  // closing tag
  while (in[c] && in[c - 1] != '>') {
    // copy directly to out stream
    copyToNextChar(out);
  }
    /*// start tag
    if (in[c] == '<') {
      copyToNextChar(out);
      // get tagName
      while (in[c] && in[c] != ' ' && in[c] != '>') {
        copyToNextChar(tagName);
      }
      out << tagName.str();
      tagCount[tagName.str()] = tagCount.count(tagName.str()) ? tagCount[tagName.str()] + 1 : 1;
      updateXpath(xpath, tagName.str(), tagCount);
      // copy till end of opening tag
      while (in[c] && in[c - 1] != '>') {
        copyToNextChar(out);
      }
      // get value
      while (in[c] && in[c] != '<') {
        copyToNextChar(val);
        // end of current text val
        if (in[c] == '<') {
          // text() node
          tagCount["text()"] = tagCount.count("text()") ? tagCount["text()"] + 1 : 1;
          newVal = getByVal(val.str(), tagCount["text()"] > 1 ? xpath + "/text()[" + to_string(tagCount["text()"]) + "]" : xpath + "/text()");
          out << newVal;
          val.str("");
          val.clear();
          if (!in[c + 1] || in[c + 1] == '/') {
            // copy closing tag
            while (in[c] && in[c - 1] != '>') {
              copyToNextChar(out);
            }
            return;
          }
          else {
            // WRONG??
            childrenTagCount["text()"] = 0;
            processElement(xpath, childrenTagCount);
          }
        }
      }
      tagName.str("");
      tagName.clear();
    }
    // copies characters outside of <html></html> (or any other top level elements)
    // being careful not to copy past end of string
    if (in[c])
      copyToNextChar(out);
  }*/

}

void Dom:: processTextNode (string xpath) {
  stringstream val;
  while (in[c] && in[c] != '<')
    copyToNextChar(val);
  out << getByVal(val.str(), xpath);
}

string Dom::getByVal (const string &val, const string &xpath) {
  string newVal;
  if (textVals.count(val) && textVals[val].count(targetLang) && textVals[val][targetLang].size() > 0) {
    newVal = getBestMatch(textVals[val][targetLang], xpath, val);
  }
  else {
    newVal = val;
  }
  return newVal;
}

int Dom::matchScore (const string &a, const string &b) {
  int result = 0;
  int x = a.length() - 1;
  int y = b.length() - 1;
  while (x >= 0 && y >= 0) {
    if (a[x] != b[y])
      return result;
    if (a[x] == '/')
      result++;
    x--;
    y--;
  }
  return result;
}

// vals.size >= 1
string Dom::getBestMatch (valCandidates &vals, const string &xpath, const string &currentVal) {
  if (vals.size() == 1)
    return vals[0]["data"];
  string bestMatch = vals[0]["data"];
  int bestScore = matchScore(xpath, vals[0]["xpath"]);
  int score = 0;
  for (int i = 1; i < vals.size(); i++) {
    score = matchScore(xpath, vals[i]["xpath"]);
    if (score > bestScore) {
      bestMatch = vals[i]["data"];
      bestScore = score;
    }
  }
  return bestMatch;
}

void Dom::updateXpath (string &xpath, string tagName, stringCount &tagCount) {
  xpath += "/" + tagName;
  if (tagCount[tagName] > 1)
    xpath += "[" + to_string(tagCount[tagName]) + "]";
}

void Dom::copyToNextChar (stringstream &dest) {
  dest << in[c];
  c++;
}

bool Dom::compareToStringEnd (string a, int i) {
  int j = 0;
  while (a[j] && in[i]) {
    if (tolower(a[j++]) != tolower(in[i++]))
      return false;
  }
  return true;
}

