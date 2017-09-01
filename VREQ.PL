#!/usr/local/bin/perl
#-------------------------------------------------------------------------------------------------
#   NAME        VReq - Perl Command Line interface to the Vantive system
#   VERSION     1.0
#   WRITEN BY   Robert Bondaruk, Vantive Consulting
#   DATE        08/16/1999
#       This script provides a simple command line interface to the Vantive system.  It provides
#       basic functionality to manage task within Vantive.  It does not replace all of the
#       functionality of the Vantive client.
#
#       This script requires the Vantive Perl API to run.  It also uses the POSIX Perl module and
#       Filehandle Perl module.
#       The HELP() subroutine describes the functions and syntax of the commands for this script.
#-------------------------------------------------------------------------------------------------

use Vanperl;
use POSIX;
use FileHandle;


#-------------------------------------------------------------------------------------------------
# COMMENT format and header used to show a Note record from Vantive.
#-------------------------------------------------------------------------------------------------
format COMMENT_TOP =

.

format COMMENT =
Id:          @<<<<<<<<<<<<<<
$noteid
Subject:     @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$notesubject
Visible:     @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$visible
Created By:  @<<<<<<<<<<<<<<<<<<<
$createdby
DateCreated: @<<<<<<<<<<<<<<<<<<<
$datecreated
Note:
@*
$note

.


#-------------------------------------------------------------------------------------------------
# CUSTOMER format and header used to show a Customer record from Vantive.
#-------------------------------------------------------------------------------------------------
format CUSTOMER_TOP =

.

format CUSTOMER =
Customer:        @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$company
Phone:           @<<<<<<<<<<<<<<<<<<<
$phone
Company Type:    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$ctype
Company Status:  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$cstatus
Contacts:
.


#-------------------------------------------------------------------------------------------------
# QUERY_COMMENT format and header used to show a list of Comment records related to a Task from
# Vantive.
#-------------------------------------------------------------------------------------------------
format QUERY_COMMENT_TOP =

Id              Visibility Created By           Date Created         Subject
---------------------------------------------------------------------------------------------------------------
.

format QUERY_COMMENT =
@<<<<<<<<<<<<<< @<<<<<<<<< @<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$noteid,$visible,$createdby,$datecreated,$notesubject
.


#-------------------------------------------------------------------------------------------------
# QUERY_CONTACT format and header used to show a list of Contact records related to a Customer
# from Vantive.
#-------------------------------------------------------------------------------------------------
format QUERY_CONTACT_TOP =

ID              Initial,Lastname  Phone                Alt-Phone  Email
---------------------------------------------------------------------------------------------------------------
.

format QUERY_CONTACT =
@<<<<<<<<<<<<<< @,@<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<< @<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$contactid,$cfirstname,$clastname,$ophone,$aphone,$email
.


#-------------------------------------------------------------------------------------------------
# QUERY_CUSTOMER format and header used to show a list of Customer records from Vantive.
#-------------------------------------------------------------------------------------------------
format QUERY_CUSTOMER_TOP =

Id              Company                                                                Customer Phone
---------------------------------------------------------------------------------------------------------------
.

format QUERY_CUSTOMER =
@<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<
$custid,$company,$phone
.


#-------------------------------------------------------------------------------------------------
# QUERY_TASK format and header used to show a list of Task records from Vantive.
#-------------------------------------------------------------------------------------------------
format QUERY_TASK_TOP =

Id              Prio  T Group Assigned    Hrs   Stat Customer         Subject
---------------------------------------------------------------------------------------------------------------
.

format QUERY_TASK =
@<<<<<<<<<<<<<<  @<<  @  @<<< @<<<<<<<<<  @<<<<  @<  @<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$todoid,$priority,$tasktype,$group,$assignedto,$hours,$status,$customername,$subject
.


#-------------------------------------------------------------------------------------------------
# QUERY_USERS format and header used to show a list of Employee records from Vantive.
#-------------------------------------------------------------------------------------------------
format QUERY_USERS_TOP =

ID              Login                Firstname                             Lastname
---------------------------------------------------------------------------------------------------------------
.

format QUERY_USERS =
@<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$personid,$login,$vfirstname,$vlastname
.


#-------------------------------------------------------------------------------------------------
# TASK format and header used to show a Task record from Vantive.
#-------------------------------------------------------------------------------------------------
format TASK_TOP =

.

format TASK =
Id:          @<<<<<<<<<<<<<<
$todoid
Priority:    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$priority
Task Type:   @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$tasktype
Group:       @<<<<<<<<<
$group
AssignedTo:  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$assignedto
StartDate    @<<<<<<<<<<<<<<<<<<<
$startdate
Status:      @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$status
Customer:    @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$customername
Contact:     @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$tlastname
Subject:
@*
$subject

Description:
@*
$desc

Notes:
.


#-------------------------------------------------------------------------------------------------
# ADD_TASK_QUAL Subroutine
#
# This subroutine adds qualifiers to the form represented by the $From handle.  Qualifiers are
# where clauses applied at the form level to the data returned by Vantive.  This routine should
# only be used with the the Task object.  If a detail is given on the command line for a specific
# Task then this routine sets the where clause to return only the rows by the detail.  If no
# detail is given on the command line then the other command options are parsed to set the where
# clause to return a list of records as described by the options.
#-------------------------------------------------------------------------------------------------
sub ADD_TASK_QUAL
{

if ($Detail ne "")
	{

	$Rtn = VanAddQualifier($Form,"SWTODOID","=",$Detail,);
	if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUALaddqualifier:swtodoid",$Rtn);}	

	}
elsif (($Owner ne "") || ($Status ne "") || ($Priority ne "" || $Type ne "" || $Group ne ""))
	{

	if ($Owner ne "")
		{

		$Owner = $Owner . "%";
		$Rtn = VanAddQualifier($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN","like",$Owner,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUAL:addqualifier:swassignedtoid|sw_employee_vw.swlogin",$Rtn);}

		}

	if ($Status ne "")
		{

		$Status = $Status . "%";
		$Rtn = VanAddQualifier($Form,"SWSTATUS","like",$Status,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUAL:addqualifier:swstatus",$Rtn);}

		}

	if ($Priority ne "")
		{

		$Priority = $Priority . "%";
		$Rtn = VanAddQualifier($Form,"SWPRIORITY","like",$Priority,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUAL:addqualifier:swpriority",$Rtn);}

		}

	if ($Type ne "")
		{

		$Type = $Type . "%";
		$Rtn = VanAddQualifier($Form,"DITYPE","like",$Type,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUAL:addqualifier:dttype",$Rtn);}

		}

	if ($Group ne "")
		{

		$Group = $Group . "%";
		$Rtn = VanAddQualifier($Form,"DIDEPARTMENT","like",$Group,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn,"ADD_TASK_QUAL:addqualifier:didepartment",$Rtn);}

		}

	}
else
	{

		$Rtn = VanAddQualifier($Form,"SWSTATUS","=","Open",);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn, "ADD_TASK_QUAL:addqualifier:swstatus", $Rtn);}
		$Rtn = VanAddQualifier($Form,"DIDEPARTMENT","=",$UsersGroup,);
		if ($Rtn < VAN_NOERROR && $Rtn != VAN_EFIELD) {REPORTERROR($Conn, "ADD_TASK_QUAL:addqualifier:didepartment", $Rtn);}

	}

}


#-------------------------------------------------------------------------------------------------
# ARGS Subroutine
#
# This subroutine extracts the arguments specified on the command line and places the values for
# the arguments in the appropriate variable.
#-------------------------------------------------------------------------------------------------
sub ARGS
{

## VARIABLES USED BY THE SUBROUTINE
my @bArgs = @_;

foreach $i (@bArgs )

	{

	if ($i =~ /^owner:.+$/i)
		{

		$i =~ s/owner://i;
		if ($i ne "") {$Owner = $i;}

		}

	elsif ($i =~ /^status:.+$/i) 
		{

		$i =~ s/status://i;
		if ($i ne "") {$Status = $i;}

		}

	elsif ($i =~ /^detail:.+$/i)
		{

		$i =~ s/detail://i;
		if ($i =~ /(\d{1,15})(\.?)(\d{0,5})/) {$Detail = $i;}
		else {$Detail = "";}

		}

	elsif ($i =~ /^priority:.+$/i)
		{

		$i =~ s/priority://i;
		if ($i ne "") {$Priority = $i;}

		}

	elsif ($i =~ /^comment:.+$/i)
		{

		$i =~ s/comment://i;
		if ($i =~ /(\d{1,15})(\.?)(\d{0,5})/) {$Comment = $i;}
		else {$Comment = "";}

		}

	elsif ($i =~ /^sub:.+$/i)
		{

		$i =~ s/sub://i;
		if ($i ne "") {$Sub = $i;}

		}

	elsif ($i =~ /^note:.+$/i)
		{

		$i =~ s/note://i;
		if ($i ne "") {$Note = $i;}

		}

	elsif ($i =~ /^file:.+$/i)
		{

		$i =~ s/file://i;
		if ($i ne "") {$File = $i;}

		}

	elsif ($i =~ /^type:.+$/i)
		{

		$i =~ s/type://i;
		if ($i ne "") {$Type = $i;}

		}

	elsif ($i =~ /^customer:.+$/i)
		{

		$i =~ s/customer://i;
		if ($i =~ /(\d{1,15})(\.?)(\d{0,5})/) {$Customer = $i;}
		else {$Customer = "";}


		}

	elsif ($i =~ /^company:.+$/i)
		{

		$i =~ s/company://i;
		if ($i ne "") {$Company = $i;}

		}

	elsif ($i =~ /^users:.+$/i)
		{

		$i =~ s/users://i;
		if ($i ne "") {$User = $i;}

		}

	elsif ($i =~ /^group:.+$/i)
		{

		$i =~ s/group://i;
		if ($i ne "") {$Group = $i;}

		}

	elsif ($i =~ /^person:.+$/i)
		{

		$i =~ s/person://i;
		if ($i ne "") {$Person = $i;}
		if ($i =~ /(\d{1,15})(\.?)(\d{0,5})/) {$Person = $i;}
		else {$Person = "";}


		}

	}

}


#-------------------------------------------------------------------------------------------------
# CLOSEVANTIVE Subroutine
#
# This is a routine to close the Vantive connection gracefully when an error happens.  It is used
# in place of the die command when a file is opened.  If the file cannot be open this routine is
# called.
#-------------------------------------------------------------------------------------------------

sub CLOSEVANTIVE
{

my $status = $_[0];

print $status;
if (($Rtn = VanCloseConnection($Conn,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,'CLOSEVANTIVE:closeconnection',$Rtn);}
exit(1);

}


#-------------------------------------------------------------------------------------------------
# COMMENT Subroutine
#
# This subroutine is called when the user executes a comment command in the vreq shell.  If Task
# and Comment details are specified as options on the command line then the routine shows the
# specified Note record.  If a Task and Subject details are specified then the routine adds a
# new Note to related to the specified Task detail.  When adding a new Note, the user can also add
# a note in addition to the subject of up to 4000 characters of text.  The note can be added from
# a file as well.
#-------------------------------------------------------------------------------------------------
sub COMMENT
{

my $create_subform = "";

if (($Comment ne "") && ($Detail ne ""))
	{
	$Cursorwhere2 = "SWWORKLOGID = $Comment";

	$Form = VanCreateMainForm($Conn,"TO_DO");
	if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:createmain:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:createmain:to_do", $Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:opencursor", $Cursor);}

	if (($Fetch = VanFetchRecord($Form)) == VAN_NOERROR) 
		{

		$numchild = VanNumChilds($Form);
		for ($r = 1; $r <= $numchild; $r++)
			{

			$Rtn = VanChildDesc($Form,$r,VAN_CNAME,$subform,30);
			if ($subform eq "diWorkLogPu") {$create_subform = "yes";}

			}
		if ($create_subform eq "yes")
			{

			if (($Form2 = VanCreateChildDetailForm($Form,"diWorkLogPu")) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:createchilddetail:diWorkLogPu", $Form2);}
			if (($Cursor2 = VanOpenCursor($Form2,$Cursorwhere2,$Cursororder2)) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:opencursor", $Cursor2);}
			$- = 0;
			while (($Fetch = VanFetchRecord($Form2)) == VAN_NOERROR) 
				{

				$Field = VanGetField($Form2,"SWWORKLOGID",$noteid,20);
				if ($Field == VAN_EFIELD) {$noteid = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swworklogid", $Field);}

				$Field = VanGetField($Form2,"SWVISIBILITY",$visible,30);
				if ($Field == VAN_EFIELD) {$visible = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swvisibility", $Field);}

				$Field = VanGetField($Form2,"SWSUBJECT",$notesubject,70);
				if ($Field == VAN_EFIELD) {$notesubject = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swsubject", $Field);}

				$Field = VanGetField($Form2,"SWCREATEDBY",$createdby,20);
				if ($Field == VAN_EFIELD) {$createdby = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swcreatedby", $Field);}

				$Field = VanGetField($Form2,"SWDATECREATED",$datecreated,20);
				if ($Field == VAN_EFIELD) {$datecreated = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swdatecreated", $Field);}

				$Field = VanGetField($Form2,"SWNOTE",$note,10000);
				if ($Field == VAN_EFIELD) {$note = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:getfield:swnote", $Field);}

				format_name STDOUT "COMMENT";
				format_top_name STDOUT "COMMENT_TOP";
				write STDOUT;

				}

			if ($Fetch == VAN_WNODATA)
				{

				if (($Rtn = VanCloseCursor($Form2)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closecursor",$Rtn);}
				if (($Rtn = VanCloseForm($Form2,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closeform",$Rtn);}

				}
			elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "COMMENT:fetchrecord", $Fetch);}

			}

		else {print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:createchilddetail:diWorkLogPu\n\n";last;}

		}

	if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closecursor",$Rtn);}
	if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closeform",$Rtn);}

	}

elsif (($Sub ne "") && ($Detail ne ""))
	{

	$Form = VanCreateMainForm($Conn,"TO_DO");
	if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:createmain:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:createmain:to_do", $Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:opencursor", $Cursor);}

	$Fetch = VanFetchRecord($Form);
	if ($Fetch == VAN_NOERROR) 
		{

		$numchild = VanNumChilds($Form);
		for ($r = 1; $r <= $numchild; $r++)
			{

			$Rtn = VanChildDesc($Form,$r,VAN_CNAME,$subform,30);
			if ($subform eq "diWorkLogPu") {$create_subform = "yes";}

			}
		if ($create_subform eq "yes")
			{

			if (($Form2 = VanCreateChildDetailForm($Form,"diWorkLogPu")) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:createchilddetail:diWorkLogPu", $Form2);}
			if (($Rtn = VanNewRecord($Form2)) < VAN_NOERROR) {REPORTERROR($Conn, "COMMENT:newrecord", $Rtn);}
			if ($Note ne "")
				{

				$Set = VanSetField($Form2,"SWSUBJECT",$Sub,$Errcode,$Errpath);
				if ($Set == VAN_EPERM)
					{

					$Rtn = VanUndoChanges($Form2,1);
					print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:setfield:swsubject\n\n";

					}

				elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swsubject",$Rtn);}

				$Set = VanSetField($Form2,"SWNOTE",$Note,$Errcode,$Errpath);
				if ($Set == VAN_EPERM)
					{

					$Rtn = VanUndoChanges($Form2,1);
					print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:setfield:swnote\n\n";

					}

				elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swnote",$Rtn);}

				if ($Set == VAN_NOERROR)

					{

					if (($Rtn = VanSaveRecord($Form2,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swnote",$Rtn);}
					print "\n\nNew Record Saved\n\n";

					}

				}
			elsif ($File ne "")
				{

				open(TEXT,$File) || CLOSEVANTIVE("Could not open file.");
				while(($line = <TEXT>) && ($len < 4000))
					{

					chomp($line);
					$Note = $Note . $line;
					$len = length($Note);

					}

				if ($len > 4000)
					{

					print "\n\nMaximum field length of 4000 character exceeded by file.\n";
					print "Would you like to add the first 4000 characters as a Note? (Y/N)\n\n";
					chomp($keepfile = <STDIN>);
					if ($keepfile =~ /y/i)
						{

						$Note = substr($Note,0,4000);

						$Set = VanSetField($Form2,"SWSUBJECT",$Sub,$Errcode,$Errpath);
						if ($Set == VAN_EPERM)
							{

							$Rtn = VanUndoChanges($Form2,1);
							print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:setfield:swsubject\n\n";

							}

						elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swsubject",$Rtn);}

						$Set = VanSetField($Form2,"SWNOTE",$Note,$Errcode,$Errpath);
						if ($set == VAN_EPERM)
							{

							$Rtn = VanUndoChanges($Form2,1);
							print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:setfield:swnote\n\n";

							}

						elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swnote",$Rtn);}

						if ($Set == VAN_NOERROR)
							{

							if (($Rtn = VanSaveRecord($Form2,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:saverecord",$Rtn);}
							print "\n\nComment Added\n\n";

							}

						}

					}

				}
			else
				{

				$Set = VanSetField($Form2,"SWSUBJECT",$Sub,$Errcode,$Errpath);
				if ($Set == VAN_EPERM)
					{

					$Rtn = VanUndoChanges($Form2,1);
					print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:setfield:swsubject\n\n";

					}

				if ($Set < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:setfield:swsubject",$Rtn);}

				if ($Set == VAN_NOERROR)
					{

					if (($Rtn = VanSaveRecord($Form2,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:saverecord",$Rtn);}
					print "\n\nNew Record Saved\n\n";

					}

				}

			if (($Rtn = VanCloseForm($Form2,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closeform",$Rtn);}

			}

		else {print "\n\nYou do not have the necessary permissions to execute this command!\nCOMMENT:createchilddetail:diWorkLogPu\n\n";}

		}

	else {print "\nThe record could not be created.  Check the values used on the command line.\n\n";}

	if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closecursor",$Rtn);}
	if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"COMMENT:closeform",$Rtn);}

	}

else {HELP("comment");}

}


#-------------------------------------------------------------------------------------------------
# CUSTOMER Subroutine
#
# This subroutine is called when the user executes a customer command in the vreq shell.  If a 
# Customer detail is specified as an option on the command line then the routine shows the
# specified Customer record.  If no detail is specified then the routine shows a list of all
# Customer records in Vantive.
#-------------------------------------------------------------------------------------------------
sub CUSTOMER
{

## VARIABLES USED BY THE SUBROUTINE
my $cuReccnt = 0;
my $cuSpoolcnt = 0;
my $cuSpooltest = "";

$Cursororder = "SWNAME";
if ($Customer eq "")
	{

	$Form = VanCreateListForm($Conn,"CUSTOMER","",0);
	if ($Form == VAN_EFORM) {print "\n\nYou do not have the necessary permissions to execute this command!\nCUSTOMER:createmain:customer\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:createmain:customer", $Form);}
	if ($Company ne "") {$Cursorwhere = "SWNAME LIKE '$Company%'";}
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:opencursor", $Cursor);}
	$cuReccnt = VanSearchCount($Form);
	$Fetch = VanFetchRecord($Form);
	$- = 0;
	while ($Fetch == VAN_NOERROR) 
		{

		$cuSpoolcnt++;

		$Field = VanGetField($Form,"SWCUSTOMERID",$custid,20);
		if ($Field == VAN_EFIELD) {$custid = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swcustomerid", $Field);}

		$Field = VanGetField($Form,"SWNAME",$company,70);
		if ($Field == VAN_EFIELD) {$company = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swname", $Field);}

		$Field = VanGetField($Form,"SWMAINPHONEAREA",$phonearea,10);
		if ($Field == VAN_EFIELD) {$phonearea = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swmainphonearea", $Field);}

		$Field = VanGetField($Form,"SWMAINPHONE",$phone,10);
		if ($Field == VAN_EFIELD) {$phone = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swmainphone", $Field);}

		if ($phone eq "") {$phonearea = "";}
		if ($phonearea ne "") {$phone = $phonearea . "-" . $phone;}

		format_name STDOUT "QUERY_CUSTOMER";
		format_top_name STDOUT "QUERY_CUSTOMER_TOP";
		write STDOUT;

		if (($cuSpoolcnt % 20) == 0)
			{

			print "\n\n$cuSpoolcnt of $cuReccnt records of the query are shown. Press enter to continue the query or s to stop the query.\n\n";
			$cuSpooltest = <STDIN>;
			chomp($cuSpooltest);
			if ($cuSpooltest =~ /^s$/i){$Fetch = VAN_WNODATA;}
			else {$Fetch = VanFetchRecord($Form);}

			}

		else {$Fetch = VanFetchRecord($Form)}

		}

	if ($Fetch == VAN_WNODATA)
		{

		if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closecursor",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closeform",$Rtn);}
		if (!($cuSpooltest =~ /^s$/i)) {print "\nThere were $cuReccnt records in the query.\n\n";}

		}

	elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "CUSTOMER:fetchrecord", $Fetch);}
		
	}

else
	{

	$Form = VanCreateMainForm($Conn,"CUSTOMER");
	if (($Form == VAN_EFORM) || ($Form == VAN_EPERM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nCUSTOMER:createmain:customer\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:createmain:customer", $Form);}
	$Cursorwhere = "SWCUSTOMERID = '$Customer'";
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:opencursor", $Cursor);}
	$- = 0;
	if (($Fetch = VanFetchRecord($Form)) == VAN_NOERROR) 
		{

		$Field = VanGetField($Form,"SWCUSTOMERID",$custid,20);
		if ($Field == VAN_EFIELD) {$custid = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swcustomerid", $Field);}

		$Field = VanGetField($Form,"SWNAME",$company,70);
		if ($Field == VAN_EFIELD) {$company = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swname", $Field);}

		$Field = VanGetField($Form,"SWMAINPHONECNTRY",$phonecountry,10);
		if ($Field == VAN_EFIELD) {$phonecountry = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swmainphonecntry", $Field);}

		$Field = VanGetField($Form,"SWMAINPHONEAREA",$phonearea,10);
		if ($Field == VAN_EFIELD) {$phonearea = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swmainphonearea", $Field);}

		$Field = VanGetField($Form,"SWMAINPHONE",$phone,10);
		if ($Field == VAN_EFIELD) {$phone = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swmainphone", $Field);}

		$Field = VanGetField($Form,"SWTYPE",$ctype,30);
		if ($Field == VAN_EFIELD) {$ctype = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swtype", $Field);}

		$Field = VanGetField($Form,"SWSTATUS",$cstatus,30);
		if ($Field == VAN_EFIELD) {$cstatus = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swstatus", $Field);}

		if ($phone eq "") {$phonecountry = "";$phonearea = "";}
		if ($phonearea ne "")
			{

			$phone = $phonearea . "-" . $phone;
			if ($phonecountry ne "") {$phone = $phonecountry . "-" . $phone;}

			}

		format_name STDOUT "CUSTOMER";
		format_top_name STDOUT "CUSTOMER_TOP";
		write STDOUT;

		$numchild = VanNumChilds($Form);
		for ($r = 1; $r <= $numchild; $r++)
			{

			$Rtn = VanChildDesc($Form,$r,VAN_CNAME,$subform,30);
			if ($subform eq "diContactSummaryScr") {$create_subform = "yes";}

			}
		if ($create_subform eq "yes")
			{

			if (($Form2 = VanCreateSummaryForm($Form,"diContactSummaryScr")) < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:createsummary:diContactSummaryScr", $Form2);}
			if (($Cursor2 = VanOpenCursor($Form2,$Cursorwhere2,$Cursororder2)) < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:opencursor", $Cursor2);}
			$- = 0;
			while (($Fetch = VanFetchRecord($Form2)) == VAN_NOERROR) 
				{

				$Field = VanGetField($Form2,"SWPERSONID",$contactid,20);
				if ($Field == VAN_EFIELD) {$contactid = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swpersonid", $Field);}

				$Field = VanGetField($Form2,"SWLASTNAME",$clastname,20);
				if ($Field == VAN_EFIELD) {$clastname = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swlastname", $Field);}

				$Field = VanGetField($Form2,"SWFIRSTNAME",$cfirstname,30);
				if ($Field == VAN_EFIELD) {$cfirstname = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swfirstname", $Field);}

				$Field = VanGetField($Form2,"SWOFFICEPHONECNTRY",$ophonecountry,70);
				if ($Field == VAN_EFIELD) {$ophonecountry = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swofficephonecntry", $Field);}

				$Field = VanGetField($Form2,"SWOFFICEPHONEAREA",$ophonearea,20);
				if ($Field == VAN_EFIELD) {$ophonearea = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swofficephonearea", $Field);}

				$Field = VanGetField($Form2,"SWOFFICEPHONE",$ophone,20);
				if ($Field == VAN_EFIELD) {$ophone = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swofficephone", $Field);}

				$Field = VanGetField($Form2,"SWOFFICEPHONEEXT",$ophoneext,20);
				if ($Field == VAN_EFIELD) {$ophoneext = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swofficephoneext", $Field);}

				$Field = VanGetField($Form2,"SWALTPHONE",$aphone,30);
				if ($Field == VAN_EFIELD) {$aphone = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swaltphone", $Field);}

				$Field = VanGetField($Form2,"SWEMAILADDRESS",$email,70);
				if ($Field == VAN_EFIELD) {$email = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "CUSTOMER:getfield:swemailaddress", $Field);}

				if ($ophone eq "") {$ophonecountry = "";$ophonearea = "";$ophoneext = "";}
				if ($ophoneext ne "") {$ophone = $ophone . "Ext " . $ophoneext;}
				if ($ophonearea ne "")
					{

					$ophone = $ophonearea . "-" . $ophone;
					if ($ophonecountry ne "") {$ophone = $ophonecountry . "-" . $ophone;}

					}


				format_name STDOUT "QUERY_CONTACT";
				format_top_name STDOUT "QUERY_CONTACT_TOP";
				write STDOUT;

				}

			if ($Fetch == VAN_WNODATA)
				{

				if (($Rtn = VanCloseCursor($Form2)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closecursor",$Rtn);}
				if (($Rtn = VanCloseForm($Form2,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closeform",$Rtn);}

				}
			elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "CUSTOMER:fetchrecord", $Fetch);}

			}

		else {print "\nYou do not have the necessary permissions to view the contacts related to a customer record!\nCUSTOMER:createsummary:diContactSummaryScr\n\n";}

		if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closecursor",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"CUSTOMER:closeform",$Rtn);}

		}

	elsif ($Fetch == VAN_WNODATA)
		{

		print "\nThere is no Customer for the CustomerId that you entered.\n\n";

		}
	elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Fetch, "CUSTOMER:fetchrecord", $Form);}

	}

}


#-------------------------------------------------------------------------------------------------
# GETGROUP Subroutine
#
#-------------------------------------------------------------------------------------------------
sub GETGROUP
{

$Form = VanCreateMainForm($Conn,"EMPLOYEE");
if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {CLOSEVANTIVE("\n\nYou do not have the necessary permissions to use Vantive from the command line!\nGETGROUP:createmain:employee\n\n");}
elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn,"GETGROUP:createmain:employee",$Form);}
$Cursorwhere = "SWLOGIN = '$Username'";
if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn,"GETGROUP:opencursor",$Cursor);}
if (($Fetch = VanFetchRecordForUpdate($Form)) == VAN_NOERROR)
	{

	$Field = VanGetField($Form,"SWDEPARTMENT",$UsersGroup,40);
	if ($Field < VAN_NOERROR) {REPORTERROR($Conn, "GETGROUP:getfield:swdepartment", $Field);}
	if ($UsersGroup eq "") {CLOSEVANTIVE("\n\nYou do not have the necessary permissions to use Vantive from the command line!\nGETGROUP:getfield:swdepartment\n\n");}

	}

if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"GETGROUP:closecursor",$Rtn);}
if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"GETGROUP:closeform",$Rtn);}

}



#-------------------------------------------------------------------------------------------------
# HELP Subroutine
#
# This subroutine produces help output when a user types an inappropriate command.
#-------------------------------------------------------------------------------------------------
sub HELP
{

## VARIABLES USED BY THE SUBROUTINE
my @hArgs = @_;
if (@hArgs == 0) {@hArgs = ("bye","comment","customer","new","q","take","update","users");}

foreach $j (@hArgs)
	{

	PARSE:
		{

		$j =~ /bye/i and do 
			{

			print "\n------------------------------------------------------------------------------------------\n\nBYE: ";
			print "Log out of Vantive, close the vreq shell, and return to the Unix command line.\n\n";
			print "Syntax: bye\n\n";
			last PARSE;

			};

		$j =~ /comment/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nCOMMENT: ";
			print "Show the text of the specified comment.  Comments can be up to 4000 characters of text.\n\n";
			print "Syntax: comment --detail:<taskid> --comment:<commentid>\n\n";
			print "Add a comment to an existing task, subject is required, note and file are optional.  Don't\n";
			print "use both note and file as options.  If both are used you will only get the note.  Use note\n";
			print "to type text at the command line. Use file to import text from a file.\n\n";
			print "Syntax: comment --detail<taskid> --sub:<subject> --note:<text> --file:<file>\n\n";
			last PARSE;

			};

		$j =~ /customer/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nCUSTOMER: ";
			print "Show a list of all Digital Island Customers.  Company is optional and allows the user to\n";
			print "specify criteria to narrow the list of customers returned.  It works as a like clause.\n\n";
			print "Syntax: customer --company:<company name>\n\n";
			print "Show the details of a specific customer.  Includes a list of contacts for that customer.\n\n";
			print "Syntax: customer --customer:<customerid>\n\n";
			last PARSE;

			};

		$j =~ /new/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nNEW: ";
			print "Create a new Case and Task in Vantive.  The personid can be either a contactid from a\n";
			print "Customer/Contact record or the employeeid from a User record.  Either note or file is\n";
			print "required and they are used in the description of the Task.  Don't use both note and file as\n";
			print "options.  If both are used you will only get the note.  Use note to type text at the command\n";
			print "line.\n";
			print "Syntax: new --sub:<subject> --person:<personid> --note:<text> --file:<file>\n\n";
			last PARSE;

			};

		$j =~ /q/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nQUERY: ";
			print "Queries Vantive for a list of all Open tasks.  Owner,Status, and Type are optional parameters\n";
	            print "that allow the user to specifiy criteria to narrow the list of tasks returned.  The optional\n";
			print "parameters work like where clauses.\n";
			print "Syntax: q --owner:<owner> --status:<status> --type:<case type>\n\n";
			print "Show the details of a specific Task in Vantive.  Includes a list of comments for the task.\n\n";
			print "Syntax: q --detail:<taskid>\n\n";
			last PARSE;
			};

		$j =~ /start/i and do
			{

			print "\nTo start the VReq shell, the following syntax is required:\n\n";
			print "\tSyntax: vreq.pl <username> <password>\n\n";
			print "\t<username>  Vantive Login\n";
			print "\t<password>  Vantive Password\n\n";

			};

		$j =~ /take/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nTAKE: ";
			print "Assign the specified task to the current user.\n\n";
			print "Syntax: take --detail:<taskid>\n\n";
			last PARSE;

			};

		$j =~ /update/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nUPDATE: ";
			print "Updates the owner, status, and/or priority of the specified task.  One of the three is\n";
			print "required, though they call all be set simulateously.\n\n";
			print "Syntax: update --detail:<taskid> --owner:<owner> --status:<status> --priority:<priority>\n\n";
			last PARSE;

			};

		$j =~ /users/i and do
			{

			print "\n------------------------------------------------------------------------------------------\n\nUSERS: ";
			print "Queries Vantive for a list of all Users.  The returned list can be narrowed via the users\n";
			print "option, which works like a where clause on login id.\n\n";
			print "Syntax: users --users:<username>\n\n";
			last PARSE;

			};

		}

	}

}


#-------------------------------------------------------------------------------------------------
# NEW Subroutine
#
# This subroutine is used to add a new case and task.  A new case must be created first.  The
# caseid is then used to to create a new task and relate it to the previously created case.  A new
# case and task require a subject, related person, and description (from a note or file).  The
# related person can either be a contact or and employee and uses the personid of either.
#-------------------------------------------------------------------------------------------------
sub NEW
{

if (($Sub ne "") && ($Person ne "") && ($Note ne "" || $File ne ""))
	{

	$Form = VanCreateMainForm($Conn,"CASE");
	if (($Form == VAN_EFORM) || ($Form == VAN_EPERM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:createmain:case\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "NEW:createmain:case", $Form);}
	if (($Rtn = VanNewRecord($Form)) < VAN_NOERROR) {REPORTERROR($Conn, "NEW:newrecord", $Rtn);}

	$Set = VanSetField($Form,"SWNOTE",$Sub,$Errcode,$Errpath);
	if ($Set == VAN_EPERM)
		{

		$Rtn = VanUndoChanges($Form,1);
		print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swnote\n\n";
		}

	elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swnote",$Rtn);}

	$Set = VanSetField($Form,"SWSTATUS","Open",$Errcode,$Errpath);
	if ($Set == VAN_EPERM)
		{

		$Rtn = VanUndoChanges($Form,1);
		print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swstatus\n\n";

		}

	elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swstatus",$Rtn);}

	$Set = VanSetField($Form,"SWDEPARTMENT",$UsersGroup,$Errcode,$Errpath);
	if ($Set == VAN_EPERM)
		{

		$Rtn = VanUndoChanges($Form,1);
		print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swdepartment\n\n";

		}

	elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swdepartment",$Rtn);}

	$Set = VanSetField($Form,"SWASSIGNEDTO|SW_EMPLOYEE_VW.SWLOGIN",$Username,$Errcode,$Errpath);
	if ($Set == VAN_EPERM)
		{

		$Rtn = VanUndoChanges($Form,1);
		print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swassignedto|sw_employee_vw.swlogin\n\n";
		}

	elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:assignedto|sw_employee_vw.swlogin",$Rtn);}

	$Set = VanSetField($Form,"SWREPORTEDBY",$Person,$Errcode,$Errpath);
	if ($Set == VAN_EPERM)
		{

		$Rtn = VanUndoChanges($Form,1);
		print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swreportedby\n\n";

		}

	elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swreportedby",$Rtn);}

	$Field = VanGetField($Form,"SWCASEID",$caseid,20);
	if ($Field < VAN_NOERROR) {REPORTERROR($Conn, "NEW:getfield:swcaseid", $Field);}

	if (($caseid ne "") && ($Set == VAN_NOERROR))
		{

		if (($Rtn = VanSaveRecord($Form,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"NEW:saverecord",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedfrom)) < VAN_NOERROR) {REPORTERROR($Conn,"NEW:closeform",$Rtn);}

		$Form = VanCreateMainForm($Conn,"TO_DO");
		if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:createmain:to_do\n\n";last;}
		elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "NEW:createmain:to_do", $Form);}
		if (($Rtn = VanNewRecord($Form)) < VAN_NOERROR) {REPORTERROR($Conn, "NEW:newrecord", $Rtn);}

		$Set = VanSetField($Form,"SWCASEID",$caseid,$Errcode,$Errpath);
		if ($Set == VAN_EPERM)
			{

			$Rtn = VanUndoChanges($Form,1);
			print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:caseid\n\n";

			}

		elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swcaseid",$Rtn);}

		$Set = VanSetField($Form,"SWSUBJECT",$Sub,$Errcode,$Errpath);
		if ($Set == VAN_EPERM)
			{

			$Rtn = VanUndoChanges($Form,1);
			print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swsubject\n\n";

			}

		elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swsubject",$Rtn);}

		$Set = VanSetField($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN",$Username,$Errcode,$Errpath);
		if ($Set == VAN_EPERM)
			{

			$Rtn = VanUndoChanges($Form,1);
			print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swassignedtoid|sw_employee_vw.swlogin\n\n";

			}

		elsif($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swassignedtoid|sw_employee_vw.swlogin",$Rtn);}

		if ($Note ne "")
			{

			$Set = VanSetField($Form,"SWDESCRIPTION",$Note,$Errcode,$Errpath);
			if ($Set == VAN_EPERM)
				{

				$Rtn = VanUndoChanges($Form,1);
				print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swdescription\n\n";

				}

			elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swdescription",$Rtn);}

			}

		elsif ($File ne "")
			{

			open(TEXT,$File) || CLOSEVANTIVE("Could not open file.");
			while(($line = <TEXT>) && ($len < 4000))
				{

				chomp($line);
				$Note = $Note . $line;
				$len = length($Note);

				}

			if ($len > 4000)
				{

				print "\n\nMaximum field length of 4000 character exceeded by file.\n";
				print "Would you like to add the first 4000 characters as a Note? (Y/N)\n\n";
				chomp($keepfile = <STDIN>);
				if ($keepfile =~ /y/i)
					{

					$Note = substr($Note,0,4000);

					$Set = VanSetField($Form,"SWDESCRIPTION",$Note,$Errcode,$Errpath);
					if ($Set == VAN_EPERM)
						{

						$Rtn = VanUndoChanges($Form2,1);
						print "\n\nYou do not have the necessary permissions to execute this command!\nNEW:setfield:swdescription\n\n";

						}

					elsif ($Set < VAN_NOERROR) {REPORTERROR($Conn,"NEW:setfield:swdescription",$Rtn);}

					}

				}

			}

		if ($Set == VAN_NOERROR)
			{

			if (($Rtn = VanSaveRecord($Form,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"NEW:saverecord",$Rtn);}
			print "\n\nNew Record Created\n\n";

			}

		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"NEW:closeform",$Rtn);}

		}

	}

else {HELP("New");}

}


#-------------------------------------------------------------------------------------------------
# QUERY Subroutine
#
# This subroutine is called when the user executes a q command in the vreq shell.  If a Detail
# detail is specified as an option then the subroutine shows the specified Task record and all
# comments related to that Task.  If no Detail detail is specified then the subroutine shows a
# list of all Task records based on the where clause set by the ADD_TASK_QUAL subroutine.
#-------------------------------------------------------------------------------------------------
sub QUERY
{

## VARIABLES USED BY THE SUBROUTINE
my $qReccnt = 0;
my $qSpoolcnt = 0;
my $qSpooltest = "";
my $qTimediff = "";

$Cursororder = "SWPRIORITY,SWESTSTARTDATE";
if ($Detail eq "")
	{

	$Form = VanCreateListForm($Conn,"TO_DO","",0);
	if ($Form == VAN_EFORM) {print "\n\nYou do not have the necessary permissions to execute this command!\nQUERY:createlist:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:createlist:to_do", $Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:opencursor", $Cursor);}
	$qReccnt = VanSearchCount($Form);
	$Fetch = VanFetchRecord($Form);
	$- = 0;
	while ($Fetch == VAN_NOERROR) 
		{

		$qSpoolcnt++;

		$Field = VanGetField($Form,"SWTODOID",$todoid,20);
		if ($Field == VAN_EFIELD) {$todoid = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swtodoid", $Field);}

		$Field = VanGetField($Form,"SWPRIORITY",$priority,30);
		if ($Field == VAN_EFIELD) {$priority = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swpriority", $Field);}

		$Field = VanGetField($Form,"DITYPE",$tasktype,30);
		if ($Field == VAN_EFIELD) {$tasktype = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:ditype", $Field);}

		$Field = VanGetField($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN",$assignedto,40);
		if ($Field == VAN_EFIELD) {$assignedto = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swassignedtoid|sw_employee_vw.swlogin", $Field);}

		$Field = VanGetField($Form,"SWESTSTARTDATE",$startdate,20);
		if ($Field == VAN_EFIELD) {$startdate = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:sweststartdate", $Field);}

		$Field = VanGetField($Form,"SWSTATUS",$status,30);
		if ($Field == VAN_EFIELD) {$status = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swstatus", $Field);}

		$Field = VanGetField($Form,"SWSUBJECT",$subject,250);
		if ($Field == VAN_EFIELD) {$subject = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swsubject", $Field);}

		$Field = VanGetField($Form,"SWCUSTOMERID|SW_CUSTOMER.SWNAME",$customername,30);
		if ($Field == VAN_EFIELD) {$customername = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swcustomerid|sw_customer.swname", $Field);}

		$Field = VanGetField($Form,"DIDEPARTMENT",$group,40);
		if ($Field == VAN_EFIELD) {$group = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:didepartment", $Field);}

		$hours = "";
		if ($startdate ne "")
			{

			$qTimediff = mktime(substr($startdate,17,2),substr($startdate,14,2),substr($startdate,11,2),substr($startdate,3,2),(substr($startdate,0,2)-1),(substr($startdate,6,4)-1900));
			$hours = (time() - $qTimediff) / 3600;
			if ($hours >= 100 || $hours <= -100) {$hours =~ s/\..*//}
			else {$hours =~ /.*\.../;}

			}

		format_name STDOUT "QUERY_TASK";
		format_top_name STDOUT "QUERY_TASK_TOP";
		write STDOUT;

		if (($qSpoolcnt % 20) == VAN_NOERROR)
			{

			print "\n\n$qSpoolcnt of $qReccnt records of the query are shown. Press enter to continue the query or s to stop the query.\n\n";
			$qSpooltest = <STDIN>;
			chomp($qSpooltest);
			if ($qSpooltest =~ /^s$/i){$Fetch = VAN_WNODATA;}
			else {$Fetch = VanFetchRecord($Form);}

			}
		else {$Fetch = VanFetchRecord($Form)}

		}

	if ($Fetch == VAN_WNODATA)
		{

		if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closecursor",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closeform",$Rtn);}
		if (!($qSpooltest =~ /^s$/i)) {print "\nThere were $qReccnt records in the query.\n";}

		}
	elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "QUERY:fetchrecord", $Fetch);}
		
	}
else 
	{

	$Form = VanCreateMainForm($Conn,"TO_DO");
	if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nQUERY:createmain:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:createmain:to_do", $Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:opencursor", $Cursor);}
	$- = 0;
	if (($Fetch = VanFetchRecord($Form)) == VAN_NOERROR) 
		{

		$Field = VanGetField($Form,"SWTODOID",$todoid,20);
		if ($Field == VAN_EFIELD) {$todoid = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swtodoid", $Field);}

		$Field = VanGetField($Form,"SWPRIORITY",$priority,30);
		if ($Field == VAN_EFIELD) {$priority = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swpriority", $Field);}

		$Field = VanGetField($Form,"DITYPE",$tasktype,30);
		if ($Field == VAN_EFIELD) {$tasktype = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:ditype", $Field);}

		$Field = VanGetField($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN",$assignedto,40);
		if ($Field == VAN_EFIELD) {$assignedto = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swassignedtoid|sw_employee_vw.swlogin", $Field);}

		$Field = VanGetField($Form,"SWESTSTARTDATE",$startdate,20);
		if ($Field == VAN_EFIELD) {$startdate = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:sweststartdate", $Field);}

		$Field = VanGetField($Form,"SWSTATUS",$status,30);
		if ($Field == VAN_EFIELD) {$status = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swstatus", $Field);}

		$Field = VanGetField($Form,"SWCUSTOMERID|SW_CUSTOMER.SWNAME",$customername,30);
		if ($Field == VAN_EFIELD) {$customername = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swcustomerid|sw_customer.swname", $Field);}

		$Field = VanGetField($Form,"SWCONTACTID|SW_PERSON.SWLASTNAME",$tlastname,30);
		if ($Field == VAN_EFIELD) {$tlastname = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swcontactid|sw_person.swlastname", $Field);}

		$Field = VanGetField($Form,"SWSUBJECT",$subject,250);
		if ($Field == VAN_EFIELD) {$subject = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swsubject", $Field);}

		$Field = VanGetField($Form,"SWDESCRIPTION",$desc,4000);
		if ($Field == VAN_EFIELD) {$desc = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swdescription", $Field);}

		$Field = VanGetField($Form,"DIDEPARTMENT",$group,40);
		if ($Field == VAN_EFIELD) {$group = "";}
		elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:didepartment", $Field);}

		format_name STDOUT "TASK";
		format_top_name STDOUT "TASK_TOP";
		write STDOUT;

		$numchild = VanNumChilds($Form);
		for ($r = 1; $r <= $numchild; $r++)
			{

			$Rtn = VanChildDesc($Form,$r,VAN_CNAME,$subform,30);
			if ($subform eq "diWorkLog") {$create_subform = "yes";}

			}
		if ($create_subform eq "yes")
			{

			if (($Form2 = VanCreateSummaryForm($Form,"diWorkLog")) < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:createsummary:diWorkLog", $Form2);}
			if (($Cursor2 = VanOpenCursor($Form2,$Cursorwhere2,$Cursororder2)) < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:opencursor", $Cursor2);}
			$- = 0;
			while (($Fetch = VanFetchRecord($Form2)) == VAN_NOERROR) 
				{

				$Field = VanGetField($Form2,"SWWORKLOGID",$noteid,20);
				if ($Field == VAN_EFIELD) {$noteid = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swworklogid", $Field);}

				$Field = VanGetField($Form2,"SWVISIBILITY",$visible,30);
				if ($Field == VAN_EFIELD) {$visible = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swvisibility", $Field);}

				$Field = VanGetField($Form2,"SWSUBJECT",$notesubject,70);
				if ($Field == VAN_EFIELD) {$notesubject = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swsubject", $Field);}

				$Field = VanGetField($Form2,"SWCREATEDBY",$createdby,20);
				if ($Field == VAN_EFIELD) {$createdby = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swcreatedby", $Field);}

				$Field = VanGetField($Form2,"SWDATECREATED",$datecreated,20);
				if ($Field == VAN_EFIELD) {$datecreated = "";}
				elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "QUERY:getfield:swdatecreated", $Field);}

				format_name STDOUT "QUERY_COMMENT";
				format_top_name STDOUT "QUERY_COMMENT_TOP";
				write STDOUT;

				}

			if ($Fetch == VAN_WNODATA)
				{

				if (($Rtn = VanCloseCursor($Form2)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closecursor",$Rtn);}
				if (($Rtn = VanCloseForm($Form2,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closeform",$Rtn);}

				}
			elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "QUERY:fetchrecord", $Fetch);}

			if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closecursor",$Rtn);}
			if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"QUERY:closeform",$Rtn);}

			}

		}

	elsif ($Fetch == VAN_WNODATA)
		{

		print "\nThere is no task for the TaskId that you entered.\n\n";

		}
	elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Fetch, "QUERY:fetchrecord", $Form);}

	}

}


#-------------------------------------------------------------------------------------------------
# REPORTERROR Subroutine
#
# This is the error routine used to print error associated with the Vantive API.
#-------------------------------------------------------------------------------------------------
sub REPORTERROR
{

## VARIABLES USED BE THE SUBROUTINE
my ($handle, $str, $status) = @_;
my $msg = '';

print "Error $str: $status\n";
VanGetMsg($handle, $msg, 1000);
printf "Message: $msg\n";
exit(1);

}


#-------------------------------------------------------------------------------------------------
# TAKE Subroutine
#
# This subroutine is called when the user executes a take command in the vreq shell.  If a Task
# detail is specified as an option on the command line then the routine assigns the Task to
# the current user.
#-------------------------------------------------------------------------------------------------
sub TAKE
{

if ($Detail eq "") {HELP("take");}
else
	{

	$Form = VanCreateMainForm($Conn,"TO_DO");
	if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necassary permissions to execute this command!\nTAKE:createmain:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn,"TAKE:createmain:to_do",$Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn,"TAKE:opencursor",$Cursor);}

	if (($Fetch = VanFetchRecordForUpdate($Form)) == VAN_NOERROR)
		{

		$Rtn = VanSetField($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN",$Username,$Errcode,$Errpath);
		if ($Rtn == VAN_EPERM)
			{

			$Rtn = VanUndoChanges($Form,1);
			print "\n\nYou do not have the necessary permissions to execute this command!\nTAKE:setfield:swassignedtoid|sw_employee_vw.swlogin\n\n";

			}

		elsif ($Rtn == VAN_EVALUE)
			{

			print "\n\nThe value for status you choose does not match one of the predefined values in Vantive.\n";
			print "\n\nThe users command will give you a list of all Vantive users and their logins.\n";
			print "\n\nTasks should be assinged to a Vantive users login.\n\n";

			}

		elsif ($Rtn < VAN_NOERROR)
			{

			REPORTERROR($Conn,"TAKE:setfield:swassignedtoid|sw_employee_vw.swlogin",$Rtn);

			}

		elsif ($Rtn = VAN_NOERROR) 
			{

			if (($Rtn = VanSaveRecord($Form,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"TAKE:saverecord",$Rtn);}
			print "\n\nTask Reassigned to You.\n\n";

			}

		if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"TAKE:closecursor",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"TAKE:closeform",$Rtn);}

		}

	}

}


#-------------------------------------------------------------------------------------------------
# UPDATE Subroutine
#
# The update subroutine update an existing task.  It requires a taskid in as the detail and one of
# the optional parameters to specify a field for update.  Either the status, priority, or owner
# can be updated.  
#-------------------------------------------------------------------------------------------------
sub UPDATE
{

if (($Detail eq "") || (($Status eq "") && ($Priority eq "") && ($Owner eq ""))) {HELP("update");}
else
	{

	$Form = VanCreateMainForm($Conn,"TO_DO");
	if (($Form == VAN_EPERM) || ($Form == VAN_EFORM)) {print "\n\nYou do not have the necessary permissions to execute this command!\nUPDATE:createmain:to_do\n\n";last;}
	elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn,"UPDATE:createmain:to_do",$Form);}
	ADD_TASK_QUAL();
	if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn,"UPDATE:opencursor",$Cursor);}

	if (($Fetch = VanFetchRecordForUpdate($Form)) == VAN_NOERROR)
		{

		if ($Status ne "")
			{

			$Set = VanSetField($Form,"SWSTATUS",$Status,$Errcode,$Errpath);
			if ($Set == VAN_EVALUE)
				{

				print "\n\nThe value for status you choose does not match one of the predefined values in Vantive.\n\n";

				}

			elsif ($Set == VAN_EPERM)
				{

				$Rtn = VanUndoChanges($Form,1);
				print "\n\nYou do not have the necessary permissions to execute this command!\nUPDATE:setfield:swstatus\n\n";

				}
			elsif ($Set < VAN_NOERROR)
				{

				REPORTERROR($Conn,"UPDATE:setfield:swstatus",$Rtn);

				}

			}

		if ($Priority ne "")
			{

			$Set = VanSetField($Form,"SWPRIORITY",$Priority,$Errcode,$Errpath);
			if ($Set == VAN_EVALUE)
				{

				print "\n\nThe value for priority you choose does not match one of the predefined values in Vantive.\n\n";

				}

			elsif ($Set == VAN_EPERM)
				{

				$Rtn = VanUndoChanges($Form,1);
				print "\n\nYou do not have the necessary permissions to execute this command!\nUPDATE:setfield:swpriority\n\n";

				}

			elsif ($Set < VAN_NOERROR)
				{

				REPORTERROR($Conn,"UPDATE:setfield:swpriority",$Rtn);

				}

			}

		if ($Owner ne "")
			{

			$Set = VanSetField($Form,"SWASSIGNEDTOID|SW_EMPLOYEE_VW.SWLOGIN",$Owner,$Errcode,$Errpath);
			if ($Set == VAN_EVALUE) 
				{

				print "\n\nThe value for owner you choose does not match one of the predefined values in Vantive.\n\n";

				}

			elsif ($Set == VAN_EPERM)
				{

				$Rtn = VanUndoChanges($Form,1);
				print "\n\nYou do not have the necessary permissions to execute this command!\nUPDATE:setfield:swassignedtoid|sw_employee_vw.swlogin\n\n";

				}

			elsif ($Set < VAN_NOERROR)
				{

				REPORTERROR($Conn,"UPDATE:setfield:swassignedtoid|sw_employee_vw.swlogin",$Rtn);

				}

			}

		if ($Set == VAN_NOERROR)
			{

			if (($Rtn = VanSaveRecord($Form,$Errcode,$Errpath,0)) < VAN_NOERROR) {REPORTERROR($Conn,"UPDATE:saverecord",$Rtn);}
			print "\n\nRecord Updated\n\n";

			}

		if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"UPDATE:closecursor",$Rtn);}
		if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"UPDATE:closeform",$Rtn);}

		}

	}

}


#-------------------------------------------------------------------------------------------------
# VANTIVE_USERS Subroutine
#
# This subroutine shows a list of all Vantive users along with their login.  The optional user
# parameter can be used as a like clause on the login to narrow the list returned.
#-------------------------------------------------------------------------------------------------
sub VANTIVE_USERS
{

## VARIABLES USED BY THE SUBROUTINE
my $vReccnt = 0;
my $vSpoolcnt = 0;
my $vSpooltest = "";

$Form = VanCreateListForm($Conn,"EMPLOYEE","",0);
if ($Form == VAN_EFORM) {print "\n\nYou do not have the necessary permissions to execute this command!\nVANTIVE_USERS:createmain:employee\n\n";last;}
elsif ($Form < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:createmain:employee", $Form);}
if ($User ne "") {$Cursorwhere = "SWLOGIN LIKE '$User%'";}
if (($Cursor = VanOpenCursor($Form,$Cursorwhere,$Cursororder)) < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:opencursor", $Cursor);}
$vReccnt = VanSearchCount($Form);
$Fetch = VanFetchRecord($Form);
$- = 0;
while ($Fetch == VAN_NOERROR) 
	{
	$vSpoolcnt++;

	$Field = VanGetField($Form,"SWPERSONID",$personid,40);
	if ($Field == VAN_EFIELD) {$personid = "";}
	elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:getfield:swpersonid", $Field);}

	$Field = VanGetField($Form,"SWFIRSTNAME",$vfirstname,40);
	if ($Field == VAN_EFIELD) {$vfirstname = "";}
	elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:getfield:swfirstname", $Field);}

	$Field = VanGetField($Form,"SWLASTNAME",$vlastname,40);
	if ($Field == VAN_EFIELD) {$vlastname = "";}
	elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:getfield:swlastname", $Field);}

	$Field = VanGetField($Form,"SWLOGIN",$login,20);
	if ($Field == VAN_EFIELD) {$login = "";}
	elsif ($Field < VAN_NOERROR) {REPORTERROR($Conn, "VANTIVE_USERS:getfield:swlogin", $Field);}

	format_name STDOUT "QUERY_USERS";
	format_top_name STDOUT "QUERY_USERS_TOP";
	write STDOUT;

	if (($vSpoolcnt % 20) == 0)
		{

		print "\n\n$vSpoolcnt of $vReccnt records of the query are shown. Press enter to continue the query or s to stop the query.\n\n";
		$vSpooltest = <STDIN>;
		chomp($vSpooltest);
		if ($vSpooltest =~ /^s$/i){$Fetch = VAN_WNODATA;}
		else {$Fetch = VanFetchRecord($Form);}

		}

	else {$Fetch = VanFetchRecord($Form)}

	}

if ($Fetch == VAN_WNODATA)
	{

	if (($Rtn = VanCloseCursor($Form)) < VAN_NOERROR) {REPORTERROR($Conn,"VANTIVE_USERS:closecursor",$Rtn);}
	if (($Rtn = VanCloseForm($Form,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"VANTIVE_USERS:closeform",$Rtn);}
	if (!($vSpooltest =~ /^s$/i)) {print "\nThere were $vReccnt records in the query.\n\n";}

	}

elsif ($Fetch < VAN_NOERROR) {REPORTERROR($Form, "VANTIVE_USERS:fetchrecord", $Fetch);}

}


#-------------------------------------------------------------------------------------------------
# Main Program
#
# This is the engine for the program.  It parses the Vantive username and password arguments
# passed in from the command line, connects to the database, creates its own shell prompt, parses
# commands typed at the shell prompt, and prints for unknown commands.
#-------------------------------------------------------------------------------------------------
## VARIABLES USED BY THE MAIN SCRIPT
my @args = "";
my $command = "";

## GLOBAL VARIABLES USED BY THE SCRIPT
$hours = "";
$= = 23; 			#Sets the number of lines to return when using a format.
$create_subform = "";
$numchild = 0;

## GLOBAL VARIABLES USED TO STORE COMMAND LINE VALUES
$Detail = "";
$Status = "";
$Owner = "";
$Priority = "";
$Comment = "";
$Sub = "";
$Note = "";
$File = "";
$Type = "";
$Customer = "";
$Company = "";
$User = "";
$Group = "";
$Person = "";

## GLOBAL VARIABLES USED BY THE VANTIVE API
$Username = "";
$Password = "";
$Host = "206.220.225.203";
$Port = "1540";
$Conn = 0;
$Unsavedform = 0;
$Form = 0;
$Form2 = 0;
$Cursor = 0;
$Cursor2 = 0;
$Fetch = 0;
$Field = 0;
$Set = 0;
$Rtn = 0;
$Cursorwhere = "";
$Cursororder = "";
$Cursorwhere2 = "";
$Cursororder2 = "";
$Errcode = "";
$Errpath = "";

## GLOBAL VARIABLE USED TO STORE THE CURRENT USERS DEPARTMENT RETURNED BY VANTIVE
$UsersGroup = "";

## GLOBAL VARIABLES USED TO STORE THE TASK RECORD RETURNED BY VANTIVE
$todoid = "";
$priority = "";
$tasktype = "";
$assignedto = "";
$startdate = "";
$status = "";
$subject = "";
$tlastname = "";
$customername = "";
$desc = "";
$group = "";

## GLOBAL VARIABLES USED TO STORE THE NOTE RECORD RETURNED BY VANTIVE
$noteid = "";
$visible = "";
$notesubject = "";
$createdby = "";
$datecreated = "";

## GLOBAL VARIABLES USED TO STORE THE CUSTOMER RECORD RETURNED BY VANTIVE
$custid = "";
$company = "";
$phonecountry = "";
$phonearea = "";
$phone = "";
$ctype = "";
$cstatus = "";

## GLOBAL VARIABLES USED TO STORE THE CONTACT RECORD RETURNED BY VANTIVE
$contactid = "";
$clastname = "";
$cfirstname = "";
$ophonecountry = "";
$ophonearea = "";
$ophone = "";
$ophoneext = "";
$aphone = "";
$email = "";

## GLOBAL VARIABLES USED TO STORE THE EMPLOYEE RECORD RETURNED BY VANTIVE
$personid = "";
$vfirstname = "";
$vlastname = "";
$login = "";

## GLOBAL VARIABLES USED TO STORE THE CASE RECORD RETURNED BY VANTIVE
$caseid = "";

chomp(@ARGV);
$parms = @ARGV;
if ($parms < 2) {HELP("start");exit(1);}
$Username = $ARGV[0];
$Password = $ARGV[1];

$Conn = VanOpenConnection($Username,$Password,$Host,$Port);
if ($Conn == VAN_ELOGIN) {die "\n\nThere was an error with your username and/or password!\n\n";}
elsif ($Conn < VAN_NOERROR) {REPORTERROR(-1,"open connection", $Conn);}

GETGROUP();

do
	{

#	RESET ALL VARIABLES USED TO BUILD WHERE CLAUSES FOR FORMS
	$Detail = "";
	$Status = "";
	$Owner = "";
	$Priority = "";
	$Comment = "";
	$Sub = "";
	$Note = "";
	$File = "";
	$Type = "";
	$Customer = "";
	$Company = "";
	$User = "";
	$Group = "";
	$Person = "";
	$Cursorwhere = "";
	$Cursororder = "";
	$Cursorwhere2 = "";
	$Cursororder2 = "";

	print "VREQ>";
	chomp(@args = split(' --',<STDIN>));
	$command = $args[0];
	if ($command ne "")
		{

		SWITCH:
			{

			$command =~ /^bye$/i      and do {                                            last SWITCH;};
			$command =~ /^comment$/i  and do {shift(@args); ARGS(@args); COMMENT();       last SWITCH;};
			$command =~ /^customer$/i and do {shift(@args); ARGS(@args); CUSTOMER();      last SWITCH;};
			$command =~ /^help$/i     and do {shift(@args); HELP(@args);                  last SWITCH;};
			$command =~ /^q$/i        and do {shift(@args); ARGS(@args); QUERY();         last SWITCH;};
			$command =~ /^new$/i      and do {shift(@args); ARGS(@args); NEW();           last SWITCH;};
			$command =~ /^take$/i     and do {shift(@args); ARGS(@args); TAKE();          last SWITCH;};
			$command =~ /^update$/i   and do {shift(@args); ARGS(@args); UPDATE();        last SWITCH;};
			$command =~ /^users$/i    and do {shift(@args); ARGS(@args); VANTIVE_USERS(); last SWITCH;};
			print "You typed an unknown command!\n";
			HELP();

			}

		}

	} until $command eq "bye";

if (($Rtn = VanCloseConnection($Conn,0,$Unsavedform)) < VAN_NOERROR) {REPORTERROR($Conn,"close connection",$Rtn);}
