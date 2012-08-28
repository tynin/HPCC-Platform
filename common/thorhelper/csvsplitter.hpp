/*##############################################################################

    HPCC SYSTEMS software Copyright (C) 2012 HPCC Systems.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
############################################################################## */

#ifndef CSVSPLITTER_INCL
#define CSVSPLITTER_INCL

#ifdef _WIN32
 #ifdef THORHELPER_EXPORTS
  #define THORHELPER_API __declspec(dllexport)
 #else
  #define THORHELPER_API __declspec(dllimport)
 #endif
#else
 #define THORHELPER_API
#endif

#include "jregexp.hpp"
#include "eclhelper.hpp"
#include "unicode/utf.h"

class THORHELPER_API CSVSplitter
{
public:
    CSVSplitter();
    ~CSVSplitter();

    void addQuote(const char * text);
    void addSeparator(const char * text);
    void addTerminator(const char * text);

    void init(unsigned maxColumns, ICsvParameters * csvInfo, const char * dfsQuotes, const char * dfsSeparators, const char * dfsTerminators);
    void reset();
    size32_t splitLine(size32_t maxLen, const byte * start);

    inline unsigned * queryLengths() { return lengths; }
    inline const byte * * queryData() { return data; }

protected:
    void setFieldRange(const byte * start, const byte * end, unsigned curColumn, unsigned quoteToStrip);

protected:
    enum { NONE=0, SEPARATOR=1, TERMINATOR=2, WHITESPACE=3, QUOTE=4 };
    unsigned            maxColumns;
    StringMatcher       matcher;
    unsigned            numQuotes;
    unsigned *          lengths;
    const byte * *      data;
    byte *              unquotedBuffer;
    byte *              curUnquoted;
    unsigned            maxCsvSize;
};

class THORHELPER_API CSVOutputStream : public StringBuffer, implements ITypedOutputStream
{
public:
    void beginLine();
    void writeHeaderLn(size32_t len, const char * data); // no need for endLine
    void endLine();
    void init(ICsvParameters * args, bool _oldOutputFormat);

    virtual void writeReal(double value)                    { append(prefix).append(value); prefix = separator; }
    virtual void writeSigned(__int64 value)                 { append(prefix).append(value); prefix = separator; }
    virtual void writeString(size32_t len, const char * data);
    virtual void writeUnicode(size32_t len, const UChar * data);
    virtual void writeUnsigned(unsigned __int64 value)      { append(prefix).append(value); prefix = separator; }
    virtual void writeUtf8(size32_t len, const char * data);

protected:
    StringAttr separator;
    StringAttr terminator;
    StringAttr quote;
    const char * prefix;
    bool oldOutputFormat;
};

#endif // CSVSPLITTER_INCL
