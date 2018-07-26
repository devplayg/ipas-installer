#!/usr/bin/perl -w
use strict;
use warnings;
use Term::ANSIColor;


status("Time", "/bin/date '+%Y-%m-%d %H:%M:%S'");
#status("CPU", "/usr/bin/mpstat");
status("Memory", "/bin/grep '^Mem' /proc/meminfo && awk '/^MemFree/ {free=\$2} /^MemTotal/ {total=\$2} END {print \"MemUsage:         \" (total-free) / total * 100  \" \%\"  }' /proc/meminfo");
status("Disk", "/bin/df");
statuskv("Service (command, cpu, mem, started, uptime) ", '/bin/ps -C \'scheduler,classifier\' -o "comm,%cpu,%mem,etime,lstart" --no-headers ', "", "classifier,scheduler");
statuskv_cut("Listening (service, port)", '/bin/netstat -lntpu | grep -E "^tcp|^udp" | awk \'{ gsub(".*:","",$4); gsub("^LISTEN|.*/","",$6); gsub(".*/","",$7);  print $6$7"\t"$4}\'', "", "mcs,receiver,mysqld");
#statuskv_cut("Processes (APTX-AM)", '/bin/netstat -lntpu | grep -E "^tcp|^udp" | awk \'{ gsub(".*:","",$4); gsub("^LISTEN|.*/","",$6); gsub(".*/","",$7);  print $6$7"\t"$4}\'', "", "AMServer,httpd");
statuskv("IP Tables", '/sbin/iptables -n -L INPUT  --line-number | grep "^[0-9]" | awk \'{$1=$2=$3=$4=$5=$6=""; gsub("dpts?:", "", $0);gsub("state NEW", "", $0);  print $0}\' | awk \'{print $2"_"$1"\t "}\' | uniq', "", "80_tcp,8080_tcp");
status("Defunct process", "/bin/ps -ef | grep defunct | grep -v 'grep defunct'");



sub status {
    my ( $title, $cmd, $home_dir ) = @_;
    if ( $home_dir ) {
        chdir( $home_dir );
    }
    print_title( "green", $title );

    my ($file) = split(/\s/, $cmd);
    if (-e $file) {
        my @row = `$cmd`;
        chomp(@row);
        if ($#row >= 0) {
            foreach (@row) {
                if ($_ =~ /\s+NOT\s+/) {
                    print color( "bold ", "yellow on_magenta" );
                    print "\t" , $_, "\n";
                    print color( "reset" );
                    #print colored("\t[ERROR] ". $_ . "\n" , 'yellow on_magenta');
                    #print color( "reset" );

                } else {
                    print "\t",  $_, "\n";
                }

            }
        } else {
            print "\tN/A\n";
        }
    } else {
        print "\t[ERROR] Cannot find command: ", $file, "\n";
    }
}


sub print_title {
    my ( $color, $str ) = @_;
    print color( "bold ", $color );
    print "# " , $str, "\n";
    print color( "reset" );
}

sub print_ansi {
    my ( $color, $str ) = @_;
    print color( $color );
    print $str;
    print color( "reset" );
}


sub statuskv {
    my ($title, $cmd, $home_dir, $checklist) = @_;
    if ($home_dir) {
        chdir($home_dir);
    }
    print_title( "green", $title );

    my ($file) = split(/\s/, $cmd);
    if (-e $file) {
        my @row = `$cmd`;
        chomp(@row);
        my %item = ();
        foreach (@row) {
            my ($k, $v) = split(/\s+/, $_, 2);
            $item{ $k } .= $v.",";
        }

        if ( $checklist ) {
            foreach my $p (split /,/, $checklist) {
                if ($item{$p}) {
                    printf("\t%-15s%22s\n", $p, substr($item{$p}, 0, -1));
                } else {
                    my $str = sprintf("[ERROR] %s", $p);
                    print "\t";
                    print colored("[ERROR] ". $p, 'yellow on_magenta');
                    print "\n";
                }
            }
        }
    } else {
        print "\t[ERROR] Cannot find command: ", $file, "\n";
    }
}



sub statuskv_cut {
    my ($title, $cmd, $home_dir, $checklist) = @_;
    if ($home_dir) {
        chdir($home_dir);
    }
    print_title( "green", $title );

    my ($file) = split(/\s/, $cmd);
    if (-e $file) {
        my @row = `$cmd`;
        chomp(@row);
        my %item = ();
        foreach (@row) {
            my ($k, $v) = split(/\s+/, $_, 2);
            $k = substr($k, 0, 13);
            $item{ $k } .= $v.",";
        }

        if ($checklist) {
            foreach my $p (split /,/, $checklist) {
                $p = substr($p, 0, 13);
                if ($item{$p}) {
                    printf("\t%-15s%22s\n", $p, substr($item{$p}, 0, -1));
                } else {
                    my $str = sprintf("[ERROR] %s", $p);
                    print "\t";
                    print colored("[ERROR] ". $p, 'yellow on_magenta');
                    print "\n";
                }
            }
        }
    } else {
        print "\t[ERROR] Cannot find command: ", $file, "\n";
    }

}

