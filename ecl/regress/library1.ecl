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

namesRecord :=
            RECORD
string20        surname;
string10        forename;
integer2        age := 25;
            END;

FilterDatasetLibrary(string search, dataset(namesRecord) ds, boolean onlyOldies) := interface
    export included := ds;
    export excluded := ds;
    export string name;
end;

//namesTable := dataset('x',namesRecord,FLAT);
namesTable := dataset([
        {'Hawthorn','Gavin',31},
        {'Hawthorn','Mia',30},
        {'Smithe','Pru',10},
        {'X','Z'}], namesRecord);

boolean isFCRA := false : stored('isFCRA');
NameFilterName := IF(isFCRA, 'NameFilter.FCRA', 'NameFilter');

filtered := LIBRARY(NameFilterName, FilterDatasetLibrary('Smith', namesTable, false));
output(filtered.included,,named('Included'));

filtered2 := LIBRARY(NameFilterName, FilterDatasetLibrary, 'Hawthorn', namesTable, false);
output(filtered2.excluded,,named('Excluded'));
