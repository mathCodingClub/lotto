#!/usr/bin/perl

use DBI;

my $dbh = DBI->connect('dbi:mysql:database=mcc_lotto;host=localhost','mcc','smgIsNoMore',{AutoCommit=>1,RaiseError=>1,PrintError=>0});

my $sth = $dbh->prepare('INSERT INTO rivi(num1,num2,num3,num4,num5,num6,num7,num8,num9,num10,num11,num12, pvm, kierros,vuosi,varsiNroa,extraNroa) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)')
                or die "Couldn't prepare statement: " . $dbh->errstr;

sub checkGameMode {

    my ($round, $year) = @_;

    if ($year == 1971)
    {
      return (6, 3);
    }
    elsif($year >= 1972 && $year <= 1980)
    {
      if($year == 1980 && $round >= 40)
      {
        return (7, 4);
      }
      else
      {
        return (6, 2);
      }
    }
    elsif($year > 1980 && $year < 1986)
    {
      return (7, 4);
    }
    elsif($year >= 1986 && $year <= 2011)
    {
      if($year == 1986 && $round == 1)
      {
        return (7, 4);
      }
      elsif($year == 1986 && $round < 17)
      {
        return (7, 0);
      }
      elsif($year == 2011 && $round >= 41)
      {
         return (7, 2);
      }
      else
      {
        return (7, 3);
      }
    }
    else
    {
      return (7, 2);
    }
}

for (my $vuosi = $ARGV[0]; $vuosi <= 2014; $vuosi++)
{
  for(my $kierros = 1; $kierros <= 52; $kierros++)
  {

    my ($varsiNro, $extraNro) = checkGameMode($kierros, $vuosi);
    
    print "Now getting round $kierros/$vuosi\n, pelimuoto $varsiNro+$extraNro";
    my $url = "'https://www.veikkaus.fi/mobile?area=results&comesfrom=results&op=normal_search&game=lotto&round="
          . $kierros . "&year="
          . $vuosi . "&Z_ACTION=Hae'";

    sleep(int(rand(2))+1); #wait so we don't clog the veikkaus service
    my $output = `curl -s -k $url`;

    last if $output =~ m/no_results_message/g;

    my $date_string = "";
    while($output =~ /Arvonta:.*?(\d{1,2}).*?(\d{1,2}).*?(\d{1,4})<\/p>/g)
    {
      $date_string = join("-",$3,$2,$1);
      last;
    }

    my @numbers = [];

    while($output =~ /<td>(.*?)<\/td>/g)
    {
      push(@numbers, $1);
    }

    while($output =~ /<td\sclass=\"secondary\">(.*?)<\/td>/g)
    {
      push(@numbers, $1);
    }

    while(scalar @numbers < 13)
    {
      print "Adding extra zeros...\n";
      push(@numbers, 0);
    }

    shift @numbers;

    $sth->execute($numbers[0],$numbers[1],$numbers[2],$numbers[3],$numbers[4],$numbers[5],$numbers[6],
                 $numbers[7],$numbers[8], $numbers[9],$numbers[10],$numbers[11],
                 $date_string, $kierros, $vuosi,$varsiNro,$extraNro
                 );
  }
}
