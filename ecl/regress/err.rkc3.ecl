/*##############################################################################

    Copyright (C) 2011 HPCC Systems.

    All rights reserved. This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
############################################################################## */

person := dataset('person', { unsigned8 person_id, string2 per_st, string10 per_first_name, string10 per_last_name }, thor);
tmp_r :=
  record
    st := person.per_st;
  end;

tmp_t:= table(person(per_st in ['FL']), tmp_r);
inputTable := tmp_t;
inputRecord := tmp_r;

seedRecord :=
  record
    string25 per_last_name;
    string15 per_first_name;
    string42 per_street;
    string20 per_full_city;
    string4 per_abr_city;
    string2 per_st;
    string5 per_zip;
    string4 per_ssn;
    string9 per_cid;
  end;

seedTable := dataset('seeding_test::56recs_seed_file', seedRecord,
flat);

//  Calc included states.
stateTable := table(inputTable, {st}, st);

//  Sequence Seed Table
seedSeqRecord :=
  record
    integer8 seqNum;
    seedRecord;
  end;

seedSeqRecord toSeq(seedTable L) :=
  transform
    self.seqNum := 0;
    self.per_st := L.per_st;
  end;

tmpA := join(seedTable, stateTable, left.per_st = right.st,
toSeq(left));

seedSeqRecord createSeqNum(seedSeqRecord L, seedSeqRecord R) :=
  transform
    self.seqNum := L.seqNum + 1;
    self := R;
  end;

seedSeqTable := iterate(tmpA, createSeqNum(left, right));
seedSeqCount := count(seedSeqTable);

inputSeqRecord :=
  record
    integer8 seqNum;
    inputRecord;
  end;

//inputPartialTable := choosen(inputTable, seedSeqCount);
inputPartialTable := choosen(table(inputTable, inputRecord), 56);

inputSeqRecord toSeqInput(inputRecord L) :=
  transform
    self.seqNum := 0;
    self := L;
  end;

tmpB := project(inputPartialTable, toSeqInput(left));
inputSeqRecord createSeqInput(inputSeqRecord L, inputSeqRecord R) :=
  transform
    self.seqNum := l.seqNum + 1;
    self := r;
  end;

inputPartialSeqTable := iterate(tmpB, createSeqInput(left, right));

inputSeqRecord seededTransform(inputSeqRecord L, seedSeqRecord R) :=
  transform
    self := l;
    self := r;
  end;

inputPartialSeedJoin := join(inputPartialSeqTable, seedSeqTable,
left.seqNum = right.seqNum, seededTransform(left, right));

labelTest := inputPartialSeedJoin + inputTable;

output(inputPartialSeedJoin);
