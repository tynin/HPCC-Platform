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


#ifndef _thactivityutil_ipp
#define _thactivityutil_ipp

#include "jlib.hpp"
#include "jlzw.hpp"
#include "jfile.hpp"
#include "jmisc.hpp"
#include "jthread.hpp"
#include "jbuff.hpp"

#include "thormisc.hpp"
#include "thmem.hpp"
#include "thbuf.hpp"
#include "thgraphslave.hpp"
#include "eclhelper.hpp"
#define NO_BWD_COMPAT_MAXSIZE
#include "thorcommon.ipp"

#define OUTPUT_RECORDSIZE


//void startInput(CActivityBase *activity, IThorDataLink * i, const char *extra=NULL);
//void stopInput(IThorDataLink * i, const char * activityName = NULL, activity_id activitiyId = 0);

class CPartHandler : public CSimpleInterface, implements IRowStream
{
public:
    IMPLEMENT_IINTERFACE_USING(CSimpleInterface);

    virtual ~CPartHandler() { }
    virtual void setPart(IPartDescriptor *partDesc, unsigned partNoSerialized) = 0;
    virtual void getMetaInfo(ThorDataLinkMetaInfo &info, IPartDescriptor *partDesc) { }
    virtual void stop() = 0;
};

IRowStream *createSequentialPartHandler(CPartHandler *partHandler, IArrayOf<IPartDescriptor> &partDescs, bool grouped);

#define CATCH_NEXTROWX_CATCH \
        catch (IException *_e) \
        { \
            IThorException *e = QUERYINTERFACE(_e, IThorException); \
            if (e) \
            { \
                if (!e->queryActivityId()) \
                    setExceptionActivityInfo(container, e); \
            } \
            else \
            {  \
                e = MakeActivityException(this, _e); \
                _e->Release(); \
            }  \
            if (!e->queryNotified()) \
            { \
                fireException(e); \
                e->setNotified(); \
            } \
            throw e; \
        }

#define CATCH_NEXTROW() \
    const void *nextRow() \
    { \
        try \
        { \
            return nextRowNoCatch(); \
        } \
        CATCH_NEXTROWX_CATCH \
    } \
    const void *nextRowNoCatch()

class CThorDataLink : implements IThorDataLink
{
    CActivityBase *owner;
    rowcount_t count, icount;
    char *activityName;
    activity_id activityId;
    unsigned outputId;
    unsigned limit;

protected:
    inline void dataLinkStart()
    {
        dataLinkStart(NULL, 0);
    }

    inline void dataLinkStart(const char * _activityName, activity_id _activityId, unsigned _outputId = 0)
    {
        if(_activityName) 
        {
            StringBuffer x(_activityName);
            activityName = x.toUpperCase().detach();
            activityId = _activityId;
            outputId = _outputId;
        }
#ifdef _TESTING
        ActPrintLog(owner, "ITDL starting for output %d", outputId);
#endif
#ifdef _TESTING
        assertex(!started() || stopped());      // ITDL started twice
#endif
        icount = 0;
//      count = THORDATALINK_STARTED;
        rowcount_t prevCount = count & THORDATALINK_COUNT_MASK;
        count = prevCount | THORDATALINK_STARTED;
    }

    inline void dataLinkStop()
    {
#ifdef _TESTING
        assertex(started());        // ITDL stopped without being started
#endif
        count |= THORDATALINK_STOPPED;
#ifdef _TESTING
        ActPrintLog(owner, "ITDL output %d stopped, count was %"RCPF"d", outputId, getDataLinkCount());
#endif
        if(activityName) 
        {
            free(activityName);
            activityName = NULL;
        }
    }

    inline void dataLinkIncrement()
    {
        dataLinkIncrement(1);
    }

    inline void dataLinkIncrement(rowcount_t v)
    {
#ifdef _TESTING
        assertex(started());
#ifdef OUTPUT_RECORDSIZE
        if (count==THORDATALINK_STARTED) {
            size32_t rsz = queryRowMetaData(this)->getRecordSize(NULL);
            ActPrintLog(owner, "Record size %s= %d", queryRowMetaData(this)->isVariableSize()?"(max) ":"",rsz);
        }   
#endif
#endif
        icount += v;
        count += v; 
    }

    inline bool started()
    {
        return (count & THORDATALINK_STARTED) ? true : false; 
    }

    inline bool stopped()
    {
        return (count & THORDATALINK_STOPPED) ? true : false;
    }


public:
    CThorDataLink(CActivityBase *_owner) : owner(_owner)
    {
        icount = count = 0;
        activityName = NULL;
        activityId = 0;
    }
#ifdef _TESTING
    ~CThorDataLink()
    { 
        if(started()&&!stopped())
        {
            ActPrintLog(owner, "ERROR: ITDL was not stopped before destruction");
            dataLinkStop(); // get some info (even though failed)       
        }
    }           
#endif

    void dataLinkSerialize(MemoryBuffer &mb)
    {
        mb.append(count);
    }

    unsigned __int64 queryTotalCycles() const { return ((CSlaveActivity *)owner)->queryTotalCycles(); }

    inline rowcount_t getDataLinkGlobalCount()
    {
        return (count & THORDATALINK_COUNT_MASK); 
    } 
    inline rowcount_t getDataLinkCount()
    {
        return icount; 
    } 

    CActivityBase *queryFromActivity() { return owner; }

    void initMetaInfo(ThorDataLinkMetaInfo &info); // for derived children to call from getMetaInfo
    static void calcMetaInfoSize(ThorDataLinkMetaInfo &info,IThorDataLink *input); // for derived children to call from getMetaInfo
    static void calcMetaInfoSize(ThorDataLinkMetaInfo &info,IThorDataLink **link,unsigned ninputs);
    static void calcMetaInfoSize(ThorDataLinkMetaInfo &info, ThorDataLinkMetaInfo *infos,unsigned num);
};

interface ISmartBufferNotify
{
    virtual bool startAsync() =0;                       // return true if need to start asynchronously
    virtual void onInputStarted(IException *e) =0;      // e==NULL if start suceeded, NB only called with exception if Async
    virtual void onInputFinished(rowcount_t count) =0;
};

class CThorRowAggregator : public RowAggregator
{
    CActivityBase &activity;
    
public:
    CThorRowAggregator(CActivityBase &_activity, IHThorHashAggregateExtra &extra, IHThorRowAggregator &helper) : RowAggregator(extra, helper), activity(_activity)
    {
    }

// overloaded
    AggregateRowBuilder &addRow(const void *row);
    void mergeElement(const void *otherElement);
};

interface IDiskUsage;
IThorDataLink *createDataLinkSmartBuffer(CActivityBase *activity,IThorDataLink *in,size32_t bufsize,bool spillenabled,bool preserveLhsGrouping=true,rowcount_t maxcount=RCUNBOUND,ISmartBufferNotify *notify=NULL, bool inputstarted=false, IDiskUsage *_diskUsage=NULL); //maxcount is maximum rows to read set to RCUNBOUND for all

bool isSmartBufferSpillNeeded(CActivityBase *act);

StringBuffer &locateFilePartPath(CActivityBase *activity, const char *logicalFilename, IPartDescriptor &partDesc, StringBuffer &filePath);
void doReplicate(CActivityBase *activity, IPartDescriptor &partDesc, ICopyFileProgress *iProgress=NULL);
void cancelReplicates(CActivityBase *activity, IPartDescriptor &partDesc);

interface IPartDescriptor;
IFileIO *createMultipleWrite(CActivityBase *activity, IPartDescriptor &partDesc, unsigned recordSize, bool &compress, bool extend, ICompressor *ecomp, ICopyFileProgress *iProgress, bool direct, bool renameToPrimary, bool *aborted, StringBuffer *_locationName=NULL);


#endif
