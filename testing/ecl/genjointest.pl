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

use strict;
use warnings;
use JoinTest;

sub genfile($$$$ )
{
    my ($filename, $decs, $outs, $comments) = @_;
    open(FOUT, ">$filename") or die("Could not open $filename to write: $?");
    print(FOUT "// IMPORTANT: this test is generated by the perl script genjointest.pl, so do not edit it by hand\n");
    print(FOUT "//$_\n") foreach(@$comments);
    my $datapos = tell(DATA);
    print(FOUT $_) while(<DATA>);
    seek(DATA, $datapos, 0);
    print(FOUT "\n");
    print(FOUT "$_;\n") foreach (@$decs);
    print(FOUT "\n");
    print(FOUT "SEQUENTIAL(", join(",\n           ", @$outs), ");\n");
    close(FOUT);
}

sub mapitem($$$)
{
    my ($newname, $newvals, $prev) = @_;
    return map({{%$prev, $newname => $_}} @$newvals);
}

sub maplist($$@)
{
    my ($newname, $newvals, @old) = @_;
    return map({mapitem($newname, $newvals, $_)} @old);
}

sub multimap(@);

sub multimap(@)
{
    my $last = pop();
    if(@_)
    {
        return maplist($last->{name}, $last->{vals}, multimap(@_));
    }
    else
    {
        return mapitem($last->{name}, $last->{vals}, {});
    }
}

my $limitval = 3;
my $keepval = 2;

my @tests = map({JoinTest->new(%$_, limitval => $limitval, keepval => $keepval)} multimap(@JoinTest::factors));

my @decs;
my @outs;
my @nothor_decs;
my @nothor_outs;
my @justroxie_decs;
my @justroxie_outs;
foreach my $test (@tests)
{
    next if($test->forbidden());
    my $justroxie = $test->justroxie();
    my $nothor = $test->nothor();
    if($justroxie)
    {
        push(@justroxie_decs, $test->defecl());
    }
    elsif($nothor)
    {
        push(@nothor_decs, $test->defecl());
    }
    else
    {
        push(@decs, $test->defecl());
    }
    next if($test->fails());
    if($justroxie)
    {
        push(@justroxie_outs, $test->outecl());
    }
    elsif($nothor)
    {
        push(@nothor_outs, $test->outecl());
    }
    else
    {
        push(@outs, $test->outecl());
    }
}

genfile('genjoin.ecl', \@decs, \@outs, []);
genfile('genjoin_nothor.ecl', \@nothor_decs, \@nothor_outs, ['nothor']);
genfile('genjoin_justroxie.ecl', \@justroxie_decs, \@justroxie_outs, ['nothor', 'nohthor']);

my $posscount = @tests;
my $deccount = @decs + @nothor_decs + @justroxie_decs;
my $gencount = @outs + @nothor_outs + @justroxie_outs;
my $justroxiecount = @justroxie_outs;
my $nothorcount = @nothor_outs;
my $maincount = @outs;
my $forbidcount = $posscount - $deccount;
my $failcount = $deccount - $gencount;
print(STDERR "$posscount combinations calculated\n");
print(STDERR "$forbidcount judged illegal\n");
print(STDERR "$failcount would fail\n");
print(STDERR "$gencount tests generated ($maincount to main test, $nothorcount to nothor test, and $justroxiecount to justroxie test)\n");

__DATA__

#option('convertJoinToLookup', 0);
#option('noAllToLookupConversion', 1);
#option('spanMultipleCpp', 1);

jrec := RECORD,MAXLENGTH(100)
    UNSIGNED1 i;
    STRING3 lstr;
    STRING3 rstr;
    UNSIGNED1 c;
    STRING label;
END;

lhs := SORTED(DATASET([{3, 'aaa', '', 0, ''}, {4, 'bbb', '', 0, ''}, {5, 'ccc', '', 0, ''}, {6, 'ddd', '', 0, ''}, {7, 'eee', '', 0, ''}], jrec), i);
rhs := SORTED(DATASET([{1, '', 'fff', 0, ''}, {3, '', 'ggg', 0, ''}, {5, '', 'hhh', 0, ''}, {5, '', 'iii', 0, ''}, {5, '', 'xxx', 0, ''}, {5, '', 'jjj', 0, ''}, {7, '', 'kkk', 0, ''}, {9, '', 'lll', 0, ''}, {9, '', 'mmm', 0, ''}], jrec), i);

trueval := true : stored('trueval');
falseval := false : stored('falseval');
BOOLEAN match1(jrec l, jrec r) := (l.i = r.i);
BOOLEAN match2(jrec l, jrec r) := (r.rstr < 'x');
BOOLEAN match(jrec l, jrec r) := (match1(l, r) AND match2(l, r));
BOOLEAN allmatch1(jrec l, jrec r) := ((match1(l, r) AND trueval) OR falseval);
BOOLEAN allmatch(jrec l, jrec r) := (allmatch1(l, r) AND match2(l, r));

// transform for joins and non-group denormalizes, to be used with match or allmatch
jrec xfm(jrec l, jrec r, STRING lab) := TRANSFORM
    SELF.i := l.i;
    SELF.lstr := l.lstr;
    SELF.rstr := r.rstr;
    SELF.c := l.c+1;
    SELF.label := lab;
END;

// skipping transform for joins and non-group denormalizes
// when used with match1 or allmatch1, similar to the above, but remember that right outer picks up rows whose matches failed but not ones whose transforms skipped
jrec xfmskip(jrec l, jrec r, STRING lab) := TRANSFORM
    SELF.i := l.i;
    SELF.lstr := l.lstr;
    SELF.rstr := IF(r.rstr >= 'x', SKIP, r.rstr);
    SELF.c := l.c+1;
    SELF.label := lab;
END;

// transform for group denormalizes, to be used with match or allmatch
jrec xfmgrp(jrec l, DATASET(jrec) r, STRING lab) := TRANSFORM
    UNSIGNED c := COUNT(r);
    SELF.i := l.i;
    SELF.lstr := l.lstr;
    SELF.rstr := r[c].rstr;
    SELF.c := c;
    SELF.label := lab;
END;

// skipping transform for group denormalizes, to be used with match or allmatch
// used with match1 or allmatch1, but has a different behaviour because a skip on a group denormalize skips the whole group rather than just one row
jrec xfmgrpskip(jrec l, DATASET(jrec) r, STRING lab) := TRANSFORM
    UNSIGNED c := COUNT(r);
    UNSIGNED skp := COUNT(r(rstr >= 'x'));
    SELF.i := l.i;
    SELF.lstr := l.lstr;
    SELF.rstr := IF(skp > 0, SKIP, r[c].rstr);
    SELF.c := c;
    SELF.label := lab;
END;
