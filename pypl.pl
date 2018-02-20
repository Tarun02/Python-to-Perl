#!/usr/bin/perl -w

# Starting point for COMP[29]041 assignment 1
# http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by z5152892@unsw.edu.au September 2017

my @logical_operators=("and","or","not");
my $comment;
my $space;
my @loops_indentation;
my $recurse_flag;
my $Flag;
$space='';
my %hash_table;
my $brack_flag;


while ($line = <>) {
	$recurse_flag=0;
	$comment='';
	$brack_flag=0;
	if ($line =~ /^#!/ && $. == 1) {
		# translate #! line
		print "#!/usr/bin/perl -w\n";
	} elsif ($line =~ /^\s*(#|$)/) {
		# Blank & comment lines can be passed unchanged
		print $line;
	} elsif ($line =~ m/^(\s*)print.*$/) {
		# Python's print outputs a new-line character by default
        # so we need to add it explicitly to the Perl print statement
		if(@loops_indentation){
			if(not eof()){                                                    
				space($1);
				print "$1"; 
				comments($line);
				print_statements($line);
				print "  $comment\n";
				$space=$1;
			}else{
				#print "Tarun";
				if(length($1)<length($space)){
					#print "Prasad";
					space($1);
					print "$1"; 
					comments($line);
					print_statements($line);
					print "  $comment\n";
				}else{
					print "$1"; 
					comments($line);
					print_statements($line);
					print "  $comment\n";
					print "}\n";
				}
			}
		}else{
			print "$1"; 
			comments($line);
			print_statements($line);
			print "  $comment\n";
			$space=$1;
		}
	} elsif ($line =~ /^(\s*)while[\s+|\)].*\)?:.*$/){
		
		#While loop
		push @loops_indentation,$1;
		space($1);
		comments($line);
		while_loop($line);
		$space=$1;
		
	} elsif ($line =~ /^(\s*)if[\s+|\(](.*)\)?:.*$/){
		
		#if loop
		push @loops_indentation,$1;
		space($1);
		comments($line);
		if_loop($line);
		$space=$1;
		
	} elsif ($line =~ /^(\s*)(.*)\s*for ([a-zA-Z0-9]+) in range\((.*)\)\s*.*/){
	
		#For loop with range	
		comments($line);
		space($1);
		print "$1foreach \$$3 (";
		for_loop($4);
		$space=$1;
		if($2){
			print "$1    ";
			assignment_commands($2);
			print ";\n";
			print "$1}\n";
		}else{
			push @loops_indentation,$1;
		}
		
	} elsif ($line =~ /^(\s*)(.*)for ([a-zA-Z0-9]+) in sys\.stdin:.*$/){
	
		#For loop for standard input
		push @loops_indentation,$1;
		comments($line);
		space($1);
		print "$1foreach \$$3 (<STDIN>){   $comment\n";
		$space=$1;
		
	} elsif ($line =~ /^(\s*)elif[\s+|\)](.*)\)?:.*$/){
	
		#For elif condition
		comments($line);
		print "$1}elsif(";
		numeric_comparision($2);
		$space=$1;
		
	} elsif ($line =~ /^(\s*)else\s*:.*$/){
		
		#For else condition
		comments($line);
		print "$1}else{\n     $comment";
		
	} elsif ($line =~ /^(\s*)sys.stdout.write\(\"(.*)\"\)\s*.*$/){
		
		#For standard output
		comments($line);
		print "$1print \"$2\";   $comment\n";
		$space=$1;
		
	} elsif ($line =~ /^import sys\s*$/){
	
		#Prints and empty line if it is import sys
		comments($line);
		;
		
	} elsif ($line =~ /^(\s*)([a-zA-Z0-9\s]*)\s*=\s*.*\(sys\.stdin\.readline\(\)\)\s*.*$/){
	
		#For the x=standard output type of instructions
		comments($line);
		print "$1\$$2 = <STDIN>\;    $comment\n";
		$space=$1;
		
	} elsif ($line =~ /^(\s*)([a-zA-Z0-9]*)\s*=?\s*(.*)\.([ap|po|so]+.+)\((.*)\)\s*.*$/){
	
		#The insruction is for append,pop,sort
		comments($line);
		space($1);
		print "$1";
		$space=$1;
		if ($4 eq "append"){
			print "push \@$2, \$$5;  $comment\n";
		}elsif ($4 eq "pop"){
			print "\$$2 = pop \@$3;   $comment\n";
		}else{
			print "\$$2 = sort \@$3;   $comment\n";
		}
		
	} elsif ($line =~ /^(\s*)([a-zA-Z0-9]+)\s*=\s*\[(.*)\].*$/){
	
		#For array initializations like l=[]
		comments($line);
		$hash_table{$2}="array";
		space($1);
		print "$1my \@$2";
		if ($3){
			print "=";
			array_elements($3);
		}else{
			print ";    $comment\n";
		}
		$space=$1;
		
	} elsif ($line =~ /^(\s*)([a-zA-Z0-9]+)\s*=\s*len\((.*)\)(.*).*$/){
	
		#For length if it is an array it will print scalar
		#It prints length if it a string
		comments($line);
		space($1);
		print "$1\$$2 =";
		if($hash_table{$3} eq "array"){
			print "scalar \@$3";
			assignment_commands($4);
		}else{
			print "length \$$3";
			assignment_commands($4);
		}
		print ";   $comment\n";
		$space=$1;
		
	} elsif ($line =~ /^(\s*)([a-zA-Z0-9\s]*)=(.*).*$/){
	
		#Varible initializations like a=b+c or a=x+1 and so on
		if(@loops_indentation){
			if(not eof()){
				space($1);
				print "$1";
				comments($line);
				print "\$$2= ";
				assignment_commands($3);								###Indentation took me long time to crack and different cases arised 
				print ";  $comment\n";									###when i am working on it.So I have done the best to consider all cases		
				$space=$1;												###and this is the logic I have come up with and i am including this in variable
			}else{														###initializations and in print statements the most common cases of EOF instructions
				if(length($1)<length($space)){									
					space($1);
					print "$1";
					comments($line);
					print "\$$2= ";
					assignment_commands($3);
					print ";  $comment\n";
				}else{
					print "$1";
					comments($line);
					print "\$$2= ";
					assignment_commands($3);
					print ";  $comment\n";
					print "}\n";
				}
			}
		}else{
			print "$1";
			comments($line);
			print "\$$2= ";
			assignment_commands($3);
			print ";  $comment\n";
			$space=$1;
		
		}
	} elsif ($line =~ /^(\s*)break.*$/){
	
		#For break instruction
		space($1);
		comments($line);
		print "$1last;  $comment\n";
		$space=$1;
		
	} elsif ($line =~ /^(\s*)continue.*$/){
	
		#For continue instruction
		space($1);
		comments($line);
		print "$1next;  $comment\n";
		$space=$1;
		
	} else{
       
		# Lines we can't translate are turned into comments
		print "#$line\n";
		
    }
}


###For different kinds of print statement
###It is not exhaustive cases but will cover most of them
sub print_statements{
	#print "0";
	my ($print)=@_;
	if($print =~ /^\s*print\("(.*)"\).*$/){
		#print "1";
		print "print \"$1\\n\";";
	} elsif ($print =~ /^\s*print\(([a-zA-Z0-9]+)(.*\s+)([a-zA-Z0-9]+)\).*$/){
		#print "2";
		print "print \$$1$2\$$3,\"\\n\";";
	} elsif ($print =~ /^\s*print\(([a-zA-Z0-9]+),?[end=]?\).*$/){
		#print "3";
		print "print \"";
		assignment_commands($1);
		print "\\n\";\n";
	}  elsif($print =~ /^\s*print\(\)/){
		#print "5";
		print "print \"\\n\";";
	} elsif($print =~ /^\s*print\("(.*)"[,]+\s*([a-zA-Z0-9]+)\s*([^a-zA-Z0-9])\s*([a-zA-Z0-9]+)\s*\)$/){
		#print "6";
		print "print \"$1 \",";
		assignment_commands($2);
		print "$3";
		assignment_commands($4);
		print ",\"\\n\";\n";
	} elsif($print =~ /^\s*print\(([a-zA-Z0-9]+)\s*[,]?\s*"(.*)"\)$/){
		#print "7";
		print "print ";
		assignment_commands($1);
		print ",\"$2\\n\";";
	} elsif($print =~ /^\s*print\((.*)\)\s*$/){
		print "print ";
		$print_flag=0;
		my @sep_commas=split /,/,$1;
		foreach $s(@sep_commas){
			if($print_flag==1){
				if($s =~ /"(.*)"/){
					print ",\"$1\"";
				}else{
					print ",";
					assignment_commands($s);
				}
			}else{
				if($s =~ /"(.*)"/){
					print "\"$1\"";
				}else{
					print ",";
					assignment_commands($s);
				}
			
			}
			$print_flag=1;
		}
		print ",\"\\n\";"; 
	}
}

###Assignment initializations like x=x+y,x=2y,x=t**v ect
###Fucntion for different operators 
sub assignment_commands{                                         
	#print "TArun";
	my ($assignment)=@_;
	#print "Yerneni$assignment";
	$Flag=0;
	@tokens=split /\s+/,$assignment;
	foreach my $i(@tokens){
		if ($i =~ m/[\/\/]/){
			#print "$i";
			$Flag=1;
			last;
		}
	}
	###This flag is for a special case of // of python
	###In perl we have to use int in front of the expressio 
	if($Flag == 1){
		print "int ";
	}
	###Splitting the argument into characters
	###If it is an alphabet it will add $ in front of it
	###Or else it will remain the same
	foreach $n(@tokens){
		if($n =~ /^[a-zA-Z]+[^\s*][0-9]*$/){
			print "\$$n";
		} elsif($n =~ /(#.*)/){
			;
		} elsif($n =~ /[\/\/]/){
			#print "2";
			print "/";
		} elsif($n =~ /[\+\*\/%-]/){
			#print "3";
			print "$n";
		} elsif($n =~ /[0-9]+/){
			#print "4";
			print "$n";
		} else{
			
			my @w_space=split //,$n;
			foreach $i(@w_space){
				if($i =~ m/^[a-zA-Z]+[0-9]*$/){
					print "\$$i";
				}elsif($i =~ m/^[0-9]+$/){
					print "$i";
				} else{
					print " $i";
				}
			}
		}
	}
	
}

###It is the same as assignment initializations
###But it is different with a bracket at the end of it 
sub numeric_comparision{
	my ($numeric)=@_;
	@comp_tokens=split /\s+/,$numeric;
	foreach my $i(@comp_tokens){
		if(grep $_ eq $i,@logical_operators){
			print "$i";
		} elsif($i =~ m/^[a-zA-Z]+[0-9]*$/){
			print "\$$i";
		} elsif($i =~ m/^[0-9]+$/){
			print "$i";
		} else{
			print " $i ";
		}
	}
	###This bracket is a special case for if the conditions in the loop have
	###bracket or not
	if($brack_flag == 0){
		print "){$comment\n";
	}else{
		print "{$comment\n";
	}
}

###This function is for while loop 
###This considers the one line while loop as well as multiline while loop
sub while_loop{
	my ($w_loop)=@_;
	$w_loop =~ /^(\s*)while([\s|\(])(.*)\)?:/;
	print "$1while(";
	if($2 eq "("){
		$brack_flag=1;
	}
	numeric_comparision($3);
	###The following statements are for one line while loop
	if($w_loop =~ /^\s*while[\s|\(](.*)\)?:.+$/){ 
		$w_loop =~ s/^\s*while[\s+|\)].*\)?://;
		@while_array=split/;/,$w_loop;
		foreach my $w(@while_array){
			print "	";
			if($w =~ /^\s*print.*$/){
				print_statements($w);
			}elsif ($w =~ /^\s*(.*)=(.*)$/){
				print "\$$1= ";
				assignment_commands($2);
				print ";";
			}
		}
		my $brack=pop @loops_indentation;
		print "\n$brack}\n";
	}
	 
	
}

###This functions is for if loop
###It follows the same pattern as while loop with changes considering for if
sub if_loop{
	my ($if_loop)=@_;
	$if_loop =~ /^(\s*)if([\s|\(])(.*)\)?:.*$/;
	print "$1if($comment";
	if($2 eq "("){
		$brack_flag=1;
	}
	numeric_comparision($3);
	if($if_loop =~ /^\s*if[\s|\(](.*)\)?:.+$/){
		$if_loop =~ s/^\s*if[\s+|\)].*\)?://;
		@if_array=split/;/,$if_loop;
		foreach my $i(@if_array){
			print "	";
			if($i =~ /^\s*print.*$/){
				print_statements($i);
			}elsif ($i =~ /^\s*(.*)=(.*)$/){
				print "\$$1= ";
				assignment_commands($2);
				print ";";
			}
		}
		my $brackee=pop @loops_indentation;
		print "\n$brackee}\n";
	}
}

###This function is for comments
###This takes the line as argument and stores the comments in a scalar
sub comments{
	my ($comment_line)=@_;
	if($comment_line =~ m/(#.*)/){
		$comment = $1;
	}
}

###This fucntion is for indentation
###It compares the space between the present statement and the one the before it
###The befoe space is stored in a scalar called space 
sub space{
	my ($spaces_length)=@_;
	$prev_space=length($space);
	$curr_space=length($spaces_length);
	if(length($spaces_length)<length($space)){
		#print "Yerneni";
		$b= ($prev_space-$curr_space)/4;
		while($b>0){
			$final_bracket=pop @loops_indentation;
			print "$final_bracket}\n";
			$b--;
		}	
		
	}
}
	
###This is for "for" loop and especially for the group in the range
###It takes the group and splits them on basis of comma
###And it adds -1 at the end of second argument of the group
sub for_loop{
	my ($for_loop_range)=@_;
	@range=split /,/,$for_loop_range;
	$no_of_argument=scalar @range;
	if($no_of_argument==1){
		print "0 .. ";
	}
	$counter=0;
	$length_of_array= scalar @range;
	foreach my $f(@range){
		$counter++;
		if($f =~ m/^[a-zA-Z]+[0-9]*$/){
			print "\$$f";
		}elsif ($f =~ m/^[0-9]+$/){
			print "$f";
		}else{
			assignment_commands($f);
		}
		if($counter == $length_of_array){
			print "-1){\n";
			
		}else{
			print " .. "
		}	
	}

}


###This fucntion is for array initialization
###If it is empty then it will print just a semi-colon
###If it initialized with some elements it will add on the basis of number or string
sub array_elements{
	my ($array_elements)=@_;
	@a_e = split /,/,$array_elements;
	print "(";
	$array_flag=0;
	foreach $a(@a_e){
		if($array_flag==0){
			if($a =~ m/^"*\s*[a-zA-Z0-9]+\s*"*$/){
				print "$a";
			}
		}else{
			if($a =~ m/^"*\s*[a-zA-Z0-9]+\s*"*$/){
				print ",$a";
			}
		}
		$array_flag=1;
	}
	print ");     #$comment\n";

}
