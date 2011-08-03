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

//Check a single child records can be treated as a blob

childRecord := RECORD
unsigned4 person_id;
string20  per_surname := 'x';
string20  per_forename;
unsigned8 holepos;
    END;

parentRecord :=
                RECORD
unsigned8           id;
string20            address1;
string20            address2;
string20            address3;
unsigned2           numPeople;
DATASET(childRecord, COUNT(SELF.numPeople))   children;
string10            postcode;
                END;

parentDataset := DATASET('test',parentRecord,FLAT);

rollupParentRecord :=
                RECORD
unsigned8           id;
unsigned4           count_person_id;
                END;

rollupParentRecord rollupPeople(parentRecord l) :=
TRANSFORM
    SELF := l;
    SELF.count_person_id := COUNT(l.children(l.children.per_surname != l.children[1].per_surname));
END;

rolledupParent := project(parentDataset, rollupPeople(LEFT));

output(rolledupParent,,'out.d00');
