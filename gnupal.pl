#!/usr/bin/perl -w
#
#    Copyright (c) 2011 Koen Martens <gmc@sonologic.nl>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

use strict;
use Text::CSV_XS;
use Date::Parse;

my $netacc='Assets:Current Assets:Paypal';
my $grossacc='Paypal-import';
my $feeacc='Expenses:Fees:Paypal';

my $csv=Text::CSV_XS->new({binary=>1});


sub fieldidx {
  my $name=shift;

  my @fieldnames = qw( date time tz name type status currency bruto fee net from_email to_email ref from address title id shipping insurance vat opt1_name opt1_value opt2_name opt2_value site buyerid object_url enddate escrowid invoicedata refid invoice adjusted receipt balance adr1 adr2 city state zip country telno );

  my ($idx) =  grep { $fieldnames[$_] eq $name } 0..$#fieldnames;

  return $idx;
}

print "!Account\n";
print "N$grossacc\n";
print "TBank\n";
print "^\n";
print "!Type:Bank\n";

<>;
while(<>) { 
  if($csv->parse($_)) {
    my @fields=$csv->fields();

    die('Unparseable date '.$fields[fieldidx('date')]) unless($fields[fieldidx('date')]=~/^([0-9]{2})-([0-9]{2})-([0-9]{4})$/);

    print "D$2/$1/$3\n";

    my $gross=$fields[fieldidx('bruto')];
    $gross=~s/\./,/g;
    $gross=~s/\,([0-9]{2})$/.$1/g;
    $gross=~s/,//g;

    my $fee=$fields[fieldidx('fee')];
    $fee=~s/\./,/g;
    $fee=~s/\,([0-9]{2})$/.$1/g;
    $fee=~s/,//g;

    my $net=$fields[fieldidx('net')];
    $net=~s/\./,/g;
    $net=~s/\,([0-9]{2})$/.$1/g;
    $net=~s/,//g;

    my $desc=$fields[fieldidx('title')].' '.$fields[fieldidx('invoicedata')].' '.$fields[fieldidx('invoice')].' from '.$fields[fieldidx('from_email')].' to '.$fields[fieldidx('to_email')];
    $desc=~s/^\s//g;
    $desc=~s/\s$//g;
    $desc=~s/\s+/ /g;

    print "N".$fields[fieldidx('ref')]."\n";
    print "U".(0-$gross)."\n";
    print "T".(0-$gross)."\n";
    print "P$desc\n";
    print "C*\n";
    print "L$grossacc\n";
    print "S$netacc\n";
    print "EImported paypal payment\n";
    print '$'.(0-$net)."\n";
    print "S$feeacc\n";
    print "EPaypal fee\n";
    print '$'.$fee."\n";
    print "^\n"; 

  } else {
    die('unable to parse line: '.$_);
  }
}
close(PAL);

