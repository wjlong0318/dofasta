use Tk;
use Tk::Table;
use Tk::LabFrame;
use Tk::Label;
use File::Basename;
use subs qw/menubar_etal/;
use strict;

my $mw = MainWindow->new;
$mw->geometry("850x420");
$mw->resizable(0,0);
$mw->title("dofasta v1.0");


##############start menu#############
$mw->configure(-menu => my $menubar = $mw->Menu);
my $file = $menubar->cascade(-label => 'File');
my $help = $menubar->cascade(-label => 'Help');

$file->command(-label => 'Open sequences',
               -accelerator => 'Ctrl-o',
               -underline => 0,
               -command => \&open_seq
               );
$file->command(-label => 'new patern',
               -accelerator => 'Ctrl-n',
               -underline => 0,
               -command => \&new_pat
               );
$file->separator;
$file->command(-label => "Quit",
               -accelerator => 'Ctrl-q',
               -underline => 0,
               -command => \&exit,);

$help->command(-label => "About",
               -underline => 0, 
               -command => 
               sub{$mw->messageBox(
               	-message => "\nNAME:dofasta\n\nVERSION:V1.0\n\nAUTHOR:wjlong0318\@163.com\n",
                -type => "ok")});
#$help->command(-label => "help doc",
#               -underline => 0, 
#               -command => \&help_doc);
#
###########end menu####################



my $pattern_frame = $mw->LabFrame(-label => "parttern",-labelside => "acrosstop",)->pack(-side=>"left",-fill=>"both",-expand =>'1');
my $apply_frame = $mw->LabFrame(-label => "apply",-labelside => "acrosstop")->pack(-side=>"right",-fill=>"both",-expand =>'1');

##########start pattern_frame#############
my $button_frame=$pattern_frame->Frame()->pack(-side=>"top",-fill=>"x",-expand =>'1',);
my $pattern_table = $pattern_frame->Table(-columns =>3,
	                                      -rows=>16,
	                                      -fixedrows =>1,                                          
                                          -scrollbars => 'oe',
                                          -relief => 'raised',

                                          );
&read_pattern($pattern_table);  
$pattern_table->pack(-side=>"top");
##########end pattern_frame#############

##########start apply_frame#############
my $select_pattern='>.*\|(?<symbol>\w+)\|';
my $submit_frame=$apply_frame->Frame()->pack(-side=>"top",-fill=>"x",-expand =>'1');
my $submit_entry=$submit_frame->Entry(-text =>"$select_pattern", -width =>20,
                                  -state=>"normal",
                                  -background => 'white',-relief => "groove" )->pack(-padx=>"20",-side=>"left");
$submit_frame->Button(-text =>"test", -command =>\&apply_pattern,)->pack(-padx=>"20",-pady=>"10",-side=>"left");
$submit_frame->Button(-text => "save", -command =>\&save_fasta,)->pack(-side=>"left");

my $apply_table = $apply_frame->Table(-columns =>3,
	                                      -rows=>16,
	                                      -fixedrows =>1,                                          
                                          -scrollbars => 'oe',
                                          -relief => 'raised',

                                          );
my $index_label = $apply_table->Label(-text =>"index", -width =>18,-pady=>"6",
                                  -background => 'white',-relief => "groove" );
$apply_table->put(0,0, $index_label);
my $symbol_label = $apply_table->Label(-text =>"symbol", -width =>18,-pady=>"6",
                                  -background => 'white',-relief => "groove" );
$apply_table->put(0,1, $symbol_label);  
my $line_label = $apply_table->Label(-text =>"line", -width =>18,-pady=>"6",
                                  -background => 'white',-relief => "groove" );
$apply_table->put(0,2, $line_label); 
foreach my $num (0..19){            
    $num++;
    my $num_label = $apply_table->Label(-text =>"$num", -width =>18,-pady=>"4",
                                  -background => 'white',-relief => "groove" );
    $apply_table->put($num,0, $num_label);  
}   
$apply_table->pack(-side=>"top");

##########end apply_frame#############




sub help_doc {
#open help pdf
    
}

sub read_pattern{
	#read pattern from pattern.csv
	my $table= shift @_;
	my $i=-1;	
	open(IN,"data/pattern.csv");
    while(my $line=<IN>){
        $i++;
        my $j=0;
        my $index;
        if($i eq 0){$index="index";}else{$index=$i;}        
        my $index_button = $table->Button(-text =>"$index",
                                         -width =>18,-pady=>"4",                                   
                                         -background => 'white',
                                         -relief => "groove",
                                         -command =>[\&get_pat,$i]);
        
        $table->put($i,$j, $index_button);          
        my @cells=split(/,/,$line);
        for my $cell (@cells){
        	$j++;
        	#print "$i:$j:$cell\n";       	
            my $tmp_label = $table->Entry(-text =>"$cell", -width =>18,
                                  -state=>"readonly",
                                  -readonlybackground => 'white',-relief => "groove" );
            $table->put($i, $j, $tmp_label);	
        }
    }
}

sub get_pat{
	#read pattern from pattern tabel ,write apply entry	
	my $index= shift @_;
	#print "$index:get_pat...\n";
	my $fasta_type=$pattern_table->get($index,1)->get();
	my $mypattern=$pattern_table->get($index,2)->get();
	$submit_entry->delete(0, "end");
	$submit_entry->insert(0,"$mypattern\n");
	
}
my $filename="";#globe flenname
sub open_seq{
	#read seq file (only fasta)
    my $types = [
    ['fasta Files',        '',        '.fasta'],
    ['Text Files',       ['.txt', '.text']],     
    ['All Files',        '*',             ],
    ];

	  $filename = $mw->getOpenFile(-filetypes=>$types,-initialdir =>".");
    my $pattern='>.*\|(?<symbol>\w+)\|';
	&read_seq($pattern);
	
}
sub apply_pattern{
	#
    my $pattern = $submit_entry->get();
    $pattern=~s/\s//g;;
    my $rows = $apply_table->totalRows-1;
    for my $index (1..$rows){
        my $line = $apply_table->get($index,2)->get();
        my $symbol_entry=$apply_table->get($index,1);
        $symbol_entry->delete(0, "end");
        if($line=~m/>/){
            if ($line=~m/$pattern/){            
                my $get_symbol=$+{symbol};
                $symbol_entry->insert(0,"$get_symbol");
            }else{
				$symbol_entry->insert(0,"$line");
			}
        }
    }
}

sub read_seq{
	#read_seq
    my $num=0;
    my $check_line;
    my $pattern= shift @_;
    #print "$pattern\n";
    open(IN,"$filename") || $mw->messageBox(
                -message => "Can't open myfile: $!",
                -type => "ok");
    while(my $line=<IN>){
      if (($line=~m/$pattern/) && $num <20){            
          $num++;
          my $get_symbol=$+{symbol}; 
          my $symbol_entry = $apply_table->Entry(-text =>"$get_symbol", -width =>18,
                                  -background => 'white',-relief => "groove" );
          $apply_table->put($num,1, $symbol_entry);
          my $line_entry = $apply_table->Entry(-text =>"$line", -width =>30,-state=>"readonly",
                                  -readonlybackground => 'white',-relief => "groove" );
          $apply_table->put($num,2, $line_entry);
      }            
    }
    close IN;
}
sub new_pat{
    my $newpat_win = $mw->Toplevel;
    $newpat_win->geometry("250x100");
    $newpat_win->resizable(0,0);
    $newpat_win->title("New Pattern");
    my $name_frame = $newpat_win->Frame()->pack(-side=>"top",-fill=>"both",-expand =>'1');
    my $newpat_frame = $newpat_win->Frame()->pack(-side=>"top",-fill=>"both",-expand =>'1');

    $name_frame->Label(-text =>"name:",-pady=>"4",)->pack(-side=>"left",-padx=>"24");
    my $name_entry=$name_frame->Entry(-text =>"", -width =>20,
                                  -state=>"normal",
                                  -background => 'white',-relief => "groove" )->pack(-side=>"left");

    $newpat_frame->Label(-text =>"pattren:",-pady=>"4",)->pack(-side=>"left",-padx=>"20");
    my $pattern_entry=$newpat_frame->Entry(-text =>"", -width =>20,
                                  -state=>"normal",
                                  -background => 'white',-relief => "groove" )->pack(-side=>"left");

    $newpat_win->Button(-text => "Ok", -command => [\&write_newpat,$newpat_win,$name_entry,$pattern_entry],-pady=>"4",)->pack(-side=>"bottom",);
      
    
	}
sub write_newpat{
	my ($newpat_win,$name_entry,$pattern_entry)=@_;
	my $name=$name_entry->get();
    my $pattern=$pattern_entry->get();
      $name=~s/\s//g;
      $pattern=~s/\s//g;
    open(IN,">>data/pattern.csv");
    print IN "$name,$pattern\n";
    close IN;
    &read_pattern($pattern_table);  
	$newpat_win->destroy();
	}

sub save_fasta{
	my $types = [
     ['Fasta Files',  '.fasta'],
     ['All Files',    '*',],
 ];
 
 my $save_filename = $apply_frame->getSaveFile(-filetypes=>$types,-defaultextension=>"fasta");
 my $pattern= $submit_entry->get();
 $pattern=~s/\s//g;
 &write_fasta($save_filename,$pattern);
}  
sub write_fasta{
	my ($save_filename,$pattern)=@_;
	#print "$filename:$pattern\n";
	open (SOURCE,"$filename") or  $mw->messageBox(
                -message => "Can't open source file: $!",
                -type => "ok");
    open (RESULT,">$save_filename") or  $mw->messageBox(
                -message => "Can't open result file: $!",
                -type => "ok");
    while(my $line=<SOURCE>){
	     chomp($line);
        if ($line=~m/$pattern/){            
            my $get_symbol=$+{symbol};            
            print RESULT ">$get_symbol\n";
            #print  ">$get_symbol\n";
	    }else{            
            print RESULT "$line\n";
           #print  "$line\n";
        }
    }
}
MainLoop;
