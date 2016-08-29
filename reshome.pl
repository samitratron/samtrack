#!c:/perl/bin/perl.exe
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Tie::IxHash;
use MIME::Lite;
use POSIX;
use Time::Piece;
use XML::Writer;
use IO::File;

require 'header.pl';
#test
$session = CGI::Session->load();
$cgi = new CGI;
$session->save_param($cgi);

tie(%user_details, Tie::IxHash);

#print "Content-type: text/html; charset=iso-8859-1\n\n";

# Variables passed from query string
#
#my $action=$cgi->param("action");

# Set autoflush on always.
#
#$|=1;


@final_sub_list =();

if($session->is_expired)
  {
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "Your session has expired. Please login again.";
      print "<br/><a href='login.pl>Login</a>";
  }
  elsif($session->is_empty)
  {
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "You have not logged in. Click here to <a href=http://127.0.0.1:80/webapp/login.pl>login</a>";
  }
elsif($cgi->param('action') eq 'home')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");

    $session->clear();
    $session->param(usr=>$myname);
    #$session->param(action=>'view_timecard_submit');

   $full_name = getfullname($myname);

   @months = qw(JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC);
   @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
   $year = 1900 + $yearOffset;
   $searchdate = $dayOfMonth . "-" . $months[$month] . "-" . $year;



               &header($myname);
                        print qq~
                      	<div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Overview :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>                       
		        <tr>
			<td class=TableCellText><font color=blue><b>SaMTrack</b></font> stands for <b>Software Activities Management & Tracker </b>. Using SamTrack users at different levels in the organization can enter, manage and view their and their team's day to day tasks. These tasks might or might not be related to a project. With the help of SaMTrack, user would be able to view resource workload for their teams and align them either due to optimal resource utilization or due to business goals reprioritization. SaMTrack also allows users to search for availability of resources within an organization having specific skillset and competency.</td>
			</tr>
		      </table>


<table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Features :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>                       
		        		<tr>
						<td class=TableCellText><font color=brown>:: Entering, Editing and Viewing Individual and Organization Time Cards</font></td>
					</tr>
					<tr>
						<td class=TableCellText><font color=brown>:: Resource Workload Dashboard</font></td>
					</tr>			
					<tr>				
						<td class=TableCellText><font color=brown>:: Resource Availability Lookup</font></td>
					</tr>
					<tr>			
						<td class=TableCellText><font color=brown>:: Emailing Daily Status Report</font></td>
					</tr>
					<tr>
						<td class=TableCellText><font color=brown>:: Managing skillset Repository</font></td>
					</tr>
		      </table>


<table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Features Under Development :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>                       
		        <tr>
			<td class=TableCellText>Based on the feedback receieved from users <font color=blue><b>SaMTrack </b></font> will also allow users to manage testing or development projects. Currentlt the application is project based and allows users to map tasks/activities to a certain project. Once this feature is implemented, users would be able to track, monitor and control project status and take corrective action when things are not going as planned.</td>
			</tr>
		      </table>
		      <table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Please feel free to send <a href=http://127.0.0.1/webapp/reshome.pl?action=send_feedback>Feedback </a> to Improve <font color=blue><b>SaMTrack</b></font></th>
                      </table>	
                      </div>
                     ~;
		   &footer();				            
}
elsif($cgi->param('action') eq 'capture_timecard')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        new JsDatePick({
                        	useMode:2,
                        	target:"singleenddayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });


                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script language="javascript">
                        function addRow(tableID,hiddenfield)
                        {
                                 var table = document.getElementById(tableID);
                                 //alert("Table is"+table);
                                 var rowCount = table.rows.length;
                                 var row = table.insertRow(rowCount);


                                 var colCount = table.rows[0].cells.length;

                                 var current_row = rowCount + 1;

                                 //alert("Column Count is "+colCount);
                                 for(var i=0; i<colCount; i++)
                                 {
                                   var newcell = row.insertCell(i);

                                   //alert("i is"+i);
                                   if(i==0)
                                   {
                                     cellname = "chkbox";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<input type=checkbox name="+newcell_name+">";
                                   }
                                   else if(i==1)
                                   {
                                     var tasksjoined = document.getElementById("hidden_tasks").getAttribute("value");
                                     //alert(tasksjoined);
                                     var tasks = tasksjoined.split(",");

                                     cellname = "taskcat";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;

                                     content = "<select name="+newcell_name+">";

                                     for(j=0;j<tasks.length;j++)
                                     {
                                      content = content + "<option value='"+tasks[j]+"'>"+tasks[j]+"</option>";
                                     }

                                     //newcell.innerHTML = "<select name="+newcell_name+"><option value='SCRUM:Team:Canada:IGP/EGP'>SCRUM:Team:Canada:IGP/EGP</option><option value='QUARTERLY TASK:Prize Update'>QUARTERLY TASK:Prize Update</option><option value='WATERFALL:DGC'>WATERFALL:DGC</option>";
                                     newcell.innerHTML = content;
                                   }
                                   else if(i==2)
                                   {
                                     cellname = "taskcomments";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<input type=text size=25  maxlength=295 name="+newcell_name+">";
                                   }
                                   else if(i==3)
                                   {
                                     var tasksjoined = document.getElementById("hidden_projects").getAttribute("value");
                                     //alert(tasksjoined);
                                     var tasks = tasksjoined.split(",");

                                     cellname = "projname";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;

                                     content = "<select name="+newcell_name+">";

                                     for(j=0;j<tasks.length;j++)
                                     {
                                      content = content + "<option value='"+tasks[j]+"'>"+tasks[j]+"</option>";
                                     }

                                     //newcell.innerHTML = "<select name="+newcell_name+"><option value='SCRUM:Team:Canada:IGP/EGP'>SCRUM:Team:Canada:IGP/EGP</option><option value='QUARTERLY TASK:Prize Update'>QUARTERLY TASK:Prize Update</option><option value='WATERFALL:DGC'>WATERFALL:DGC</option>";
                                     newcell.innerHTML = content;
                                   }

                                   else if(i==4)
                                   {
                                     cellname = "priority";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<select name="+newcell_name+"><option value=low>Low</option><option value=medium>Medium</option><option value=high>Hign</option></select>";
                                   }

                                   else if(i==5)
                                   {
                                     cellname = "manhours";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<select name="+newcell_name+"><option value='30'>30 min</option><option value='60'>1 hr</option><option value='90'>1.5hr</option><option value='120'>2 hr</option><option value='150'>2.5 hr</option><option value='180'>3 hr</option><option value='210'>3.5 hr</option><option value='240'>4hr</option><option value='270'>4.5 hr</option><option value='300'>5 hr</option><option value='330'>5.5 hr</option><option value='360'>6 hr</option><option value='390'>6.5hr</option><option value='420'>7 hr</option><option value='450'>7.5 hr</option><option value='480'>8 hr</option></select>";
                                   }

                                   else if(i==6)
                                   {
                                     cellname = "status";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<select name="+newcell_name+"><option value='Planned'>Planned</option></select>";
                                   }
                                   
                                   //newcell.innerHTML = table.rows[0].cells[i].innerHTML;


                                   //alert(newcell.childNodes);
                                   var assigned_user = document.getElementById("hidden_user_name").getAttribute("value");
                                   switch(newcell.childNodes[0].type)
                                   {
                                    case "text":
                                                newcell.childNodes[0].value = "";
                                                break;
                                    case "checkbox":
                                                newcell.childNodes[0].checked = false;
                                                break;
                                    case "select-one":
                                                newcell.childNodes[0].selectedIndex = 1;
                                                break;


                                    }
                             }

                        }

                        function deleteRow(tableID,hiddenfield)
                        {
                         try
                         {
                          var table = document.getElementById(tableID);
                          var rowCount = table.rows.length;
                          //alert("Before deletion rowcount is "+rowCount);
                             for(var i=0; i<rowCount; i++)
                             {
                                  var row = table.rows[i];
                                  var chkbox = row.cells[0].childNodes[0];
                                  if(null != chkbox && true == chkbox.checked)
                                  {
                                     if(rowCount <= 1)
                                     {
                                      alert("Cannot delete all the rows.");
                                      break;
                                     }
                                     table.deleteRow(i);

                                     rowCount--;
                                     i--;
                                   }
                              }


                           }
                          catch(e)
                          {
                             alert(e);
                          }
                         }
                         function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {
                         activity_id = document.getElementById("activity_id").value;
                         if(!activity_id)
                         {
                          alert("Please select an Activity");
                          return(false);
                         }
                         if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            return(false);
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            return(false);
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            return(false);
                            }
                          }
                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;


                        getsubordinates($myname);

                        my $final_sub_list_ref = \@final_sub_list;

                        my $hashref = getfullnametitle($final_sub_list_ref);
                        my %user_details = %$hashref;

                        push(@final_sub_list,$myname);
                        my $final_sub_list_ref = \@final_sub_list;

                        my $allusersskillsethashref = getskillsetagainstroles($final_sub_list_ref);
                        my %allusersskillsethash =  %$allusersskillsethashref;

                        my %activities = ();


                       #my $taskhashref = gettaskcategory();
                       #my %task_details = %$taskhashref;

                       @keys = keys (%allusersskillsethash);
                       $tasksjoined = join(",",@keys);

                       ### Getting list of activities for which user is owner

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_desc FROM activities a, activity_details b where a.activity_id=b.id and b.activity_owner = '$myname' and a.activity_status in ('Assigned','Planned','In Progress')order by a.activity_reported_date;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                        $activity_id = $resultset[0];
                        $activity_desc = $resultset[1];
                        $activities{$activity_id} = $activity_desc;
                       }
                       $sth->finish();
                       $dbh->disconnect();

                       ### Getting list of activities for which user is worker

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT a.activity_id,b.activity_desc FROM activity_workers a, activities b where a.activity_id=b.activity_id and a.worker_username = '$myname' and b.activity_status in ('Assigned','Planned','In Progress') order by b.activity_reported_date;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                        $activity_id = $resultset[0];
                        $activity_desc = $resultset[1];
                        $activities{$activity_id} = $activity_desc;
                       }
                       $sth->finish();
                       $dbh->disconnect();


                       ###
                       
                      ### Getting list of tasks within this activity for which user is a worker

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT c.task_id,c.task_comments,c.activity_id FROM task_global c order by c.task_comments asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                        $tasks_id = $resultset[0];
                        $tasks_desc = $resultset[1];
                        $tasks_activity_id = $resultset[2];
                        $tasks_under_activity{$tasks_id} = $tasks_activity_id . "::" . $tasks_desc;
                       }
                       $sth->finish();
                       $dbh->disconnect();


                       ###
                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="process_timecard.pl?action=submit_timecard" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p><p></p></div>

                      <table width=90%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Resource Time Card Entry : </th>
                      </table>
                      <table width=90% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       ~;
                       print "<td width=150 class='TableCellText' >Resource Name :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=resourcename >";

                       push(@curr_name_list,$myname);
                       my $curr_name_list_ref = \@curr_name_list;

                       my $currhashref = getfullnametitle($curr_name_list_ref);
                       my %curruser_details = %$currhashref;

                       foreach $key (keys %curruser_details)
                       {
                         print "<option value=$myname>$curruser_details{$key}</option>";

                       }

                       foreach $key (keys %user_details)
                       {
                         print "<option value=$key>$user_details{$key}</option>";

                       }

                       my $projects_hash_ref = getprojects();

                       my %projects = %$projects_hash_ref;

                       @keys = keys (%projects);
                       my @projectkeys = sort(@keys);
                       push(@keys,"Non - Project");
                       $projectsjoined = join(",",@keys);

                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";
                       print "<table width=90% border=0 cellpadding=3 width=350px border=1>";
                       print "<td width=150 class='TableCellText' >Activity ID :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_id id=activity_id >";
                       foreach $activity_id (keys %activities)
                       {
                        print "<option value=$activity_id>$activity_id :: $activities{$activity_id}</option>";
                       }

                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";

                       print qq~
                        <input type=hidden name=hidden_tasks id=hidden_tasks value="$tasksjoined">
                        <input type=hidden name=hidden_projects id=hidden_projects value="$projectsjoined">
                       ~;
                       print qq~
                        <table width=90%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=100%>Task Planned Start and End Date</th>
                        </table>
                        ~;
                        print "<table width=90%  border='0' cellpadding='3'>";
                        print "<tr><td width=150 class='TableCellText' >Start Date :</td><td width=\"265\" class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text readonly=readonly name=singledayField id=singledayField size=12></div></td></tr>";
                        print "</table>";
                        print "<table width=90%  border='0' cellpadding='3'>";
                        print "<tr><td width=500 class='TableCellText' >End Date :</td><td width=\"265\" class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text readonly=readonly name=singleenddayField id=singleenddayField size=12></div></td></tr>";
                        print "</table>";
                        print qq~
                        <table width=90%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=\"100%\">Enter Daily Tasks :</th>
                        </table>
                        <table width=90%  id=dataTable border='0' cellpadding='3'>
                        <tr class='TableColumnHeader' width=\"100%\">
                            <td style="width:1%;">Chk</td>
                            <td style="width:5%;text-align:center">Type</td>
                            <td style="width:31%;text-align:center">Comments</td>
                            <td style="width:8%;text-align:center">Category</td>
                            <td style="width:8%;text-align:center">Priority</td>
                            <td style="width:8%;text-align:center">Man Hr</td>
                            <td style="width:8%;text-align:center">Status</td>

                        </tr>


                         <tr>
                            <td style="width:4%;"><input type=checkbox name=taskrow_1_chkbox size=25></td>

                            <td style="width:6%;">
                                <select name=taskrow_1_taskcat>
                                ~;

                                foreach $key (keys %allusersskillsethash)
                                {
                                 print "<option value='$key'>$key</option>";
                                 }

                                 print qq~
                                </select>
                            </td>

                            <td style="width:32%;"><input type=text name=taskrow_1_taskcomments size=58 maxlength="295"></td>
                             <td style="width:8%;">
                                <select name=taskrow_1_projname>
                                        <option value="Non - Project">Non - Project</option>
                            ~;

                            #foreach $key (keys %projects)
                             foreach $key (@projectkeys)
                                {
                                 print "<option value='$key'>$key</option>";
                                 }

                            print qq~
                                  </select>
                            </td>
                            <td style="width:8%;">
                                <select name=taskrow_1_priority>
                                        <option value="low">Low</option>
                                        <option value="medium">Medium</option>
                                        <option value="high">High</option>
                                </select>
                            </td>


                            <td style="width:8%;">
                                <select name=taskrow_1_manhours>
                                        <option value='30'>30 min</option><option value='60'>1 hr</option><option value='90'>1.5hr</option><option value='120'>2 hr</option><option value='150'>2.5 hr</option><option value='180'>3 hr</option><option value='210'>3.5 hr</option><option value='240'>4hr</option><option value='270'>4.5 hr</option><option value='300'>5 hr</option><option value='330'>5.5 hr</option><option value='360'>6 hr</option><option value='390'>6.5hr</option><option value='420'>7 hr</option><option value='450'>7.5 hr</option><option value='480'>8 hr</option>
                                </select>
                            </td>


                            <td style="width:8%;">
                                <select name=taskrow_1_status>
                                        <option value='Planned'>Planned</option>
                                </select>
                            </td>
                            


                        </tr>
                       </table>
                       <input class='TableCellText' type=button class=submitButtonEnable1 value=\"Add Task\" onclick=\"addRow('dataTable','taskrowcount')\" />
                       <input class='TableCellText' type=button class=submitButtonEnable1 value=\"Delete Task\" onclick=\"deleteRow('dataTable','taskrowcount')\" />
                       <table width=90% align=center  border='0' cellpadding='3'>
                       <tr>
                       <td class='TableCellText' align='center' ><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=\"return formvalidate()\"/></td>
                       <td class='TableCellText' align='center'><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()\"/></td>
                       </tr>
                       </table>
                       

                       </form>
                       </div>
                       ~;
                       &footer();

  }
elsif($cgi->param('action') eq 'insert_usercalendar_into_db')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'insert_usercalendar_into_db_submit');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          leave_justification = document.getElementById("leave_justification").value;
                          durationfrom_Field_val = document.getElementById("durationfromField").value;
                          durationto_Field_val = document.getElementById("durationtoField").value;
                          if(!leave_justification)
                          {
                            alert("Please Enter Leave Justification");
                            return(false);
                          }
                          if(!durationfrom_Field_val)
                          {
                            alert("Please select From Date");
                            return(false);
                          }
                          if(!durationto_Field_val)
                          {
                            alert("Please select To Date");
                            return(false);
                          }
                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;



                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Enter Leave Plan : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print "<tr>";
                       print "<td width=535 class='TableCellText' >Username :</td>";
                       print "<td class='TableCellText' >$myname</td>";
                       print "<td width=535 class='TableCellText' >Leave Type :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=leave_type >";
                       print "<option value='Casual Leave'>Casual Leave</option>";
                       print "<option value='Sick Leave'>Sick Leave</option>";
                       print "<option value='Privilege Leave'>Privilege Leave</option>";
                       print "<option value='Maternity Leave'>Maternity Leave</option>";
                       print "<option value='Paternity Leave'>Paternity Leave</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "<tr><td width=\"265\" class='TableCellText'>Leave Justification</td><td colspan=3 class='TableCellText'><input type=text name=leave_justification id=leave_justification size=25></td></tr>";
                       print "</table>";

                       ####

                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print qq~
                       <tr>
                       <td width=\"125\" class='TableCellText'>Needed From</td>
                       <td width=125 class='TableCellText'></td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_from>From Date : </td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_to >To Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>

                       </tr>
                       </table>





                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\"return formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'insert_usercalendar_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    $session->param(action=>'submit_timecard');

    %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");


                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                      <th class='TableColumnHeader' width=100% >Resource Lookup Details :</th>
                      </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $resource_from_date_need = $session->param("durationfromField");
                      my $resource_to_date_need = $session->param("durationtoField");
                      my $leave_type = $session->param("leave_type");
                      my $leave_justification = $session->param("leave_justification");

                      if($resource_from_date_need=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }
                          
                          $leave_from_date = $year . "-" . $month . "-" .  $day;
                          
                      if($resource_to_date_need=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }
                          
                          $leave_to_date = $year . "-" . $month . "-" .  $day;

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Leave Submission Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO user_leaves (username,leave_fromdate,leave_todate,leave_type,leave_justification) VALUES ('$resource_name','$leave_from_date','$leave_to_date','$leave_type','$leave_justification');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();
                      $dbh->disconnect();

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Leave Plan was submitted successfully.</td></tr>";
                      print "</table>";

                       &footer();
}
elsif($cgi->param('action') eq 'insert_activity')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'insert_activity_into_db_submit');
     $session->param(usr=>$myname);

     tie(%goals, Tie::IxHash);
     tie(%milestones, Tie::IxHash);


     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



     $customdate = $dayOfMonth . "-" . $month . "-" .  $year . "-" . $hour . ":" .  $minute . ":" . $second;
     $curr_activity_id = $dayOfMonth . $month . $year . $hour . $minute . $second;
     &header($myname);

                        print qq~
                        <script type="text/javascript">
                         window.onload = function(){

                         new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });



                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {
                          activity_reqemail = document.getElementById("activity_reqemail").value;
                          activity_comments = document.getElementById("activity_comments").value;
                          activity_comments_length =  activity_comments.length;
                          activity_desc = document.getElementById("activity_desc").value;
                          activity_desc_length = activity_desc.length;


                          if(!activity_reqemail)
                          {
                            alert("Please enter Activity Requestor Email");
                            return(false);
                          }
                          if(!activity_desc)
                          {
                            alert("Please enter Activity Description");
                            return(false);
                          }
                          if(activity_desc_length > 145)
                          {
                            alert("Please restrict Activity Description to 145 char");
                            return(false);
                          }
                          if(!activity_comments)
                          {
                            alert("Please enter Activity Comments");
                            return(false);
                          }
                          if(activity_comments_length > 145)
                          {
                            alert("Please restrict Activity Comments to 145 char");
                            return(false);
                          }

                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;

#                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#                         my $sth = $dbh->prepare("SELECT count(*),max(activity_id) from activities;");
#                         $sth->execute() || die "$DBI::errstr\n";
#                         while (@resultset = $sth->fetchrow_array)
#                         {
#                           if($resultset[0]==0)
# 			  {
# 			    $curr_activity_id = $date . 1;
# 			  }
# 			  else
# 			  {		
# 			   $curr_activity_id = $resultset[1] + 1;	  
# 			  }
#                         }
#                        $sth->finish();
#                        $dbh->disconnect();

#                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#                        my $sth = $dbh->prepare("SELECT username FROM resources order by username asc");
#                        $sth->execute() || die "$DBI::errstr\n";
#                        while (@resultset = $sth->fetchrow_array)
#                        {
#                          push(@names,$resultset[0]);
#                        }
#                        $sth->finish();
#                        $dbh->disconnect();

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       #$curr_activity_id = $customdate . "[$myname]";

                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Enter Activity Details :[$customdate] </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       
                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";


                       print "<tr><td width=150 class='TableCellText' >Activity Planned Start Date :</td><td width=\"265\" class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text readonly=readonly name=singledayField id=singledayField size=12></div></td></tr>";
                      

                       print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_type >";
                       print "<option value='Alpha Testing'>Test Automation</option>";
                       print "<option value='Production Testing'>Task Automation</option>";
                       print "<option value='Online Testing'>Statistics/Reporting</option>";
                       print "<option value='CSD Issue Checking'>Training/Mentoring</option>";
                       print "<option value='CSD Issue Checking'>Research</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td width=300 class='TableCellText' >Activity Status :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_status id=activity_status value='Unassigned' size=15></td></tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Priority :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_priority >";
                       print "<option value='Low'>Low</option>";
                       print "<option value='Medium'>Medium</option>";
                       print "<option value='High'>High</option>";
                       print "<option value='Urgent'>Urgent</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT goal_id,goal_name FROM goals order by goal_name asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $goal_id = $resultset[0];
                         $goal_name = $resultset[1];
                         $goals{$goal_id} = $goal_name;
                       }
                       $sth->finish();
                       $dbh->disconnect();

                       print "<tr><td width=300 class='TableCellText' >Goal :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=goal >";
                       foreach $key (keys %goals)
                       {
                        print "<option value='$key'>$goals{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT milestone_id,milestone_desc FROM milestone order by milestone_desc asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $milestone_id = $resultset[0];
                         $milestone_desc = $resultset[1];
                         $milestones{$milestone_id} = $milestone_desc;
                       }
                       $sth->finish();
                       $dbh->disconnect();

                       print "<tr><td width=300 class='TableCellText' >Milestone :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=milestone >";
                       foreach $key (keys %milestones)
                       {
                        print "<option value='$key'>$milestones{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td width=300 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText'><input type=email name=activity_reqemail id=activity_reqemail size=25></td></tr>";
                       
                       print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_notified_using >";
                       print "<option value='EMail'>EMail</option>";
#                       print "<option value='Mantis'>Mantis</option>";
#                       print "<option value='Control Ops'>Control Ops</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td class='TableCellText'><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       print "</tr>";
                       print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td class='TableCellText'><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\" return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'insert_activity_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    $session->param(action=>'submit_timecard');

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



    $activity_reported_date = $year . "-". $month . "-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $activity_id = $session->param("activity_id");
                      my $activity_type = $session->param("activity_type");
                      my $activity_status = $session->param("activity_status");
                      my $activity_priority = $session->param("activity_priority");
                      my $activity_reqemail = $session->param("activity_reqemail");
                      my $activity_notified_using = $session->param("activity_notified_using");
                      my $activity_desc = $session->param("activity_desc");
                      my $activity_comments = $session->param("activity_comments");
                      my $goal = $session->param("goal");
                      my $milestone = $session->param("milestone");
                      my $activity_planned_start_date = $session->param("singledayField");

                      $activity_planned_start_date = convert_jquerydate_to_mysql_date($activity_planned_start_date);

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("SELECT milestone_date FROM milestone where milestone_id = $milestone;");
                      $sth->execute() || die "$DBI::errstr\n";
                      while (@resultset = $sth->fetchrow_array)
                      {
                        $milestone_date = $resultset[0];
                      }
                      $sth->finish();
                      $dbh->disconnect();



                      map {s/'/''/g} $activity_desc;
                      map {s/'/''/g} $activity_comments;


#                     if($activity_reported_date=~/(\d+)-(.*)-(\d+)/)
#                     {
#                       $day = $1;
#                       $month_alphabetic = $2;
#                       $month = $months{$month_alphabetic};
#                       $year = $3;
#                      }

#                    $activity_reported_date = $year . "-" . $month . "-" .  $day;
#
#                       if($activity_planned_end_date=~/(\d+)-(.*)-(\d+)/)
#                           {
#                             $day = $1;
#                             $month_alphabetic = $2;
#                             $month = $months{$month_alphabetic};
#                             $year = $3;
#                           }
#
#                           $activity_planned_end_date = $year . "-" . $month . "-" .  $day;

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Activity Submission Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO activities (activity_id,activity_type,activity_status,activity_priority,activity_reqemail,activity_notified_using,activity_desc,activity_comments,activity_reported_date,goal_id) VALUES ('$activity_id','$activity_type','$activity_status','$activity_priority','$activity_reqemail','$activity_notified_using','$activity_desc','$activity_comments','$activity_reported_date','$goal');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO activity_details (id,activity_owner,activity_planned_manhrs,milestone_id,activity_planned_start_date,activity_planned_end_date) VALUES ('$activity_id','Unassigned','0','$milestone','$activity_planned_start_date','$milestone_date');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();
                      $dbh->disconnect();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Activity having ID : $activity_id was submitted successfully.</td></tr>";
                      print "</table>";

                       &footer();
}
elsif($cgi->param('action') eq 'register_risk')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'register_risk_into_db_submit');
     $session->param(usr=>$myname);

     tie(%goals, Tie::IxHash);
     tie(%milestones, Tie::IxHash);


     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



     $customdate = $dayOfMonth . "-" . $month . "-" .  $year . "-" . $hour . ":" .  $minute . ":" . $second;
     $today = $year . "-" . $month . "-" . $dayOfMonth;
     &header($myname);

     print qq~
     <script type="text/javascript">
      window.onload = function(){
      new JsDatePick({
      	useMode:2,
      	target:"singledayField",
      	dateFormat:"%d-%M-%Y"
      	/*selectedDate:{
      	day:5,
      	month:9,
      	year:2006
      	},
      	yearsRange:[1978,2020],
      	limitToToday:false,
      	cellColorScheme:"blue",
      	dateFormat:"%m-%d-%Y",
      	imgPath:"img/",
      	weekStartDay:1*/
        });
      };



      function formvalidate()
      {
         singledayField_val = document.getElementById("singledayField").value;
         activity_id = document.getElementById("searched_activity_id").value;
         searched_activity_owner = document.getElementById("searched_activity_owner").value;

         if((!singledayField_val) && (!activity_id) && (!searched_activity_owner))
         {
          alert("Please enter either activity id or date or activity owner's username to retrieve activity");
          return(false);
         }
      }
    </script>
    ~;

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       $curr_activity_id = $customdate . "[$myname]";



                       #print "<tr><td width=300 class='TableCellText' >Goal ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT milestone_id,milestone_comments FROM milestone where milestone_achieved='No' order by milestone_comments asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $milestone_id = $resultset[0];
                         $milestone_comments = $resultset[1];
                         $milestones{$milestone_id} = $milestone_comments;
                       }
                       $sth->finish();
                       $dbh->disconnect();
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Register Risk :[$customdate] </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       #print "<tr><td width=300 class='TableCellText' >Goal ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";


                       print "<tr><td width=300 class='TableCellText' >Milestone Under Risk :</td>";
                       print "<td class='TableCellText' >";
                       print "<select style='width: 450px' name=risk_affecting_milestone >";
                       foreach $key (keys %milestones)
                       {
                        print "<option value='$key'>$milestones{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td class='TableCellText' >Risk Description :</td><td class='TableCellText'><input type=text name=risk_desc id=risk_desc size=100></td></tr>";
                       print "<tr><td class='TableCellText' >Risk Raised By :</td><td class='TableCellText'><input readonly=readonly type=text name=risk_raised_by id=risk_raised_by size=15 value='$myname'></td></tr>";
                       print "<tr><td class='TableCellText' >Risk Impact :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=risk_impact >";
                       print "<option value='1'>1</option>";
                       print "<option value='2'>2</option>";
                       print "<option value='3'>3</option>";
                       print "<option value='4'>4</option>";
                       print "<option value='5'>5</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       print "<tr><td class='TableCellText' >Risk Probability</td><td class='TableCellText'><input type=text name=risk_probability id=risk_probability maxlength='3' size=1></td></tr>";
                       print "<tr><td class='TableCellText' >Risk Raised On</td><td class='TableCellText'><input readonly=readonly type=text name=risk_raise_date id=risk_raise_date size=10 value=$today></td></tr>";
                       print "<tr><td width=300 class='TableCellText' >Mitigation Plan :</td><td class='TableCellText'><input type=text name=risk_mitigation_plan id=risk_mitigation_plan size=100></td></tr>";


                       print "</table>";



                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\" return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'register_risk_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



    $activity_reported_date = $year . "-". $month . "-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $risk_affecting_milestone = $session->param("risk_affecting_milestone");
                      my $risk_desc = $session->param("risk_desc");
                      my $risk_raised_by = $session->param("risk_raised_by");
                      my $risk_impact = $session->param("risk_impact");
                      my $risk_probability = $session->param("risk_probability");
                      my $risk_raise_date = $session->param("risk_raise_date");
                      my $risk_mitigation_plan = $session->param("risk_mitigation_plan");

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Risk Registration Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO risk_register (risk_desc,risk_affecting_milestone,risk_raise_date,risk_raised_by,risk_impact,risk_probability,risk_mitigation_plan) VALUES ('$risk_desc','$risk_affecting_milestone','$risk_raise_date','$risk_raised_by','$risk_impact','$risk_probability','$risk_mitigation_plan');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Risk was registered successfully.</td></tr>";
                      print "</table>";

                       &footer();
}
elsif($cgi->param('action') eq 'unregister_risk')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'unregister_risk_into_db_submit');
     $session->param(usr=>$myname);

     tie(%goals, Tie::IxHash);
     tie(%milestones, Tie::IxHash);


     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



     $customdate = $dayOfMonth . "-" . $month . "-" .  $year . "-" . $hour . ":" .  $minute . ":" . $second;
     $today = $year . "-" . $month . "-" . $dayOfMonth;
     &header($myname);

     print qq~
     <script type="text/javascript">
      window.onload = function(){
      new JsDatePick({
      	useMode:2,
      	target:"singledayField",
      	dateFormat:"%d-%M-%Y"
      	/*selectedDate:{
      	day:5,
      	month:9,
      	year:2006
      	},
      	yearsRange:[1978,2020],
      	limitToToday:false,
      	cellColorScheme:"blue",
      	dateFormat:"%m-%d-%Y",
      	imgPath:"img/",
      	weekStartDay:1*/
        });
      };



      function formvalidate()
      {
         singledayField_val = document.getElementById("singledayField").value;
         activity_id = document.getElementById("searched_activity_id").value;
         searched_activity_owner = document.getElementById("searched_activity_owner").value;

         if((!singledayField_val) && (!activity_id) && (!searched_activity_owner))
         {
          alert("Please enter either activity id or date or activity owner's username to retrieve activity");
          return(false);
         }
      }
    </script>
    ~;

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       $curr_activity_id = $customdate . "[$myname]";



                       #print "<tr><td width=300 class='TableCellText' >Goal ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT id,risk_desc FROM risk_register order by risk_desc asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $risk_id = $resultset[0];
                         $risk_desc = $resultset[1];
                         $risks{$risk_id} = $risk_desc;
                       }
                       $sth->finish();
                       $dbh->disconnect();
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Unregister Risk : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       #print "<tr><td width=300 class='TableCellText' >Goal ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";


                       print "<tr><td width=300 class='TableCellText' >Select Risk To Unregister :</td>";
                       print "<td class='TableCellText' >";
                       print "<select style='width: 450px' name=risk_affecting_milestone >";
                       foreach $key (keys %risks)
                       {
                        print "<option value='$key'>$risks{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";
 
                       print "</table>";



                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\" return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'unregister_risk_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



    $activity_reported_date = $year . "-". $month . "-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $risk_id = $session->param("risk_affecting_milestone");

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Risk Unregistration Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("DELETE FROM risk_register WHERE id=$risk_id and risk_raised_by='$myname';");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Risk was unregistered successfully.</td></tr>";
                      print "</table>";

                       &footer();
}

elsif($cgi->param('action') eq 'insert_milestone')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'insert_milestone_into_db_submit');
     $session->param(usr=>$myname);

     tie(%goals, Tie::IxHash);
     tie(%milestones, Tie::IxHash);


     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



     $customdate = $dayOfMonth . "-" . $month . "-" .  $year . "-" . $hour . ":" .  $minute . ":" . $second;

     &header($myname);

     print qq~
     <script type="text/javascript">
      window.onload = function(){
      new JsDatePick({
      	useMode:2,
      	target:"singledayField",
      	dateFormat:"%d-%M-%Y"
      	/*selectedDate:{
      	day:5,
      	month:9,
      	year:2006
      	},
      	yearsRange:[1978,2020],
      	limitToToday:false,
      	cellColorScheme:"blue",
      	dateFormat:"%m-%d-%Y",
      	imgPath:"img/",
      	weekStartDay:1*/
        });
      };



      function formvalidate()
      {
         singledayField_val = document.getElementById("singledayField").value;
         activity_id = document.getElementById("searched_activity_id").value;
         searched_activity_owner = document.getElementById("searched_activity_owner").value;

         if((!singledayField_val) && (!activity_id) && (!searched_activity_owner))
         {
          alert("Please enter either activity id or date or activity owner's username to retrieve activity");
          return(false);
         }
      }
    </script>
    ~;

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       $curr_activity_id = $customdate . "[$myname]";

                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Enter Milestone Details :[$customdate] </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       #print "<tr><td width=300 class='TableCellText' >Goal ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT goal_id,goal_name FROM goals order by goal_name asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $goal_id = $resultset[0];
                         $goal_name = $resultset[1];
                         $goals{$goal_id} = $goal_name;
                       }
                       $sth->finish();
                       $dbh->disconnect();

                       print "<tr><td width=300 class='TableCellText' >Milestone Applicable For Goal :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=milestone_goal >";
                       foreach $key (keys %goals)
                       {
                        print "<option value='$key'>$goals{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";



                       print "<tr><td width=300 class='TableCellText' >Milestone Requestor Email :</td><td class='TableCellText'><input type=email name=milestone_reqemail id=milestone_reqemail size=25></td></tr>";
                       print "<tr><td width=300 class='TableCellText' >Milestone Desc :</td><td class='TableCellText'><input type=text name=milestone_desc id=milestone_desc size=75></td></tr>";
                       print "<tr><td width=\"300\" class='TableCellText'>Milestone Comments</td><td class='TableCellText'><input type=text name=milestone_comments id=milestone_comments size=75></td></tr>";
                       print "<tr><td width=535  class='TableCellText' >Milestone Date</td>";
                       print "<td width=\"265\" class='TableCellText'><div id=div_form_single style='visibility:visible'><img src=http://127.0.0.1/webapp/testlink/images/calendar-icon.png><input type=text readonly name=singledayField id=singledayField size=12></img></div></td></tr>";
                       print "</table>";
                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\" return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'insert_milestone_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



    $activity_reported_date = $year . "-". $month . "-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $milestone_goal = $session->param("milestone_goal");
                      my $milestone_reqemail = $session->param("milestone_reqemail");
                      my $milestone_desc = $session->param("milestone_desc");
                      my $milestone_comments = $session->param("milestone_comments");
                      my $milestone_date = $session->param("singledayField");

                      $milestone_date = convert_jquerydate_to_mysql_date($milestone_date);

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Activity Submission Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO milestone (goal_id,milestone_desc,milestone_date,milestone_comments,milestone_reqemail,milestone_achieved) VALUES ('$milestone_goal','$milestone_desc','$milestone_date','$milestone_comments','$milestone_reqemail','No');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Milestone was submitted successfully.</td></tr>";
                      print "</table>";

                       &footer();
}

elsif($cgi->param('action') eq 'link_activity_to_milestone')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'link_activity_to_milestone_db_submit');
     $session->param(usr=>$myname);

     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



     $customdate = $dayOfMonth . "-" . $month . "-" .  $year . "-" . $hour . ":" .  $minute . ":" . $second;

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {
                          activity_reqemail = document.getElementById("activity_reqemail").value;
                          activity_comments = document.getElementById("activity_comments").value;
                          activity_comments_length =  activity_comments.length;
                          activity_desc = document.getElementById("activity_desc").value;
                          activity_desc_length = activity_desc.length;


                          if(!activity_reqemail)
                          {
                            alert("Please enter Activity Requestor Email");
                            return(false);
                          }
                          if(!activity_desc)
                          {
                            alert("Please enter Activity Description");
                            return(false);
                          }
                          if(activity_desc_length > 145)
                          {
                            alert("Please restrict Activity Description to 145 char");
                            return(false);
                          }
                          if(!activity_comments)
                          {
                            alert("Please enter Activity Comments");
                            return(false);
                          }
                          if(activity_comments_length > 145)
                          {
                            alert("Please restrict Activity Comments to 145 char");
                            return(false);
                          }

                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;

#                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#                         my $sth = $dbh->prepare("SELECT count(*),max(activity_id) from activities;");
#                         $sth->execute() || die "$DBI::errstr\n";
#                         while (@resultset = $sth->fetchrow_array)
#                         {
#                           if($resultset[0]==0)
# 			  {
# 			    $curr_activity_id = $date . 1;
# 			  }
# 			  else
# 			  {		
# 			   $curr_activity_id = $resultset[1] + 1;	  
# 			  }
#                         }
#                        $sth->finish();
#                        $dbh->disconnect();

#                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#                        my $sth = $dbh->prepare("SELECT username FROM resources order by username asc");
#                        $sth->execute() || die "$DBI::errstr\n";
#                        while (@resultset = $sth->fetchrow_array)
#                        {
#                          push(@names,$resultset[0]);
#                        }
#                        $sth->finish();
#                        $dbh->disconnect();

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       $curr_activity_id = $customdate . "[$myname]";

                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Set a Milestone :[$customdate] </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       
                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_type >";
                       print "<option value='Alpha Testing'>Test Automation</option>";
                       print "<option value='Production Testing'>Task Automation</option>";
                       print "<option value='Online Testing'>Statistics/Reporting</option>";
                       print "<option value='CSD Issue Checking'>Training/Mentoring</option>";
                       print "<option value='CSD Issue Checking'>Research</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td width=300 class='TableCellText' >Activity Status :</td><td class='TableCellText'><input type=text readonly=readonly name=activity_status id=activity_status value='Unassigned' size=15></td></tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Priority :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_priority >";
                       print "<option value='Low'>Low</option>";
                       print "<option value='Medium'>Medium</option>";
                       print "<option value='High'>High</option>";
                       print "<option value='Urgent'>Urgent</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT goal_id,goal_name FROM goals order by goal_name asc;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                         $goal_id = $resultset[0];
                         $goal_name = $resultset[1];
                         $goals{$goal_id} = $goal_name;
                       }
                       $sth->finish();
                       $dbh->disconnect();

                       print "<tr><td width=300 class='TableCellText' >Goal :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=goal >";
                       foreach $key (keys %goals)
                       {
                        print "<option value='$key'>$goals{$key}</option>";
                       }
                       print "</select>";
                       print "</td>";
                       print "</tr>";



                       print "<tr><td width=300 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText'><input type=email name=activity_reqemail id=activity_reqemail size=25></td></tr>";
                       
                       print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=activity_notified_using >";
                       print "<option value='EMail'>EMail</option>";
#                       print "<option value='Mantis'>Mantis</option>";
#                       print "<option value='Control Ops'>Control Ops</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td class='TableCellText'><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       print "</tr>";
                       print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td class='TableCellText'><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit\" onclick=\" return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'link_activity_to_milestone_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    $session->param(action=>'submit_timecard');

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;


    $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
    $month = $month + 1;



     if($month=~/^\d$/)
     {
      $month = "0" . $month;
     }
     if($dayOfMonth=~/^\d$/)
     {
      $dayOfMonth = "0" . $dayOfMonth;
      }



    $activity_reported_date = $year . "-". $month . "-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $activity_id = $session->param("activity_id");
                      my $activity_type = $session->param("activity_type");
                      my $activity_status = $session->param("activity_status");
                      my $activity_priority = $session->param("activity_priority");
                      my $activity_reqemail = $session->param("activity_reqemail");
                      my $activity_notified_using = $session->param("activity_notified_using");
                      my $activity_desc = $session->param("activity_desc");
                      my $activity_comments = $session->param("activity_comments");
                      my $goal = $session->param("goal");


                      map {s/'/''/g} $activity_desc;
                      map {s/'/''/g} $activity_comments;


#                     if($activity_reported_date=~/(\d+)-(.*)-(\d+)/)
#                     {
#                       $day = $1;
#                       $month_alphabetic = $2;
#                       $month = $months{$month_alphabetic};
#                       $year = $3;
#                      }

#                    $activity_reported_date = $year . "-" . $month . "-" .  $day;
#
#                       if($activity_planned_end_date=~/(\d+)-(.*)-(\d+)/)
#                           {
#                             $day = $1;
#                             $month_alphabetic = $2;
#                             $month = $months{$month_alphabetic};
#                             $year = $3;
#                           }
#                           
#                           $activity_planned_end_date = $year . "-" . $month . "-" .  $day;

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Activity Submission Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO activities (activity_id,activity_type,activity_status,activity_priority,activity_reqemail,activity_notified_using,activity_desc,activity_comments,activity_reported_date,goal_id) VALUES ('$activity_id','$activity_type','$activity_status','$activity_priority','$activity_reqemail','$activity_notified_using','$activity_desc','$activity_comments','$activity_reported_date','$goal');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("INSERT INTO activity_details (id,activity_owner,activity_planned_manhrs) VALUES ('$activity_id','Unassigned','0');");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();
                      $dbh->disconnect();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Activity having ID : $activity_id was submitted successfully.</td></tr>";
                      print "</table>";

                       &footer();
}
elsif($cgi->param('action') eq 'delete_activity_form')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'delete_activity_submit');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          resourcename_val = document.getElementById("resourcename").value;
                          alert('test')
                          alert('Resourcename is '+resourcename_val);

                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;




                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Enter Activity ID to Delete : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td><input type=text name=delete_activity_id id=delete_activity_id size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       #print "<td class='TableCellText' >";
                       #print "<select name=activity_notified_using >";
                       #print "<option value='EMail'>EMail</option>";
                       #print "<option value='Mantis'>Mantis</option>";
                       #print "<option value='Control Ops'>Control Ops</option>";
                       #print "</select>";
                       #print "</td>";
                       #print "</tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       #print "</tr>";
                       #print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       #print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Delete Activity\" onclick=\"formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'delete_activity_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    #my $activity_status = $session->param("hidden_activity_status");
    my $activity_id = $session->param("delete_activity_id");

    &header($myname);



                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                         %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");


                        ###  Delete tasks linked to activity

                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("delete from task_global where activity_id='$activity_id';");
                        $sth->execute() || die "$DBI::errstr\n";
                        $sth->finish();
                        $dbh->disconnect();
  
                        ###  Delete activity from activities table

                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("delete from activities where activity_id='$activity_id';");
                        $sth->execute() || die "$DBI::errstr\n";
                        $sth->finish();
                        $dbh->disconnect();

                        ###  Delete activity from activity_details table

                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("delete from activity_details where id='$activity_id';");
                        $sth->execute() || die "$DBI::errstr\n";
                        $sth->finish();
                        $dbh->disconnect();

                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Activity Delete Status</th>";
                         print "<tr><td class='TableCellText' >Activity Having ID $activity_id Delete Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                         print "</table>";

                       &footer();
}
elsif($cgi->param('action') eq 'activity_resourcing_form')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'activity_resourcing_submit');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          resourcename_val = document.getElementById("resourcename").value;
                          alert('test')
                          alert('Resourcename is '+resourcename_val);

                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;




                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Retrieve Activity to Assign Resources : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td><input type=text name=activity_id_resourcing id=activity_id_resourcing size=50></td></tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       #print "<td class='TableCellText' >";
                       #print "<select name=activity_notified_using >";
                       #print "<option value='EMail'>EMail</option>";
                       #print "<option value='Mantis'>Mantis</option>";
                       #print "<option value='Control Ops'>Control Ops</option>";
                       #print "</select>";
                       #print "</td>";
                       #print "</tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       #print "</tr>";
                       #print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       #print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Search\" onclick=\"formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'activity_resourcing_submit')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     #$timecarduser = $session->param("timecard_user");
     #$timecarddate = $session->param("singledayField");
     $activity_id = $session->param("activity_id_resourcing");

     $session->clear();
     $session->param(usr=>$myname);
     $session->param(activity_id_resourcing=>$activity_id);
     #$session->param(singledayField=>$timecarddate);
     $session->param(action=>'activity_resourcing_db_update');



     %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");

    if($timecarddate=~/(\d+)-(.*)-(\d+)/)
    {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


     &header($myname);
                        print qq~

                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"planned_start_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        new JsDatePick({
                        	useMode:2,
                        	target:"planned_end_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"actual_end_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>

                        <script language="javascript">
                         function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;
                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      ~;

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("SELECT a.activity_type,a.activity_status,a.activity_priority,a.activity_reqemail,a.activity_desc,a.activity_comments,b.activity_owner,b.activity_planned_manhrs,b.activity_planned_start_date,b.activity_planned_end_date FROM activities a, activity_details b where a.activity_id= '$activity_id' and a.activity_id=b.id and b.activity_owner='$myname' and a.activity_status in ('Assigned','Planned','In Progress');");
                      $sth->execute() || die "$DBI::errstr\n";
                      my $task_count =  0;
                      while (@resultset = $sth->fetchrow_array)
                      {
                       $task_count ++;
                       $activity_type = $resultset[0];
                       $activity_status = $resultset[1];
                       $activity_priority = $resultset[2];
                       $activity_reqemail = $resultset[3];
                       $activity_desc = $resultset[4];
                       $activity_comments = $resultset[5];
                       $activity_owner = $resultset[6];
                       $activity_planned_manhrs = $resultset[7];
                       $activity_planed_start_date = $resultset[8];
                       $activity_planed_end_date = $resultset[9];
                      }
                      $sth->finish();
                      $dbh->disconnect();

                      if($task_count == 0 )
                      {
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Activity Resourcing Status</th>";
                         print "<tr><td class='TableCellText' >Activity with ID : $activity_id is not assigned to you.</td></tr>";
                         print "</table>";
                      }
                      elsif($task_count>0)
                      {
                                print "<input type=hidden name=hidden_activity_status id=hidden_activity_status value='$activity_status'>";


                                  print "<table width=87%  border='0' cellpadding='3'>";
                                  print "<th class='TableColumnHeader' width=100% >Activty Details : </th>";
                                  print "</table>";
                                  print "<table width=87%  border='0' cellpadding='3'>";
                                  print "<th class='TableColumnHeader' width=100% >Activty Non-Editable Details : </th>";
                                  print "</table>";
                                  print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                                  print "<tr><td width=200 class='TableCellText' >Activity ID :</td><td class='TableCellText' >$activity_id</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Type :</td><td class='TableCellText' >$activity_type</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Status :</td><td class='TableCellText' >$activity_status</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Priority :</td><td class='TableCellText' >$activity_priority</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText' >$activity_reqemail</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Desc :</td><td class='TableCellText' >$activity_desc</td></tr>";
                                  print "<tr><td width=200 class='TableCellText' >Activity Comments :</td><td class='TableCellText' >$activity_comments</td></tr>";
                                  print "</table>";



                                  print "<table width=87%  border='0' cellpadding='3'>";
                                  print "<th class='TableColumnHeader' width=\"100%\">Activity Editable Details :</th>";
                                  print "</table>";

                                  print "<table width=87% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                                  print "<tr class='TableColumnHeader'>";
                                  print "<td>Activity Owner</td>";



                                     getsubordinates($myname);
                                     push(@final_sub_list,$myname);



                                        print "<td>";
                                        print "<select name=activity_workers>";

                                        foreach $name(@final_sub_list)
                                        {
                                          print "<option value='$name'>$name</option>";
                                        }
                                        print "</select>";
                                        print "</td>";

                                        print "</tr>";
                                        print "</table>";
                                     print qq~


                                     <input type=hidden name=hidden_totaltasks id=hidden_totaltasks value="$task_count">
                                     <table width=87%  border='0' cellpadding='3'>
                                     <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Assign Resources\" ></td>
                                     <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                                     </tr>
                                     </table>
                                     </form>
                                     </div>

                                   ~;

#                              elsif($activity_status eq "Completed")
#                                 {
#                                    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                                    print "<th class='TableColumnHeader' width=\"100%\">Update Activity Status</th>";
#                                    print "<tr><td class='TableCellText' >Activity Having ID $activity_id is already completed</td></tr>";
#                                    print "</table>";
# 
#                                 }

                      }

                      &footer();

}
elsif($session->param('action') eq 'activity_resourcing_db_update')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    #my $activity_status = $session->param("hidden_activity_status");
    my $activity_id = $session->param("activity_id_resourcing");


    &header($myname);



                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                         %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");


                         my $activity_worker = $session->param("activity_workers");

                         #my @activity_workers = @$activity_workers_array_ref;


                          print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                          print "<th class='TableColumnHeader' width=\"100%\">Assign Activity Resourcing Status</th>";



                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("SELECT count(worker_username) from activity_workers where activity_id='$activity_id' and worker_username='$activity_worker';");
                            $sth->execute() || die "$DBI::errstr\n";
                            my $task_count =  0;
                            while ($resultset = $sth->fetchrow_array)
                            {
                             $entry_count = $resultset;
                            }
                            $sth->finish();
                            $dbh->disconnect();

                            if($entry_count == 0)
                            {
                                my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                my $sth = $dbh->prepare("INSERT INTO activity_workers(activity_id,worker_username) VALUES ('$activity_id','$activity_worker');");
                                $sth->execute() || die "$DBI::errstr\n";
                              
                                $sth->finish();
                                $dbh->disconnect();
                            }
                            else
                            {


                            }


                          print "<tr><td class='TableCellText' >Activity Having ID $activity_id Resourcing Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                          print "</table>";

                          print "</div>";


                       &footer();
}
elsif($cgi->param('action') eq 'update_activity_form')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'update_activity_submit');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          resourcename_val = document.getElementById("resourcename").value;
                          alert('test')
                          alert('Resourcename is '+resourcename_val);

                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;




                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Retrieve Activity to Update : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td><input type=text name=update_activity_id id=update_activity_id size=50></td></tr>";
                       
                       #print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       #print "<td class='TableCellText' >";
                       #print "<select name=activity_notified_using >";
                       #print "<option value='EMail'>EMail</option>";
                       #print "<option value='Mantis'>Mantis</option>";
                       #print "<option value='Control Ops'>Control Ops</option>";
                       #print "</select>";
                       #print "</td>";
                       #print "</tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       #print "</tr>";
                       #print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       #print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Search\" onclick=\"formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'update_activity_submit')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     #$timecarduser = $session->param("timecard_user");
     #$timecarddate = $session->param("singledayField");
     $activity_id = $session->param("update_activity_id");

     $session->clear();
     $session->param(usr=>$myname);
     $session->param(update_activity_id=>$activity_id);
     #$session->param(singledayField=>$timecarddate);
     $session->param(action=>'update_activity_db_update');



     %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");

    if($timecarddate=~/(\d+)-(.*)-(\d+)/)
    {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


     &header($myname);
                        print qq~

                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"planned_start_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        new JsDatePick({
                        	useMode:2,
                        	target:"planned_end_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"actual_end_date",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>

                        <script>

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }

                        
                        function form_validate()
                        {

                          activity_planned_manhrs = document.getElementById("activity_planned_manhrs").value;
                          planned_start_date = document.getElementById("planned_start_date").value;
                          planned_end_date = document.getElementById("planned_end_date").value;



                          if(!activity_planned_manhrs)
                          {
                            alert("Please enter the Planned Man Hours for this Activity");
                            return(false);
                          }
                          if(!planned_start_date)
                          {
                            alert("Please enter the Planned Start Date");
                            return(false);
                          }
                          if(!planned_end_date)
                          {
                            alert("Please enter the Planned End Date");
                            return(false);
                          }
                         }
                        


                        </script>
                        ~;
                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      ~;

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("SELECT a.activity_type,a.activity_status,a.activity_priority,a.activity_reqemail,a.activity_desc,a.activity_comments,b.activity_owner,b.activity_planned_manhrs,b.activity_planned_start_date,b.activity_planned_end_date FROM activities a, activity_details b where a.activity_id= '$activity_id' and a.activity_id=b.id ;");
                      $sth->execute() || die "$DBI::errstr\n";
                      my $task_count =  0;
                      while (@resultset = $sth->fetchrow_array)
                      {
                       $activity_type = $resultset[0];
                       $activity_status = $resultset[1];
                       $activity_priority = $resultset[2];
                       $activity_reqemail = $resultset[3];
                       $activity_desc = $resultset[4];
                       $activity_comments = $resultset[5];
                       $activity_owner = $resultset[6];
                       $activity_planned_manhrs = $resultset[7];
                       $activity_planed_start_date = $resultset[8];
                       $activity_planed_end_date = $resultset[9];
                      }
                      $sth->finish();
                      $dbh->disconnect();
                      
                      print "<input type=hidden name=hidden_activity_status id=hidden_activity_status value='$activity_status'>";
                      
                      if ($activity_status eq "Unassigned")
                      {
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Edit Activty Details : </th>";
                        print "</table>";
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Activty Non-Editable Details : </th>";
                        print "</table>";
                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                        print "<tr><td width=200 class='TableCellText' >Activity ID :</td><td class='TableCellText' >$activity_id</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Type :</td><td class='TableCellText' >$activity_type</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Status :</td><td class='TableCellText' >$activity_status</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Priority :</td><td class='TableCellText' >$activity_priority</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText' >$activity_reqemail</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Desc :</td><td class='TableCellText' >$activity_desc</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Comments :</td><td class='TableCellText' >$activity_comments</td></tr>";
                        print "</table>";
                       
  
  
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=\"100%\">Activity Editable Details :</th>";
                        print "</table>";
  
                        print "<table width=87% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                        print "<tr class='TableColumnHeader'>";
                        print "<td>Activity Owner</td>";
                        #print "<td>Planned Man Hr</td>";
                        print "<td>Activity Planned Start Date</td>";
                        #print "<td>Activity Planned End Date</td>";
                        print "</tr>";


                           getsubordinates($myname);
                           push(@final_sub_list,$myname);


                              print "<tr>";
                              print "<td>";
                              print "<select name=activity_owner>";

                              foreach $name(@final_sub_list)
                              {
                                print "<option value='$name'>$name</option>";
                              }
                              print "</select>";
                              print "</td>";

                              #print "<td><input type=text name=activity_planned_manhrs id=activity_planned_manhrs size=12></td>";


                           print "<td class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text name=planned_start_date id=planned_start_date size=12></div></td>";
                           #print "<td class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text name=planned_end_date id=planned_end_date size=12></div></td>";

                           print "</tr>";
                           print "</table>";
                           print qq~
                           <input type=hidden name=hidden_totaltasks id=hidden_totaltasks value="$task_count">
                           <table width=87%  border='0' cellpadding='3'>
                           <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"UPDATE\" onclick=\"return form_validate()\"/></td>
                           <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                           </tr>
                           </table>
                           </form>
                           </div>

                         ~;
                      }
                      elsif(($activity_status eq "In Progress") and ($activity_owner eq $myname))
                      {

                        @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
                        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
                       ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
                        $year = 1900 + $yearOffset;
                        $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;
                    
                    
                        $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
                        $month = $month + 1;
                    
                    
                    
                         if($month=~/^\d$/)
                         {
                          $month = "0" . $month;
                         }
                         if($dayOfMonth=~/^\d$/)
                         {
                          $dayOfMonth = "0" . $dayOfMonth;
                          }
                    
                    
                    
                        $today_date = $year . "-". $month . "-" . $dayOfMonth;


                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Edit Activty Details : </th>";
                        print "</table>";
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Activty Non-Editable Details : </th>";
                        print "</table>";
                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                        print "<tr><td width=200 class='TableCellText' >Activity ID :</td><td class='TableCellText' >$activity_id</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Type :</td><td class='TableCellText' >$activity_type</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Owner :</td><td class='TableCellText' >$activity_owner</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Priority :</td><td class='TableCellText' >$activity_priority</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText' >$activity_reqemail</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Planned Man Hrs :</td><td class='TableCellText' >$activity_planned_manhrs</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Desc :</td><td class='TableCellText' >$activity_desc</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Comments :</td><td class='TableCellText' >$activity_comments</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Planned Start Date :</td><td class='TableCellText' >$activity_planed_start_date</td></tr>";
                        print "<tr><td width=200 class='TableCellText' >Activity Planned End Date  :</td><td class='TableCellText' >$activity_planed_end_date</td></tr>";
                        print "</table>";


  
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=\"100%\">Activity Editable Details :</th>";
                        print "</table>";
                      
                        print "<table width=87% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                        print "<tr class='TableColumnHeader'>";
                        print "<td>Activity Status To</td>";
                        print "<td>Activity Actual End Date</td>";
                        print "</tr>";
                        print "<tr>";
                        print "<td>";
                        print "<select name=updated_activity_status>";
                        print "<option value='Completed'>Completed</option>";
                        print "</select>";
                        print "</td>";
  
                        print qq~
                        <td class='TableCellText'><input type=text readonly=readonly name=actual_end_date id=actual_end_date size=12 value='$today_date'></td>
                        </tr>
                        </table>
                        <input type=hidden name=hidden_totaltasks id=hidden_totaltasks value="$task_count">
                           <table width=87%  border='0' cellpadding='3'>
                           <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Update\" onclick=\" return formvalidate()\"/></td>
                           <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                           </tr>
                           </table>
                           </form>
                           </div>
                        ~;

                      }
                      elsif(($activity_status eq "In Progress") and ($activity_owner ne $myname))
                      {

                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Edit Activty Details : </th>";
                        print "</table>";
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<tr><td class='TableCellText' >Activity Having ID $activity_id is assigned to $activity_owner. You can only update activities assigned to you.</td></tr>";
                        print "</table>";

                      }
                      elsif($activity_status eq "Assigned")
                      {

                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Edit Activty Details : </th>";
                        print "</table>";
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<tr><td class='TableCellText' >Activity Having ID $activity_id is in 'Assigned' status. Only activities with status 'Unassigned' or 'In Progress' can be updated</td></tr>";
                        print "</table>";

                      }
                      elsif($activity_status eq "Planned")
                      {

                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<th class='TableColumnHeader' width=100% >Edit Activty Details : </th>";
                        print "</table>";
                        print "<table width=87%  border='0' cellpadding='3'>";
                        print "<tr><td class='TableCellText' >Activity Having ID $activity_id is in 'Planned' status. Only activities with status 'Unassigned' or 'In Progress' can be updated</td></tr>";
                        print "</table>";

                      }
                      elsif($activity_status eq "Completed")
                      {
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Update Activity Status</th>";
                         print "<tr><td class='TableCellText' >Activity Having ID $activity_id is already completed</td></tr>";
                         print "</table>";
                      
                      }



                      &footer();

}
elsif($session->param('action') eq 'update_activity_db_update')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    my $activity_status = $session->param("hidden_activity_status");
    my $activity_id = $session->param("update_activity_id");

    &header($myname);



                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                         %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");

                      if($activity_status eq "Unassigned")
                      {
                         my $activity_owner = $session->param("activity_owner");
                         my $activity_planned_start_date = $session->param("planned_start_date");
                         my $activity_planned_end_date = $session->param("planned_end_date");
                         my $activity_planned_manhrs = $session->param("activity_planned_manhrs");

                          if($activity_planned_start_date=~/(\d+)-(.*)-(\d+)/)
                          {
                            $today = $1;
                            $tomonth_alphabetic = $2;
                            $tomonth = $months{$tomonth_alphabetic};
                            $toyear = $3;
                            $activity_planned_start_date = $toyear . "-" . $tomonth . "-" .  $today;
                          }
                          if($activity_planned_end_date=~/(\d+)-(.*)-(\d+)/)
                          {
                            $today = $1;
                            $tomonth_alphabetic = $2;
                            $tomonth = $months{$tomonth_alphabetic};
                            $toyear = $3;
                            $activity_planned_end_date = $toyear . "-" . $tomonth . "-" .  $today;
                          }


                          print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                          print "<th class='TableColumnHeader' width=\"100%\">Update Activity Status [$activity_owner][$activity_planned_start_date] [$activity_planned_end_date]</th>";

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            #my $sth = $dbh->prepare("UPDATE activity_details SET activity_owner='$activity_owner',activity_planned_start_date='$activity_planned_start_date',activity_planned_end_date='$activity_planned_end_date',activity_planned_manhrs='$activity_planned_manhrs' WHERE id='$activity_id';");
                            my $sth = $dbh->prepare("UPDATE activity_details SET activity_owner='$activity_owner',activity_planned_start_date='$activity_planned_start_date' WHERE id='$activity_id';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("UPDATE activities SET activity_status='Assigned' WHERE activity_id='$activity_id';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();

#                            mail_activity_status_updates($activity_id);

                          print "<tr><td class='TableCellText' >Activity Having ID $activity_id Update Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                          print "</table>";

                       print qq~
                       </div>
                       ~;
                      }
                      elsif($activity_status eq "In Progress")
                      {

                        my $updated_activity_status = $session->param("updated_activity_status");
                        my $activity_actual_end_date = $session->param("actual_end_date");


                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("select count(task_id) from task_global where activity_id = '$activity_id' and task_status in ('Planned','In Progress');");
                        $sth->execute() || die "$DBI::errstr\n";
                        my $task_count =  0;
                        while ($resultset = $sth->fetchrow_array)
                        {
                         $number_of_in_progress_tasks = $resultset;
                        }
                        $sth->finish();
                        $dbh->disconnect();

                        if($number_of_in_progress_tasks > 0)
                        {
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Update Activity Status</th>";
                         print "<tr><td class='TableCellText' >The below tasks are still not Completed. Hence this activity cannot be completed</td></tr>";
                         print "</table>";
                         
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">In complete Tasks Under Activity</th>";
                         print "<tr class='TableColumnHeader'>";
                         print "<td>Task Cat</td>";
                         print "<td>Task Comments</td>";
                         print "<td>Task Projname</td>";
                         print "<td>Tast Date</td>";
                         print "<td>Task Priority</td>";
                         print "<td>Task Assignee</td>";
                         print "<td>Task Status</td>";
                         print "</tr>";

                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("select task_cat,task_comments,task_projname,task_date,task_priority,task_assigned_by,task_status from task_global where activity_id = '$activity_id' and task_status in ('Planned','In Progress');");
                         $sth->execute() || die "$DBI::errstr\n";
                         my $task_count =  0;
                         while (@resultset = $sth->fetchrow_array)
                         {
                          $task_cat = $resultset[0];
                          $task_comments = $resultset[1];
                          $task_projname = $resultset[2];
                          $task_date = $resultset[3];
                          $task_priority = $resultset[4];
                          $task_assigned = $resultset[5];
                          $task_status = $resultset[6];
                         
                          print "<tr class='TableCellText'>";
                          print "<td>$task_cat</td>";
                          print "<td>$task_comments</td>";
                          print "<td>$task_projname</td>";
                          print "<td>$task_date</td>";
                          print "<td>$task_priority</td>";
                          print "<td>$task_assigned</td>";
                          print "<td>$task_status</td>";
                          print "</tr>";

                         }
                         $sth->finish();
                         $dbh->disconnect();

                         print "</table>";
                         


                        }
                        else
                        {

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("UPDATE activities SET activity_status='Completed' WHERE activity_id='$activity_id';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("UPDATE activity_details SET activity_actual_end_date='$activity_actual_end_date' WHERE id='$activity_id';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();

#                            mail_activity_status_updates($activity_id);

                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Update Activity Status</th>";
                         print "<tr><td class='TableCellText' >Activity Having ID $activity_id Update Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                         print "</table>";

                        }


                      }

                       &footer();
}
elsif($session->param('action') eq 'view_daily_unassigned_activity')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');
    $session->param(action=>'display_taskbyactivityid');



#     my $activity_type = $session->param("searched_activity_type");
#     my $activity_status = $session->param("searched_activity_status");
#     my $activity_priority = $session->param("searched_activity_priority");
#     my $searched_date = $session->param("singledayField");




   my $todays_date = "";
    $todays_date = gettodaysdate();

   print qq~
   <div id="bodyColumn"><div id="contentBox"><div class="section">
  <div align="center">
  <div></div>
  <div><p></p><p></p></div>
  <form id=timecardentry action="display_workload.pl" method="post">
  <table width=100% border=0 cellpadding=3 width=350px>
  <th class='TableColumnHeader' width=100% >Unassigned Activity Details as of $todays_date</th>
  </table>

  <table width=87% border=0 cellpadding=3 width=350px border=1>
   <tr>
   </tr>
  </table>
  <table width=100% border=0 cellpadding=3 width=350px border=1>
  <tr class='TableColumnHeader' ><td>Activity ID</td><td>Update</td><td>Add Resource</td><td>Activity Type</td><td>Status</td><td>Priority</td><td>Requested By</td><td>Description</td><td>Comments</td></tr>
    ~;



    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.activity_id,a.activity_type,a.activity_status,a.activity_priority,a.activity_reqemail,a.activity_desc,a.activity_comments from activities a  where a.activity_status='Unassigned';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
      $activity_id = $resultset[0];
      $activity_type = $resultset[1];
      $activity_status = $resultset[2];
      $activity_priority = $resultset[3];
      $activity_reqemail = $resultset[4];
      $activity_desc = $resultset[5];
      $activity_comments = $resultset[6];

        print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?activityid=$activity_id'>$activity_id</a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=update_activity_submit&update_activity_id=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/pencil_icon.png'></a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=activity_resourcing_submit&activity_id_resourcing=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/assign_resource.png'></a></td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_priority</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText'>$activity_comments</td></tr>";

    }
   $sth->finish();
   $dbh->disconnect();



  #####
    print "</table>";
    print "</div>";
    print "<div></div>";
    print "<div><p></p></div>";
    print "<iframe name='iframe_a' align=center style=height:150px;width:100%;  frameborder=0 scrolling=auto ></iframe>";
    print "</form>";
    



    print qq~
    
     </form>
     </div>
     ~;

    &footer();
                      ####
                      #print "<input type=hidden name=resourcename id=resourcename value='$search_users_string'>";
                      #print qq~




#                        print " <table width=87%  border='0' cellpadding='3'>";
#                        print "<th class='TableColumnHeader' width='100%'></th>";
#                        print "<tr><td  border=0 cellpadding=3><input type=submit class=submitButtonEnable1 value='View Workload' onclick='formvalidate()' /></td>";
#                        print "<th class='TableColumnHeader' width='100'></th>";
#                        print "</table>";
#                        print "</form>";
#                        print "</div>";
#                        &footer();
}
elsif($cgi->param('action') eq 'search_activity')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'activity_search_results');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {


                           singledayField_val = document.getElementById("singledayField").value;
                           activity_id = document.getElementById("searched_activity_id").value;
                           searched_activity_owner = document.getElementById("searched_activity_owner").value;

                           if((!singledayField_val) && (!activity_id) && (!searched_activity_owner))
                           {
                            alert("Please enter either activity id or date or activity owner's username to retrieve activity");
                            return(false);
                           }

                        }
                        </script>
                        ~;

                        getsubordinates($myname);
                        push(@final_sub_list,$myname);
                        my $final_sub_list_ref = \@final_sub_list;
                        my $hashref = getfullnametitle($final_sub_list_ref);
                        my %user_details = %$hashref;


                       @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
                        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
                       ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
                        $year = 1900 + $yearOffset;
                        $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;


                        my $activity_id = $session->param("searched_activity_id");
                        my $activity_owner = $session->param("searched_activity_owner");
                        my $activity_type = $session->param("searched_activity_type");
                        my $activity_status = $session->param("searched_activity_status");
                        my $activity_priority = $session->param("searched_activity_priority");

                        if($activity_type eq "")
                        {
                          $activity_type =  "%";
                        }
                        elsif($activity_status eq "")
                        {
                          $activity_status =  "%";
                        }
                        elsif($activity_priority eq "")
                        {
                          $activity_priority =  "%";
                        }
                        elsif($activity_id eq "")
                        {
                          $activity_id =  "%";
                        }
                        elsif($activity_owner eq "")
                        {
                          $activity_owner = "%";
                        }

                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Activity Lookup : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";

                       #print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td class='TableCellText'><input type=text name=searched_activity_id id=searched_activity_id size=50></td></tr>";
                       
                       print "<tr>";
                       print "<td width=300 class='TableCellText' >Activity Owner :</td>";
                       print "<td class='TableCellText'>";
                       print "<select name=searched_activity_owner id=searched_activity_owner>";
                       print "<option value=''></option>";
                       foreach $key (keys %user_details)
                       {
                         print "<option value=$key>$user_details{$key}</option>";
                        }
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Type :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=searched_activity_type >";
                       print "<option value=''></option>";
                       print "<option value='Alpha Testing'>Alpha Testing</option>";
                       print "<option value='Production Testing'>Production Testing</option>";
                       print "<option value='Online Testing'>Online Testing</option>";
                       print "<option value='CSD Issue Checking'>CSD Issue Checking</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td width=300 class='TableCellText' >Activity Status :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=searched_activity_status >";
                       print "<option value=''></option>";
                       print "<option value='Unassigned'>Unassigned</option>";
                       print "<option value='Planned'>Planned</option>";
                       print "<option value='In Progress'>In Progress</option>";
                       print "<option value='Deferred'>Deferred</option>";
                       print "<option value='Completed'>Completed</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";


                       print "<tr><td width=300 class='TableCellText' >Activity Priority :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=searched_activity_priority >";
                       print "<option value=''></option>";
                       print "<option value='Low'>Low</option>";
                       print "<option value='Medium'>Medium</option>";
                       print "<option value='High'>High</option>";
                       print "<option value='Urgent'>Urgent</option>";
                       print "</select>";
                       print "</td>";
                       print "</tr>";

                       print "<tr><td width=300 class='TableCellText' >Activity Requestor Email :</td><td class='TableCellText'><input type=text name=searched_activity_reqemail id=searched_activity_reqemail size=25></td></tr>";
                       print "<tr><td width=300 class='TableCellText'>Search Date</td><td class='TableCellText'><div id=div_form_single style='visibility:visible'><input type=text name=singledayField id=singledayField size=12></div></td></tr>";
                       #print "<tr><td width=300 class='TableCellText' >Activity Notified Using :</td>";
                       #print "<td class='TableCellText' >";
                       #print "<select name=activity_notified_using >";
                       #print "<option value='EMail'>EMail</option>";
                       #print "<option value='Mantis'>Mantis</option>";
                       #print "<option value='Control Ops'>Control Ops</option>";
                       #print "</select>";
                       #print "</td>";
                       #print "</tr>";

                       #print "<tr><td width=300 class='TableCellText' >Activity Desc :</td><td><input type=text name=activity_desc id=activity_desc size=75></td></tr>";

# 
#                        print "<tr><td width=300 class='TableCellText' >Activity Assigned To :</td>";
#                        print "<td>";
#                        print "<select name=activity_assignedto >";
# 
#                        foreach (@names)
#                        {
#                         print "<option value=$_>$_</option>";
#                        }
#                        print "</select>";
#                        print "</td></tr>";
#                        print "<tr><td width=300 class='TableCellText' >Activity Man Hours :</td><td><input type=text name=activity_manhr id=activity_manhr size=25></td></tr>";
#                        print "<tr>";

                       #print "</tr>";
                       #print "<tr><td width=\"300\" class='TableCellText'>Activity Comments</td><td><input type=text name=activity_comments id=activity_comments size=75></td></tr>";
                       #print "</table>";

                       ####

#                        print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#                        print "<tr>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from>Activity Planned Start Date : </td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>";
#                        print "<td width='125' class='TableCellText'><div id=div_form_duration_to >Activity Planned Completion Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>";
#                        print "</tr>";
#                        print "</table>";




                       print qq~
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Search\" onclick=\"return formvalidate()\"/></td>
                       <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'activity_search_results')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');
    $session->param(action=>'display_taskbyactivityid');

%months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DEC",  "12");


    my $activity_id = $session->param("searched_activity_id");
    my $activity_owner = $session->param("searched_activity_owner");
    my $activity_type = $session->param("searched_activity_type");
    my $activity_status = $session->param("searched_activity_status");
    my $activity_priority = $session->param("searched_activity_priority");
    my $searched_date = $session->param("singledayField");

     if($searched_date=~/(\d+)-(.*)-(\d+)/)
    {
      $day = $1;
      $month_alphabetic = $2;
      $month = $months{$month_alphabetic};
      $year = $3;
      $searched_date = $year . "-" . $month . "-" .  $day;
    }





    if($activity_type eq "")
    {
      $activity_type =  "%";
    }
    
    if($activity_status eq "")
    {
      $activity_status =  "%";
    }
    if($activity_priority eq "")
    {
      $activity_priority =  "%";
    }
    if($searched_date eq "")
    {
      $searched_date = "%";
    }
    if($activity_id eq "")
    {
      $activity_id = "%";
    }
    if($activity_owner eq "")
    {
      $activity_owner = "%";
    }


   

   print qq~
   <div id="bodyColumn"><div id="contentBox"><div class="section">
  <div align="center">
  <div></div>
  <div><p></p><p></p></div>
  <form id=timecardentry action="display_workload.pl" method="post">
  <table width=100% border=0 cellpadding=3 width=350px>
  <th class='TableColumnHeader' width=100% >Activity Lookup Details :[$activity_type][$activity_status][$activity_priority][$searched_date]</th>
  </table>

  <table width=87% border=0 cellpadding=3 width=350px border=1>
   <tr>
   </tr>
  </table>
  <table width=100% border=0 cellpadding=3 width=350px border=1>
  <tr class='TableColumnHeader' ><td>Activity ID</td><td>Update</td><td>Add Resource</td><td>Activity Type</td><td>Status</td><td>Priority</td><td>Requested By</td><td>Description</td><td>Comments</td></tr>
    ~;

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.activity_id,a.activity_type,a.activity_status,a.activity_priority,a.activity_reqemail,a.activity_desc,a.activity_comments from activities a,activity_details b  where a.activity_id=b.id and a.activity_type like '$activity_type' and a.activity_status like '$activity_status' and a.activity_priority like '$activity_priority' and a.activity_reported_date like '$searched_date' and a.activity_id like '$activity_id' and b.activity_owner like '$activity_owner';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
      $activity_id = $resultset[0];
      $activity_type = $resultset[1];
      $activity_status = $resultset[2];
      $activity_priority = $resultset[3];
      $activity_reqemail = $resultset[4];
      $activity_desc = $resultset[5];
      $activity_comments = $resultset[6];

      print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?activityid=$activity_id'>$activity_id</a><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=update_activity_submit&update_activity_id=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/pencil_icon.png'></a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=activity_resourcing_submit&activity_id_resourcing=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/assign_resource.png'></a></td></td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_priority</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText'>$activity_comments</td></tr>";
      #print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?activityid=$activity_id'>$activity_id</a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=update_activity_submit&update_activity_id=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/pencil_icon.png'></a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=activity_resourcing_submit&activity_id_resourcing=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/assign_resource.png'></a></td><td class='TableCellText'>$activity_</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_priority</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText'>$activity_comments</td></tr>";
    }
   $sth->finish();
   $dbh->disconnect();



  #####
    print "</table>";
    print "</div>";
    print "<div></div>";
    print "<div><p></p></div>";
    print "<iframe name='iframe_a' align=center style=height:150px;width:100%;  frameborder=0 scrolling=auto ></iframe>";
    print "</form>";
    &footer();
                      ####
                      #print "<input type=hidden name=resourcename id=resourcename value='$search_users_string'>";
                      #print qq~




#                        print " <table width=87%  border='0' cellpadding='3'>";
#                        print "<th class='TableColumnHeader' width='100%'></th>";
#                        print "<tr><td  border=0 cellpadding=3><input type=submit class=submitButtonEnable1 value='View Workload' onclick='formvalidate()' /></td>";
#                        print "<th class='TableColumnHeader' width='100'></th>";
#                        print "</table>";
#                        print "</form>";
#                        print "</div>";
#                        &footer();
}
elsif($cgi->param('action') eq 'search_milestone')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'milestone_search_results');
     $session->param(usr=>$myname);

     &header($myname);

      getsubordinates($myname);
      push(@final_sub_list,$myname);
      my $final_sub_list_ref = \@final_sub_list;
      my $hashref = getfullnametitle($final_sub_list_ref);
      my %user_details = %$hashref;


     @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
      @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
     ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
      $year = 1900 + $yearOffset;
      $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;


      my $activity_id = $session->param("searched_activity_id");
      my $activity_owner = $session->param("searched_activity_owner");
      my $activity_type = $session->param("searched_activity_type");
      my $activity_status = $session->param("searched_activity_status");
      my $activity_priority = $session->param("searched_activity_priority");

     print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    <form id=timecardentry action="reshome.pl" method="post">
    <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
    <div></div>
    <div><p></p><p></p></div>
    ~;
                       
   print "<table width=87%  border='0' cellpadding='3'>";
   print "<th class='TableColumnHeader' width=100% >Milestone Lookup : </th>";
   print "</table>";
   print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
  
   #print "<tr><td width=300 class='TableCellText' >Activity ID :</td><td><input type=text readonly=readonly name=activity_id id=activity_id value='$curr_activity_id' size=50></td></tr>";

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT goal_id,goal_name FROM goals order by goal_name asc;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
   {
     $goal_id = $resultset[0];
     $goal_name = $resultset[1];
     $goals{$goal_id} = $goal_name;
   }
   $sth->finish();
   $dbh->disconnect();
  
   print "<tr><td width=300 class='TableCellText' >Select the Goal :</td>";
   print "<td class='TableCellText' >";
   print "<select name=milestone_goal >";
   foreach $key (keys %goals)
   {
    print "<option value='$key'>$goals{$key}</option>";
   }
   print "</select>";
   print "</td>";
   print "</tr>";

   print qq~
   <table width=87%  border='0' cellpadding='3'>
   <tr><td class='TableCellText' align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Search\" onclick=\"return formvalidate()\"/></td>
   <td class='TableCellText' align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
   </tr>
   </table>
   </form>
   </div>
   ~;
   &footer();

}
elsif($session->param('action') eq 'milestone_search_results')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    #$session->param(action=>'submit_timecard');
    #$session->param(action=>'display_taskbyactivityid');

%months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DEC",  "12");


    my $goal = $session->param("milestone_goal");



   print qq~
   <div id="bodyColumn"><div id="contentBox"><div class="section">
  <div align="center">
  <div></div>
  <div><p></p><p></p></div>
  <form id=timecardentry action="display_workload.pl" method="post">
  <table width=100% border=0 cellpadding=3 width=350px>
  <th class='TableColumnHeader' width=100% >Milestone Search Results :</th>
  </table>

  <table width=87% border=0 cellpadding=3 width=350px border=1>
   <tr>
   </tr>
  </table>
  <table width=100% border=0 cellpadding=3 width=350px border=1>
  <tr class='TableColumnHeader' ><td>Milestone ID</td><td>Milestone Date</td><td>Comments</td><td>Description</td><td>Requested By</td></tr>
    ~;

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.milestone_id,a.milestone_date,a.milestone_comments,a.milestone_desc,a.milestone_reqemail from milestone a where a.goal_id = '$goal';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
      $milestone_id = $resultset[0];
      $milestone_date = $resultset[1];
      $milestone_comments = $resultset[2];
      $milestone_desc = $resultset[3];
      $milestone_reqemail = $resultset[4];

      print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?activityid=$activity_id'>$milestone_id</a><td class='TableCellText'>$milestone_date</td><td class='TableCellText'>$milestone_comments</td><td class='TableCellText'>$milestone_desc</td><td class='TableCellText'>$milestone_reqemail</td></tr>";
      #print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?activityid=$activity_id'>$activity_id</a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=update_activity_submit&update_activity_id=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/pencil_icon.png'></a></td><td class='TableCellText'><a href='http://127.0.0.1/webapp/reshome.pl?action=activity_resourcing_submit&activity_id_resourcing=$activity_id'><img align=center src='http://127.0.0.1/webapp/images/assign_resource.png'></a></td><td class='TableCellText'>$activity_</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_priority</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText'>$activity_comments</td></tr>";
    }
   $sth->finish();
   $dbh->disconnect();



  #####
    print "</table>";
    print "</div>";
    print "<div></div>";
    print "<div><p></p></div>";
    print "<iframe name='iframe_a' align=center style=height:150px;width:100%;  frameborder=0 scrolling=auto ></iframe>";
    print "</form>";
    &footer();
}

elsif($session->param("action") eq "display_taskbyactivityid")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    #$myname = $session->param("usr");
    $activityid = $session->param("activityid");


    %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");



   #  if($myclickdate=~/(\d+)-(.*)-(\d+)/)
#    {
#       $today = $1;
#       $tomonth_alphabetic = $2;
#       $tomonth = $months{$tomonth_alphabetic};
#       $toyear = $3;
# 
#     }
# 
#     $date = $toyear . "-" . $tomonth . "-" .  $today;

    my @activity_workers = ();
    print "<html>\n";
    print "<head>\n";
    print "<meta http-equiv=Content-Type content=text/html; charset=windows-1251>";
    print "<title>Task Linked to Activity </title>\n";
    print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/my.css type=text/css>\n";
    print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/jsDatePick_ltr.min.css>\n";
    print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/site.css type=text/css>\n";
    print "<style type=\"text/css\" media=print></style></head>\n";
    
    
    print "<table width=100%  border='0' cellpadding='3'>";
    print "<th class='TableColumnHeader' width=100%>Details for Activity with ID : <b>$activityid</b> </th>";
    print "</table>";
    
#  print "<table width=100%  border='0' cellpadding='3'>";
#     print "<th class='TableColumnHeader' width=100%>Resources Working on Activity with ID : <b>$activity_id</b> </th>";
#     print "</table>";
#     print "<table width=100%  border='0' cellpadding='3'>";
#     print "<tr class='TableColumnHeader'><td>Resources Working On This Activity</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select DISTINCT(worker_username) from activity_workers where activity_id='$activityid';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     push(@activity_workers,$resultset[0]);

    }
#    print "</table>";

$sth->finish();
$dbh->disconnect();




    map {s/$_/$_,/g} @activity_workers;


    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT ROUND(SUM((task_manhour)/60),2) FROM task_global WHERE activity_id='$activityid';");
    $sth->execute() || die "$DBI::errstr\n";
    while ($resultset = $sth->fetchrow_array)
    {
     $activity_actual_manhr = $resultset;
    }
    $sth->finish();
    $dbh->disconnect();

    print "<table width=100%  border='0' cellpadding='3'>";
    print "<tr class='TableColumnHeader'><td>Owner</td><td>Resources</td><td>Planned Man Hrs</td><td>Actual Man Hrs</td><td>Planned Start Dt</td><td>Planned End Dt</td><td>Actual Start Dt</td><td>Actual End Dt</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select activity_owner,activity_planned_manhrs,activity_planned_start_date,activity_planned_end_date,activity_actual_start_date,activity_actual_end_date from activity_details where id='$activityid';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     my $activity_owner = $resultset[0];
     my $activity_planned_manhrs = $resultset[1];
     my $activity_planned_start_date = $resultset[2];
     my $activity_planned_end_date = $resultset[3];
     my $activity_actual_start_date = $resultset[4];
     my $activity_actual_end_date = $resultset[5];

     print "<tr><td class='TableCellText'>$activity_owner</td><td class='TableCellText'>@activity_workers</td><td class='TableCellText'>$activity_planned_manhrs</td><td class='TableCellText'>$activity_actual_manhr</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_actual_start_date</td><td class='TableCellText'>$activity_actual_end_date</td></tr>";
    }
    print "</table>";
    $sth->finish();
    $dbh->disconnect();


    print "<div></div><div><p></p><p></p></div>";
    print "<table width=100%  border='0' cellpadding='3'>";
    print "<th class='TableColumnHeader' width=100%>Task Under Activity with [ID] : <b>$activityid</b> </th>";
    print "</table>";
    print "<table width=100%  border='0' cellpadding='3'>";
    print "<tr class='TableColumnHeader'><td>Task Category</td><td>Task Comments</td><td>Project</td><td>Task Creation Date</td><td>Task Duration</td><td>Task Priority</td><td>Task By</td><td>Task Status</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select task_cat,task_comments,task_projname,task_manhour,task_priority,task_assigned_by,task_status,task_date from task_global where activity_id='$activityid';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     my $task_cat = $resultset[0];
     my $task_comments = $resultset[1];
     my $task_projname = $resultset[2];
     my $task_manhour = $resultset[3];
     my $task_priority = $resultset[4];
     my $task_assignedby = $resultset[5];
     my $task_status = $resultset[6];
     my $task_date = $resultset[7];

     $task_manhour = ($task_manhour/60);
     print "<tr><td class='TableCellText'>$task_cat</td><td class='TableCellText'>$task_comments</td><td class='TableCellText'>$task_projname</td><td class='TableCellText'>$task_date</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_priority</td><td class='TableCellText'>$task_assignedby</td><td class='TableCellText'>$task_status</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();
    print "</table>";
    print "</head>";
    print "</html>";
}

elsif($cgi->param('action') eq 'view_usercalendar')
{
     


     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();

     $session->param(usr=>$myname);

     getsubordinates($myname);
     push(@final_sub_list,$myname);
     #my $final_sub_list_ref = \@final_sub_list;




     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          resourcename_val = document.getElementById("resourcename").value;
                          alert('test')
                          alert('Resourcename is '+resourcename_val);

                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;



                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Leave Calendar of <font color='green'>$myname</font>'s Organization : </th>";
                       print "</table>";

                       print "<table width=87% cellpadding=3 width=350px border=0>";
                       #print "<tr><td class='TableCellText' >Username :</td><td class='TableCellText' >$resource_name</td></tr>";
                       #print "<tr><td class='TableCellText' >From Date :</td><td class='TableCellText' >$leave_from_date</td></tr>";
                       #print "<tr><td class='TableCellText' >To Date :</td><td class='TableCellText' >$leave_to_date</td></tr>";
                       #print "<tr><td class='TableCellText' >Leave Type :</td><td class='TableCellText' >$leave_type</td></tr>";
                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       print "<tr><td class='TableColumnHeader'>Resource Name</td><td class='TableColumnHeader'>Leave From Date</td><td class='TableColumnHeader'>Leave To Date</td><td class='TableColumnHeader'>Leave Type</td><td class='TableColumnHeader'>Leave Justification</td></tr>";
                       my $row_count=0;
                       foreach $name (@final_sub_list)
                       {


                          my $sth = $dbh->prepare("SELECT leave_fromdate,leave_todate,leave_type,leave_justification FROM user_leaves WHERE username='$name'");
                          $sth->execute() || die "$DBI::errstr\n";
    
                          while (@resultset = $sth->fetchrow_array)
                          {
                           $row_count++;
                           my $leave_fromdate = $resultset[0];
                           my $leave_todate = $resultset[1];
                           my $leave_type = $resultset[2];
                           my $leave_justification = $resultset[3];
                           print "<tr><td class='TableCellText'>$name</td><td class='TableCellText'>$leave_fromdate</td><td class='TableCellText'>$leave_todate</td><td class='TableCellText'>$leave_type</td><td class='TableCellText'>$leave_justification</td></tr>";
                          }
                          $sth->finish();
                       }

                      $dbh->disconnect();
                      
                      if ($row_count==0)
                      {
                        print  "<tr>";
                        print  "<td colspan=9 class=TableCellText>None</td>";
                        print  "</tr>";
                      }

                      print "</table>";
                      &footer();

}
elsif($cgi->param('action') eq 'resource_lookup')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(action=>'resource_lookup_submit');
     $session->param(usr=>$myname);

     &header($myname);

                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script>
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {

                          resourcename_val = document.getElementById("resourcename").value;
                          alert('test')
                          alert('Resourcename is '+resourcename_val);

                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;


                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      ~;
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=100% >Resource Lookup : </th>";
                       print "</table>";
                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print "<tr>";
                       print "<td width=535 class='TableCellText' >Looking For :</td>";
                       print "<td class='TableCellText' >";
                       print "<select name=resource_lookup_type >";

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT DISTINCT(user_role) FROM user_roles;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                        {
                          print "<option value='$resultset[0]'>$resultset[0]</option>";
                        }
                       $sth->finish();
                       $dbh->disconnect();
                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";

                       ####

                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print "<tr>";
                       print "<td width=535 class='TableCellText' >Having B.U Specific Skillset :</td>";
                       print "<td class='TableCellText' >";
                       print "<select multiple name=bu_specific_skillset >";

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT DISTINCT(user_skillset_desc) FROM user_skillset WHERE user_skillset_type LIKE '%BU_DEPENDENT%';");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                        {
                          print "<option value='$resultset[0]'>$resultset[0]</option>";
                        }
                       $sth->finish();
                       $dbh->disconnect();
                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";

                       ####

                       ####

                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print "<tr>";
                       print "<td width=535 class='TableCellText' >Having B.U Independent Skillset :</td>";
                       print "<td class='TableCellText' >";
                       print "<select multiple name=bu_independent_skillset >";

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT DISTINCT(user_skillset_desc) FROM user_skillset WHERE user_skillset_type LIKE '%BU_INDEPENDENT%';");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                        {
                          print "<option value='$resultset[0]'>$resultset[0]</option>";
                        }
                       $sth->finish();
                       $dbh->disconnect();
                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";

                       ####

                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print "<tr>";
                       print "<td width=535 class='TableCellText' >Worked On :</td>";
                       print "<td class='TableCellText' >";
                       print "<select multiple name=resource_lookup_projexp >";

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT DISTINCT(projname) FROM projects;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                        {
                          print "<option value='$resultset[0]'>$resultset[0]</option>";
                        }
                       $sth->finish();
                       $dbh->disconnect();
                       print "</select>";
                       print "</td>";
                       print "</tr>";
                       print "</table>";

                       ###

                       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                       print qq~
                       <tr>
                       <td width=\"125\" class='TableCellText'>Needed From</td>
                       <td width=125 class='TableCellText'></td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_from>From Date : </td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_from_dialog ><input type=text name=durationfromField id=durationfromField size=12></td>
                       <td width=\"125\" class='TableCellText'><div id=div_form_duration_to >To Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog ><input type=text name=durationtoField id=durationtoField size=12></td></div>
                       </tr>
                       </table>



                        <input type=hidden name=hidden_tasks id=hidden_tasks value="$tasksjoined">
                        <input type=hidden name=hidden_projects id=hidden_projects value="$projectsjoined">

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Search\" onclick=\"formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"ClearS\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'resource_lookup_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);

    #$session->clear();
    #$session->param(usr=>$myname);
    $session->param(action=>'submit_timecard');



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                      <th class='TableColumnHeader' width=100% >Resource Lookup Details :</th>
                      </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_type = $session->param("resource_lookup_type");

                      my $bu_specific_skillset_arr_ref = $session->param("bu_specific_skillset");
                      my @bu_specific_skillset = @$bu_specific_skillset_arr_ref;

                      $skillset_count = scalar(@bu_specific_skillset);

                      if($skillset_count>0)
                      {
                      }
                      else
                      {
                       @bu_specific_skillset = ();
                       $bu_specific_skill = $session->param("bu_specific_skillset");
                       push(@bu_specific_skillset,$bu_specific_skill);
                      }



                      my $bu_independent_skillset_arr_ref = $session->param("bu_independent_skillset");
                      my @bu_independent_skillset = @$bu_independent_skillset_arr_ref;

                      $skillset_count = scalar(@bu_independent_skillset);

                      if($skillset_count>0)
                      {
                      }
                      else
                      {
                       @bu_independent_skillset = ();
                       $bu_independent_skill = $session->param("bu_independent_skillset");
                       push(@bu_independent_skillset,$bu_independent_skill);
                      }


                      my $resource_project_exp_arr_ref = $session->param("resource_lookup_projexp");
                      my @resource_project_exp = @$resource_project_exp_arr_ref;

                      $project_count = scalar(@resource_project_exp);

                      if($project_count>0)
                      {
                      }
                      else
                      {
                       @resource_project_exp = ();
                       $project_name = $session->param("resource_lookup_projexp");
                       push(@resource_project_exp,$project_name);
                      }


                      my $resource_from_date_need = $session->param("durationfromField");

                      my $resource_to_date_need = $session->param("durationtoField");


                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Search Criteria :</th>";
                      print "</table>";
                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<tr><td class='TableCellText' >Looking For :</td><td class='TableCellText' >$resource_type</td></tr>";

                      @temp = @bu_specific_skillset;
                      map {s/$_/[$_]/g} @temp;

                      print "<tr><td class='TableCellText' >Having B.U. Specific Skillset :</td><td class='TableCellText' >@temp</td></tr>";
                      @temp = undef;

                      @temp = @bu_independent_skillset;
                      map {s/$_/[$_]/g} @temp;
                      print "<tr><td class='TableCellText' >Having B.U. Independent Skillset :</td><td class='TableCellText' >@temp</td></tr>";
                      @temp = undef;

                      @temp = @resource_project_exp;
                      map {s/$_/[$_]/g} @temp;
                      print "<tr><td class='TableCellText' >Worked On Projects :</td><td class='TableCellText' >@temp</td></tr>";
                      @temp = undef;

                      print "<tr><td class='TableCellText' >Availablity Timelines :</td><td class='TableCellText' >$resource_from_date_need - $resource_to_date_need</td></tr>";

                      print "</table>";

                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<th class='TableColumnHeader' width=100% >B.U Specific Skillset Search Results :</th>";
                      print "</table>";
                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<tr>";
                      print "<td width=535 class='TableCellText' >Resource Name</td><td width=535 class='TableCellText' >Skillset</td>";
                      print "</tr>";

                      my %search_result_names = ();

                      my $query_String = "SELECT DISTINCT(user_name),user_skillset_desc FROM user_skillset WHERE user_skillset_desc IN (";
                      foreach $skillset (@bu_specific_skillset)
                      {
                       $query_String = $query_String . "'" . $skillset . "',";
                      }
                      chop($query_String);
                      $query_String = $query_String .  ") AND user_skillset_type LIKE '%BU_DEPENDENT%' ORDER by user_name;";



                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare($query_String);

                      $sth->execute() || die "$DBI::errstr\n";
                      while (@resultset = $sth->fetchrow_array)
                      {
                         if(not exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = 1;
                          $search_result_names{$resultset[0]} = "[" . $resultset[1] ."]";
                         }
                         elsif(exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} + 1;
                          $search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} . "[" . $resultset[1] ."]";
                         }
                         my $name = getfullname($resultset[0]);
                         print "<tr><td class='TableCellText'>$name</td><td class='TableCellText'>$resultset[1]</td></tr>";
                      }
                      $sth->finish();
                      $dbh->disconnect();
                      print "</table>";


                      ####
                      my $query_String = "";

                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<th class='TableColumnHeader' width=100% >B.U Independent Skillset Search Results :</th>";
                      print "</table>";
                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<tr>";
                      print "<td class='TableCellText' >Resource Name</td><td class='TableCellText' >Skillset</td>";
                      print "</tr>";

                      my $query_String = "SELECT DISTINCT(user_name),user_skillset_desc FROM user_skillset WHERE user_skillset_desc IN (";
                      foreach $skillset (@bu_independent_skillset)
                      {
                       
                       $query_String = $query_String . "'" . $skillset . "',";
                      }
                      chop($query_String);
                      $query_String = $query_String .  ") AND user_skillset_type LIKE '%BU_INDEPENDENT%' ORDER by user_name;";

                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare($query_String);

                      $sth->execute() || die "$DBI::errstr\n";
                      while (@resultset = $sth->fetchrow_array)
                      {
                        if(not exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = 1;
                           $search_result_names{$resultset[0]} = "[" . $resultset[1] ."]";
                         }
                         elsif(exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} + 1;
                          $search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} . "[" . $resultset[1] ."]";
                         }

                         my $name = getfullname($resultset[0]);
                         print "<tr><td class='TableCellText'>$name</td><td class='TableCellText'>$resultset[1]</td></tr>";
                      }
                      $sth->finish();
                      $dbh->disconnect();
                      print "</table>";

                      ####
                      
                      my $query_String = "";

                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<th class='TableColumnHeader' width=100% >Project Exp Search Results :</th>";
                      print "</table>";
                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<tr>";
                      print "<td class='TableCellText' >Resource Name</td><td class='TableCellText' >Project Name</td>";
                      print "</tr>";

                      my $query_String = "SELECT DISTINCT(task_username),task_projname FROM task_global WHERE task_projname IN (";
                      foreach $skillset (@resource_project_exp)
                      {
                       
                       $query_String = $query_String . "'" . $skillset . "',";
                      }
                      chop($query_String);
                      $query_String = $query_String .  ") ORDER by task_username;";


                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare($query_String);

                      $sth->execute() || die "$DBI::errstr\n";
                      while (@resultset = $sth->fetchrow_array)
                      {
                        if(not exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = 1;
                          $search_result_names{$resultset[0]} = "[" . $resultset[1] ."]";
                         }
                         elsif(exists $search_result_names{$resultset[0]})
                         {
                          #$search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} + 1;
                          $search_result_names{$resultset[0]} = $search_result_names{$resultset[0]} . "[" . $resultset[1] ."]";
                         }

                         my $name = getfullname($resultset[0]);
                         print "<tr><td class='TableCellText'>$name</td><td class='TableCellText'>$resultset[1]</td></tr>";
                      }
                      $sth->finish();
                      $dbh->disconnect();
                      print "</table>";

                      ####
                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<th class='TableColumnHeader' width=100% >Search Results Summary :</th>";
                      print "</table>";
                      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                      print "<tr><td class='TableCellText' >Resource Name</td><td class='TableCellText' >Resource Role</td><td class='TableCellText' >Search Criterion Match Extent</td></tr>";
                      foreach $key (keys %search_result_names)
                      {
                       my $name = getfullname($key);
                       
                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT user_role FROM user_roles WHERE user_name='$key';");
                       $sth->execute() || die "$DBI::errstr\n";
                       my $role = "";
                       while (@resultset = $sth->fetchrow_array)
                       {
                        $role = $role . "[" . $resultset[0] . "]";
                       }
                       $sth->finish();
                       $dbh->disconnect();



                       print "<tr><td class='TableCellText' >$name</td><td class='TableCellText' >$role</td><td class='TableCellText' >$search_result_names{$key}</td></tr>";
                      }
                      print "</table>";
                      
                      
                      my @search_users = (keys %search_result_names);
                      my $search_users_string = join(",",@search_users);
                      print "<input type=hidden name=resourcename id=resourcename value='$search_users_string'>";
                      print qq~




                       <table width=87%  border='0' cellpadding='3'>
                       <th class='TableColumnHeader' width=\"100%\"></th>
                       <tr><td  border=0 cellpadding=3><input type=submit class=submitButtonEnable1 value=\"View Workload\" onclick="formvalidate()" /></td>
                       <th class='TableColumnHeader' width=\"100%\"></th>
                       </table>
                       </form>


                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'add_skillset_form')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $session->clear();
     $session->param(usr=>$myname);
     $session->param(action=>'add_skillset_submit');
     &header($myname);

                        print qq~
                        <script language="javascript">
                        function addRow(tableID,hiddenfield)
                        {
                                 var table = document.getElementById(tableID);
                                 var rowCount = table.rows.length;
                                 var row = table.insertRow(rowCount);


                                 var colCount = table.rows[0].cells.length;

                                 var current_row = rowCount + 1;

                                 //alert("Column Count is "+colCount);
                                 for(var i=0; i<colCount; i++)
                                 {
                                   var newcell = row.insertCell(i);

                                   //alert("i is"+i);
                                   if(i==0)
                                   {
                                     cellname = "chkbox";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<input type=checkbox name="+newcell_name+">";
                                   }
                                   else if(i==1)
                                   {
                                     cellname = "skillsetname";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                    newcell.innerHTML = "<input type=text size=40 name="+newcell_name+">";
                                   }
                                   else if(i==2)
                                   {
                                     cellname = "skillsetdesc";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                    newcell.innerHTML = "<input type=text size=40 name="+newcell_name+">";
                                   }
                                   else if(i==3)
                                   {
                                     cellname = "skillsettype";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<select name="+newcell_name+"><option value=bu_independent_technical_skill>B.U Independent Technical Skill</option><option value=bu_independent_soft_skill>B.U Independent Soft Skill</option><option value=bu_dependent_technical_skill>B.U Dependent Technical Skill</option></select>";
                                   }
                                   else if(i==4)
                                   {
                                     cellname = "skillsetcomplevel";
                                     newcell_name = "taskrow_"+current_row +"_"+ cellname;
                                     newcell.innerHTML = "<select name="+newcell_name+"><option value=training>Training</option><option value=beginner>Beginner</option><option value=intermediate>Intermediate</option><option value=proficient>Proficient</option><option value=expert>Expert</option></select>";
                                   }

                                   //newcell.innerHTML = table.rows[0].cells[i].innerHTML;


                                   //alert(newcell.childNodes);
                                   var assigned_user = document.getElementById("hidden_user_name").getAttribute("value");
                                   switch(newcell.childNodes[0].type)
                                   {
                                    case "text":
                                                newcell.childNodes[0].value = "";
                                                break;
                                    case "checkbox":
                                                newcell.childNodes[0].checked = false;
                                                break;
                                    case "select-one":
                                                newcell.childNodes[0].selectedIndex = 1;
                                                break;


                                    }
                             }

                        }

                        function deleteRow(tableID,hiddenfield)
                        {
                         try
                         {
                          var table = document.getElementById(tableID);
                          var rowCount = table.rows.length;
                          //alert("Before deletion rowcount is "+rowCount);
                             for(var i=0; i<rowCount; i++)
                             {
                                  var row = table.rows[i];
                                  var chkbox = row.cells[0].childNodes[0];
                                  if(null != chkbox && true == chkbox.checked)
                                  {
                                     if(rowCount <= 1)
                                     {
                                      alert("Cannot delete all the rows.");
                                      break;
                                     }
                                     table.deleteRow(i);

                                     rowCount--;
                                     i--;
                                   }
                              }


                           }
                          catch(e)
                          {
                             alert(e);
                          }
                         }

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }


                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;
                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;



                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <input type=hidden name=hidden_user_name id=hidden_user_name value='$myname'>
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Skillset Entry : </th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       ~;
                       print "<td width=535 class='TableCellText' >Skillset Requester :</td>";
                       print "<td class='TableCellText' ><input type=text readonly=readonly value='$myname'></td>";

                        print qq~
                        </tr>
                        </table>


                        <table width=87%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=\"100%\">Add Skillset Details:</th>
                        </table>
                        <table width=87%  border='0' cellpadding='3'>
                        <tr class='TableColumnHeader' width=\"100%\">
                            <td style="width:4%;">Chq to Del</td>
                            <td style="width:12%;text-align:center">Skillset Name</td>
                            <td style="width:12%;text-align:center">Skillset Desc</td>
                            <td style="width:5%;text-align:center">Skillset Type</td>
                            <td style="width:12.5%;text-align:center">Skillset Competency</td>
                        </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 id=dataTable width=350px border=1>
                         <tr>
                            <td><input type=checkbox name=taskrow_1_chkbox ></td>
                            <td><input type=text size=40 name=taskrow_1_skillsetname ></td>
                            <td><input type=text size=40 name=taskrow_1_skillsetdesc ></td>
                            <td>
                               <select name=taskrow_1_skillsettype>
                                    <option value='bu_independent_technical_skill'>B.U Independent Technical Skill</option>
                                    <option value='bu_independent_soft_skill'>B.U Independent Soft Skill</option>
                                    <option value='bu_dependent_technical_skill'>B.U Dependent Technical Skill</option>
                                </select>
                            </td>
                            <td>
                               <select name=taskrow_1_skillsetcomplevel>
                                    <option value='training'>Training</option>
                                    <option value='beginner'>Beginner</option>
                                    <option value='intermediate'>Intermediate</option>
                                    <option value='proficient'>Proficient</option>
                                    <option value='expert'>Expert</option>
                                </select>
                            </td>
                       </tr>
                       </table>
                       <input type=button class=submitButtonEnable1 value=\"Add Task\" onclick=\"addRow('dataTable','taskrowcount')\" />
                       <input type=button class=submitButtonEnable1 value=\"Delete Task\" onclick=\"deleteRow('dataTable','taskrowcount')\" />
                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=\"formvalidate()\"/></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();

  }

elsif($session->param('action') eq 'add_skillset_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);


                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Skillset Update Status :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        ~;

                       foreach (@parameters)
                       {
                        if($_=~/taskrow_(\d+)_.*/)
                        {

                         if(not exists $tasks{$_})
                         {
                          $tasks{$1} = "";
                         }
                        }
                      }
                      @task_ids = keys %tasks;


                      @task_ids = sort {$a <=> $b} @task_ids;

                      foreach (@task_ids)
                      {
                          my $skillset_name_param = "taskrow_" . $_ . "_skillsetname"; #
                          my $skillset_desc_param = "taskrow_" . $_ . "_skillsetdesc"; #project
                          my $skillset_type_param = "taskrow_" . $_ . "_skillsettype";
                          my $skillset_complevel_param = "taskrow_" . $_ . "_skillsetcomplevel";

                          my $skillset_name = $session->param("$skillset_name_param"); #comments
                          my $skillset_desc = $session->param("$skillset_desc_param"); #comments
                          my $skillset_type = $session->param("$skillset_type_param"); #comments
                          my $skillset_complevel = $session->param("$skillset_complevel_param"); #comments

                          my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                          my $sth = $dbh->prepare("INSERT INTO new_skillset_request (skillset_requester,skillset_name,skillset_desc,skillset_type,comp_level) VALUES ('$myname','$skillset_name','$skillset_desc','$skillset_type','$skillset_complevel');");
                          $sth->execute() || die "$DBI::errstr\n";
                          $sth->finish();
                          $dbh->disconnect();

                          print "<tr><td>Skillset $skillset_name Requested Successfully</td></tr>";

                        }
                       print "<tr><td><b>Thanks for submitting.The administrator would review the details and do the needful shortly</b></td></tr>";
                       print "</table>";
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'edit_timecard_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'edit_timecard_submit');
    &header($myname);
                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        };


                        </script>
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {

                           singledayField_val = document.getElementById("singledayField").value;

                           if(!singledayField_val)
                           {
                            alert("Please Enter Date");
                            return(false);
                           }


                        }
                        </script>
                        ~;
                        #my $hashref = getusers($myname);
                        #my %user_details = %$hashref;


                        getsubordinates($myname);
                        push(@final_sub_list,$myname);

                        my $final_sub_list_ref = \@final_sub_list;
                        my $hashref = getfullnametitle($final_sub_list_ref);
                        my %user_details = %$hashref;



                       print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Retrieve Time Card To Edit:</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr class='TableCellText'><td class='TableCellText' width=\"150\">Resource </td>
                            <td>
                                <select name=timecard_user>
                                ~;
                                foreach $key (keys %user_details)
                               {
                                 print "<option value=$key>$user_details{$key}</option>";
                               }

                                print qq~
                                </select>
                            </td>
                        </tr>
                        <tr><td width=\"265\" class='TableCellText'>Search Date</td><td class='TableCellText'><div id=div_form_single style="visibility:visible"><input type=text name=singledayField id=singledayField size=12></div></td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'edit_timecard_submit')
{
     print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
     $myname = $session->param("usr");
     $timecarduser = $session->param("timecard_user");
     $timecarddate = $session->param("singledayField");

     $session->clear();
     $session->param(usr=>$myname);
     $session->param(timecard_user=>$timecarduser);
     $session->param(singledayField=>$timecarddate);
     $session->param(action=>'edit_timecard_db_update');



     %months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");

    if($timecarddate=~/(\d+)-(.*)-(\d+)/)
    {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


     &header($myname);
                        print qq~
                        <script language="javascript">
                         function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }
                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val==null)
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            if((taskname=="") || (taskcat=="") || (taskduration==""))
                            {
                            alert("Please enter all details for task");
                            window.location.reload();
                            }
                          }
                        }
                        </script>
                        ~;
                       print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=100%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Edit Time Card Details : </th>
                      </table>
                      <table width=100% border=0 cellpadding=3 width=350px border=1>
                      <tr><td width=535 class='TableCellText' >Resource Name :</td><td class='TableCellText' >$timecarduser</td></tr>
                      <tr><td width=535 class='TableCellText' >Date :</td><td class='TableCellText' >$timecarddate</td></tr>
                      </table>
                      <table width=100%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=\"100%\">Task Details :</th>
                      </table>
                      <table width=100% border=0 cellpadding=3 id=dataTable width=350px border=1>
                      <th class='TableColumnHeader' width=\"100%\">To Update tasks update fields and Click 'Update Tasks' button. To delete tasks, check the task rows and click on 'Update Tasks'</th>
                      </table>
                      ~;

                      print "<table width=100% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                      print "<tr class='TableColumnHeader'><td>Del</td><td>Task</td><td>Task Type</td><td>Task Comments</td><td>Task Category</td><td>Duration In min</td><td>Priority</td><td>% Completed</td><td>Status</td><td>ETA (YYYY-MM-DD)</td><td>Activity ID </td></tr>";
                      #print "</table>";







                         getsubordinates($myname);
                         push(@final_sub_list,$myname);

                         my $final_sub_list_ref = \@final_sub_list;

                         my $allusersskillsethashref = getskillsetagainstroles($final_sub_list_ref);
                         my %allusersskillsethash =  %$allusersskillsethashref;

                         my $projects_hash_ref = getprojects();
                         my %projects = %$projects_hash_ref;



                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("SELECT task_id,task_cat,task_comments,task_projname,task_manhour,task_priority,task_percentage_complete,task_status,task_eta,activity_id FROM task_global where task_username='$timecarduser' and task_date='$date' AND task_assigned_by='$myname';");
                         $sth->execute() || die "$DBI::errstr\n";
                         my $task_count =  0;
                         while (@resultset = $sth->fetchrow_array)
                          {
                            $task_count = $task_count + 1;
                            my $task_id = $resultset[0];
                            my $task_cat = $resultset[1];
                            my $task_comments = $resultset[2];
                            my $task_projname = $resultset[3];
                            my $task_manhour = $resultset[4];
                            my $task_priority = $resultset[5];
                            my $task_percentage_completed = $resultset[6];
                            my $task_status = $resultset[7];
                            my $task_eta = $resultset[8];
                            my $activity_id = $resultset[9];

                            my $task_checkbox_cell_name = "task_" . $task_count . "_cellcheck";
                            my $task_id_cell_name = "task_" . $task_count . "_cellid";
                            my $task_cattype_cell_name = "task_" . $task_count . "_cellcat";
                            my $task_comments_cell_name = "task_" . $task_count . "_cellcomments";
                            my $task_projects_cell_name = "task_" . $task_count . "_cellprojects";
                            my $task_manhr_cell_name = "task_" . $task_count . "_cellmanhr";
                            my $task_priority_cell_name = "task_" . $task_count . "_cellpriority";
                            my $task_percentage_completed_cell_name = "task_" . $task_count . "_cellpercentagecompleted";
                            my $task_status_cell_name = "task_" . $task_count . "_cellstatus";
                            my $task_eta_cell_name = "task_" . $task_count . "_celleta";
                            my $task_activityid_cell_name = "task_" . $task_count . "_cellactivityid";



                            if($task_status eq "Completed")
                            {
                                  #print "<table width=100% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                                  
                                  
                                  print "<tr>";
                                  print "<td><input disabled=disabled type=checkbox name='$task_checkbox_cell_name' ></td>";

                                  print "<td><input readonly=readonly type=text name='$task_id_cell_name' size=2 value='$task_id'></td>";
      
                                  print "<td>";
                                  print "<select  name='$task_cattype_cell_name'>";
                                  print "<option value='$task_cat'>$task_cat</option>";
                                  print "</select>";
                                  print "</td>";

                                  print "<td><input readonly=readonly type=text name='$task_comments_cell_name' size=25 value='$task_comments'></td>";

                                  print "<td>";
                                  print "<select name='$task_projects_cell_name'>";
                                  print "<option value='$task_projname'>$task_projname</option>";
                                  print "</select>";
                                  print "</td>";
      
      
                                  #print "<td><input type=text name='$task_cattype_cell_name' size =25 value='$task_cattype'></td>";
      
      
                                  print "<td><input readonly=readonly type=text name='$task_manhr_cell_name' size=15 value='$task_manhour'></td>";
                                  
                                  print "<td>";
                                  print "<select name='$task_priority_cell_name'>";
                                  print "<option value='$task_priority'>$task_priority</option>";
                                  print "</select>";
                                  print "</td>";
      
                                  print "<td><input readonly=readonly type=text name='$task_percentage_completed_cell_name' size=7 value='100'></td>";


                                  print "<td>";
                                  print "<select name='$task_status_cell_name'>";
                                  print "<option value='$task_status'>$task_status</option>";
                                  print "</select>";
                                  print "</td>";

                                  print "<td><input readonly=readonly type=text name='$task_eta_cell_name' size=15 value=''></td>";

                                  print "<td><input readonly=readonly type=text name='$task_activityid_cell_name' size=15 value='$activity_id'></td>";

                                  print "</tr>";

                            }
                            elsif($task_status eq "In Progress")
                            {
                                  #print "<table width=100% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                                  print "<tr>";
                                  print "<td><input disabled=disabled type=checkbox name='$task_checkbox_cell_name' ></td>";
                                  print "<td><input readonly=readonly type=text name='$task_id_cell_name' size=2 value='$task_id'></td>";

                                  print "<td>";
                                  print "<select name='$task_cattype_cell_name'>";
                                  print "<option value='$task_cat'>$task_cat</option>";
                                  print "</select>";
                                  print "</td>";

                                  print "<td><input type=text name='$task_comments_cell_name' size=25 value='$task_comments'></td>";

                                  print "<td>";
                                  print "<select name='$task_projects_cell_name'>";
                                  print "<option value='$task_projname'>$task_projname</option>";
                                  print "</select>";
                                  print "</td>";
      
      
                                  #print "<td><input type=text name='$task_cattype_cell_name' size =25 value='$task_cattype'></td>";

      
                                  print "<td><input type=text name='$task_manhr_cell_name' size=15 value='$task_manhour'></td>";
                                  
                                  print "<td>";
                                  print "<select name='$task_priority_cell_name'>";
                                  print "<option value='$task_priority'>$task_priority</option>";
                                  print "</select>";
                                  print "</td>";
      
                                  print "<td><input type=text name='$task_percentage_completed_cell_name' size=7 value='$task_percentage_completed'></td>";

                                  print "<td>";
                                  print "<select name='$task_status_cell_name'>";

                                  print "<option value='$task_status'><font color=green>$task_status</font></option>";
      
                                  if($task_status eq "Planned")
                                  {
                                    print "<option value='In Progress'>In Progress</option>";
                                    print "<option value='Completed'>Completed</option>";
                                  }
                                  elsif($task_status eq "In Progress")
                                  {
                                    print "<option value='Completed'>Completed</option>";
                                  }
                                  print "</select>";
                                  print "</td>";
                                  
                                  print "<td><input type=text name='$task_eta_cell_name' size=15 value='$task_eta'></td>";

                                  print "<td><input readonly=readonly type=text name='$task_activityid_cell_name' size=15 value='$activity_id'></td>";

                                  print "</tr>";
                            }
                            else
                            {
                                  #print "<table width=100% border=0 cellpadding=3 id=dataTable width=350px border=1>";
                                  print "<tr>";
                                  print "<td><input type=checkbox name='$task_checkbox_cell_name' ></td>";
                                  print "<td><input readonly=readonly type=text name='$task_id_cell_name' size=2 value='$task_id'></td>";

                                  print "<td >";
                                  print "<select name='$task_cattype_cell_name'>";

                                  print "<option value='$task_cat'><font color=green>$task_cat</font></option>";
      
                                  delete($allusersskillsethash{$task_cat});

                                  foreach $key (keys %allusersskillsethash)
                                  {
                                    print "<option value='$key'>$key</option>";
                                  }
                                  print "</select>";
                                  print "</td>";
      
                                  print "<td><input type=text name='$task_comments_cell_name' size=25 value='$task_comments'></td>";
      
                                  print "<td>";
                                  print "<select name='$task_projects_cell_name'>";
      
                                  print "<option value='$task_projname'><font color=green>$task_projname</font></option>";
      
                                  delete($projects{$task_projname});
      
                                  foreach $key (keys %projects)
                                  {
                                    print "<option value='$key'>$key</option>";
                                  }
                                  print "</select>";
                                  print "</td>";
      
      
                                  #print "<td><input type=text name='$task_cattype_cell_name' size =25 value='$task_cattype'></td>";
      
      
                                  print "<td><input type=text name='$task_manhr_cell_name' size=15 value='$task_manhour'></td>";
                                  
                                  print "<td>";
                                  print "<select name='$task_priority_cell_name'>";
      
                                  print "<option value='$task_priority'><font color=green>$task_priority</font></option>";
      
                                  if($task_priority eq "high")
                                  {
                                    print "<option value=med>med</option>";
                                    print "<option value=low>low</option>";
                                  }
                                  elsif($task_priority eq "medium")
                                  {
                                    print "<option value=low>low</option>";
                                    print "<option value=high>high</option>";
                                  }
                                  elsif($task_priority eq "low")
                                  {
                                    print "<option value=med>med</option>";
                                    print "<option value=high>high</option>";
                                  }
                                  print "</select>";
                                  print "</td>";
      
                                  print "<td><input readonly=readonly type=text name='$task_percentage_completed_cell_name' size=7 value='0'></td>";
      
                                  print "<td>";
                                  print "<select name='$task_status_cell_name'>";
      
                                  print "<option value='$task_status'><font color=green>$task_status</font></option>";

                                  if($task_status eq "Planned")
                                  {
                                    print "<option value='In Progress'>In Progress</option>";
                                    #print "<option value='Completed'>Completed</option>";
                                  }
                                  elsif($task_status eq "In Progress")
                                  {
                                    print "<option value='Completed'>Completed</option>";
                                  }
                                  print "</select>";
                                  print "</td>";
      
                                  print "<td><input readonly=readonly type=text name='$task_eta_cell_name' size=15 value=''></td>";

                                  print "<td><input readonly=readonly type=text name='$task_activityid_cell_name' size=15 value='$activity_id'></td>";

                                  print "</tr>";
                            }
                          }
                         $sth->finish();
                         $dbh->disconnect();
                         print "</table>";
                         print qq~
                         <input type=hidden name=hidden_totaltasks id=hidden_totaltasks value="$task_count">
                         <input type=hidden name=hidden_activity_id id=hidden_activity_id value="$activity_id">
                         <p></p>
                         <p></p>
                         <table width=90%  border='0' cellpadding='3'>
                         <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Update Task\" ></td>
                         <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                         </tr>
                         </table>
                         </form>
                         </div>
                       ~;
                       &footer();

}
elsif($session->param('action') eq 'edit_timecard_db_update')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    &header($myname);



                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Timecard Update Status :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;

                         my $totaltaskcount = $session->param("hidden_totaltasks");
                         my $timecarduser = $session->param("timecard_user");
                         my $timecarddate = $session->param("singledayField");
                         my $activity_id =  $session->param("hidden_activity_id");
                         my $goal_id = "";


                          my $timecarddate = convert_jquerydate_to_mysql_date($timecarddate);


                          print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                          print "<th class='TableColumnHeader' width=\"100%\">Edit Timecard</th>";
                          for($task_index=1;$task_index<=$totaltaskcount;$task_index++)
                          {
                            $task_checkbox_param_id =  "task_" . $task_index . "_cellid";
                            $task_checkbox_param_id_val = $session->param($task_checkbox_param_id);


                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("select goal_id from activities where activity_id = (select activity_id from task_global where task_id=$task_checkbox_param_id_val);");
                            $sth->execute() || die "$DBI::errstr\n";
                            while (@resultset = $sth->fetchrow_array)
                            {
                             $goal_id = $resultset[0];
                            }
                            $sth->finish();
                            $dbh->disconnect();

                            #print "<th class='TableColumnHeader' width=\"100%\">Goal for task [$task_checkbox_param_id_val] is $goal_id</th>";

                           $task_checkbox_param_name =  "task_" . $task_index . "_cellcheck";
                           $task_checkbox_param_val = $session->param($task_checkbox_param_name);

                           if($task_checkbox_param_val eq "on")
                           {
                            $task_checkbox_param_id =  "task_" . $task_index . "_cellid";
                            $task_checkbox_param_id_val = $session->param($task_checkbox_param_id);

                            $task_activityid_param_id =  "task_" . $task_index . "_cellactivityid";
                            $task_activityid_param_id_val = $session->param($task_activityid_param_id);



                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("DELETE FROM task_global WHERE task_id=$task_checkbox_param_id_val AND task_username='$timecarduser' AND task_date='$timecarddate';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();
                            
                            ### Updating activity status. If this is the only task under the activity, then change it's status to Assigned, else don't do anything

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("select count(task_id) from task_global where activity_id = '$task_activityid_param_id_val';");
                            $sth->execute() || die "$DBI::errstr\n";
                            while ($resultset = $sth->fetchrow_array)
                            {
                             $task_count = $resultset;
                            }
                            $sth->finish();
                            $dbh->disconnect();
  
                            if($task_count >0)
                            {
                            }
                            else
                            {



                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE activities SET activity_status='Assigned' WHERE activity_id='$task_activityid_param_id_val';");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
                            



#                             mail_activity_status_updates($task_activityid_param_id_val);
                            }

                            ###
                            print "<tr><td class='TableCellText' >Task Row belonging to activity $activity_id having ID $task_checkbox_param_id_val Deletion Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                           }
                           else
                           {
                            $task_activityid_param_id =  "task_" . $task_index . "_cellactivityid";
                            $task_activityid_param_id_val = $session->param($task_activityid_param_id);

                            $task_checkbox_param_id =  "task_" . $task_index . "_cellid";
                            $task_checkbox_param_id_val = $session->param($task_checkbox_param_id);

                            $task_checkbox_param_cat =  "task_" . $task_index . "_cellcat";
                            $task_checkbox_param_cat_val = $session->param($task_checkbox_param_cat);

                            $task_checkbox_param_comments =  "task_" . $task_index . "_cellcomments";
                            $task_checkbox_param_comments_val = $session->param($task_checkbox_param_comments);

                            $task_checkbox_param_projects =  "task_" . $task_index . "_cellprojects";
                            $task_checkbox_param_projects_val = $session->param($task_checkbox_param_projects);

                            $task_checkbox_param_manhr =  "task_" . $task_index . "_cellmanhr";
                            $task_checkbox_param_manhr_val = $session->param($task_checkbox_param_manhr);

                            $task_checkbox_param_priority =  "task_" . $task_index . "_cellpriority";
                            $task_checkbox_param_priority_val = $session->param($task_checkbox_param_priority);

                            $task_checkbox_param_status =  "task_" . $task_index . "_cellstatus";
                            $task_checkbox_param_status_val = $session->param($task_checkbox_param_status);

                            $task_checkbox_param_percentagecompleted =  "task_" . $task_index . "_cellpercentagecompleted";
                            $task_checkbox_param_percentagecompleted_val = $session->param($task_checkbox_param_percentagecompleted);

                            $task_checkbox_param_eta =  "task_" . $task_index . "_celleta";
                            $task_checkbox_param_eta_val = $session->param($task_checkbox_param_eta);


                            ### If the user is directly updating from In progress to completed without setting any value for percentage complete

#                             if(($task_checkbox_param_status_val eq "Completed") and ($task_checkbox_param_percentagecompleted_val = 0))
#                             {
#                              $task_checkbox_param_percentagecompleted_val =  100;
#                             }


                            ###
                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("UPDATE task_global SET task_comments='$task_checkbox_param_comments_val',task_cat='$task_checkbox_param_cat_val',task_projname='$task_checkbox_param_projects_val',task_manhour=$task_checkbox_param_manhr_val,task_priority='$task_checkbox_param_priority_val',task_status='$task_checkbox_param_status_val',task_eta='$task_checkbox_param_eta_val',task_percentage_complete=$task_checkbox_param_percentagecompleted_val WHERE task_id=$task_checkbox_param_id_val AND task_username='$timecarduser' AND task_date='$timecarddate';");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();
                            #print "UPDATE task_global SET task_comments='$task_checkbox_param_comments_val',task_cat='$task_checkbox_param_cat_val',task_projname='$task_checkbox_param_projects_val',task_manhour=$task_checkbox_param_manhr_val,task_priority='$task_checkbox_param_priority_val',task_status='$task_checkbox_param_status_val' WHERE task_id=$task_checkbox_param_id_val AND task_username='$timecarduser' AND task_date='$timecarddate'";
                            #print "<tr><td class='TableCellText' >Task Row Having ID $task_checkbox_param_id_val Update Status</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";

                            ### Update the task_transactions table
                            
                            $todays_date = gettodaysdate();

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("INSERT INTO task_transactions (task_id,task_username,task_cat,task_comments,task_projname,task_update_date,task_manhour,task_priority,task_percentage_complete,task_status,task_eta,activity_id,transaction_type) VALUES ($task_checkbox_param_id_val,'$timecarduser','$task_checkbox_param_cat_val','$task_checkbox_param_comments_val','$task_checkbox_param_projects_val','$todays_date',$task_checkbox_param_manhr_val,'$task_checkbox_param_priority_val',$task_checkbox_param_percentagecompleted_val,'$task_checkbox_param_status_val','$task_checkbox_param_eta_val','$task_activityid_param_id_val','UPDATE');");
                            $sth->execute() || die "$DBI::errstr\n";
                            $sth->finish();
                            $dbh->disconnect();



                            ### Update activity status. If activity status is Planned change it to In Progress

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("SELECT activity_status FROM activities WHERE activity_id='$task_activityid_param_id_val';");
                            $sth->execute() || die "$DBI::errstr\n";
                            while ($resultset = $sth->fetchrow_array)
                            {
                             $activity_status = $resultset;
                            }
                            $sth->finish();
                            $dbh->disconnect();
  
                            if(($activity_status eq "Planned") and ($task_checkbox_param_status_val eq "In Progress"))
                            {
                             $activity_status = "In Progress";

                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE activities SET activity_status='$activity_status' WHERE activity_id='$task_activityid_param_id_val';");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();

#                             mail_activity_status_updates($task_activityid_param_id_val);

                             my $today = gettodaysdate();

                             #print "UPDATE activity_details SET activity_actual_start_date='$today' WHERE activity_id='$task_activityid_param_id_val';";

                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE activity_details SET activity_actual_start_date='$today' WHERE id='$task_activityid_param_id_val';");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();


                            }
  
                            ### As in this page tasks can belong to multiple activities we need to update activity_details and goals table percentage completion data here

                            #### Updating the activity details table with activity percentage completion data
                         
                             $activity_completion_data = calculate_activity_completion_percentage($task_activityid_param_id_val);

                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE activity_details SET activity_percentage_complete=$activity_completion_data WHERE id='$task_activityid_param_id_val';");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
      
      
                             ### Updating the goals table with goal percentage completion data

                             $goal_completion_data = calculate_goal_completion_percentage($goal_id);

                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE goals SET goal_percentage_complete=$goal_completion_data WHERE goal_id=$goal_id ;");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();

                             ####

                             print "<tr><td class='TableCellText' >Task Row Having ID $task_checkbox_param_id_val Update Status[$goal_id][$goal_completion_data]</td><td class='TableCellText' ><font color=green><b>SUCCESS</b></font></td></tr>";
                            ###
                           }

                          }
                          

                         print "</table>";

                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'workload_search')
  {
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");

    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'submit_timecard');

    &header($myname);
                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        new JsDatePick({
                        	useMode:2,
                        	target:"durationfromField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        new JsDatePick({
                        	useMode:2,
                        	target:"durationtoField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });

                        };

                        </script>
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(!resourcename_val)
                          {
                            alert("Please select a resourcename from drop down");
                            return(false);
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(!singledayField_val)
                           {
                            alert("Please select a date");
                            return(false);
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((!durationfrom_Field_val) || (!durationto_Field_val))
                           {
                            alert("Please select From and To dates");
                            return(false);
                           }
                          }

                        }
                        </script>
                        ~;

                       #my $hashref = getusers($myname);
                       #my %user_details = %$hashref;

                        getsubordinates($myname);
                        push(@final_sub_list,$myname);

                        my $final_sub_list_ref = \@final_sub_list;
                        my $hashref = getfullnametitle($final_sub_list_ref);
                        my %user_details = %$hashref;


                       #my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       #my $sth = $dbh->prepare("SELECT username FROM resources;");
                       #$sth->execute() || die "$DBI::errstr\n";
                       #while ($resultset_name = $sth->fetchrow_array)
                       # {
                       #  push(@users,$resultset_name);
                       # }
                       #$sth->finish();
                       #$dbh->disconnect();


                      print qq~
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Search Employee Workload :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                          ~;

                          print "<td width=535 class='TableCellText' >Resource Name :</td>";
                          print "<td class='TableCellText' >";
                          print "<select id=resourcename name=resourcename multiple>";


                           foreach $key (keys %user_details)
                           {

                              print "<option value=$key>$user_details{$key}</option>";

                           }

                        print qq~
                            </select>
                          </td>
                        </tr>
                        </table>
                        <table width=87%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=100%>Search Date can be Single Day or Duration</th>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"265\" class='TableCellText'>Single Day</td><td width=\"265\" class='TableCellText'><input type="radio" id="singlentry" checked="true" value="Daily Task Entry" onclick="test('singlentry')"/></td><td width=\"125\" class='TableCellText'><div id=div_form_single_date style="visibility:visible">Date :</td><td class='TableCellText'><div id=div_form_single style="visibility:visible"><input type=text name=singledayField id=singledayField size=12></div></td></tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"125\" class='TableCellText'>Duration</td><td width=\"125\" class='TableCellText'><input type="radio" id="durationentry" value="Tasks Entry for a Duration" onclick="test('durationentry')" /></td><td width=\"125\" class='TableCellText'><div id=div_form_duration_from style="visibility:hidden">From Date : </td></td><td width=\"125\" class='TableCellText'><div id=div_form_duration_from_dialog style="visibility:hidden"><input type=text name=durationfromField id=durationfromField size=12></td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to style="visibility:hidden">To Date :</td><td width=\"125\" class='TableCellText'><div id=div_form_duration_to_dialog style="visibility:hidden"><input type=text name=durationtoField id=durationtoField size=12></td></div></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'add_project_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'submit_project');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="admin_form.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Add Task Categories :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"150\" class='TableCellText'>Task Category Name </td><td width=\"265\" class='TableCellText'><input type=text name=taskcatname id=taskcatname size=100 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Task Category Description </td><td width=\"265\" class='TableCellText'><input type=text name=taskcatdesc id=taskcatdesc size=100 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Task Category Type </td>
                            <td>
                                <select name=taskcattype>
                                        <option value=waterfall>Waterfall</option>
                                        <option value=scrum>SCRUM</option>
                                        <option value=quarterly>Quarterly</option>
                                        <option value=testautomation>Test Automation</option>
                                        <option value=nonproject>Non Project</option>
                                        <option value=selflearning>Dev Objective</option>
                                </select>
                            </td>
                        </tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <th class='TableColumnHeader' width=\"100%\"></th>
                       <tr><td  border=0 cellpadding=3><input type=submit class=submitButtonEnable1 value=\"Submit Form\" /></td>
                       <td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick="formReset()" /></tr>
                       <th class='TableColumnHeader' width=\"100%\"></th>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'register_user_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");

    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'submit_user');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="admin_form.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Register User :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"150\" class='TableCellText'>Select Username </td><td width=\"265\" class='TableCellText'><input type=text name=register_username id=register_username size=25 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Select Password </td><td width=\"265\" class='TableCellText'><input type=password name=register_password id=register_password size=25 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>First Name </td><td width=\"265\" class='TableCellText'><input type=text name=register_first_name id=register_first_name size=50 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Last Name </td><td width=\"265\" class='TableCellText'><input type=text name=register_last_name id=register_last_name size=50 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Email ID </td><td width=\"265\" class='TableCellText'><input type=text name=register_email_id id=register_email_id size=50 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Business Title </td><td width=\"265\" class='TableCellText'><input type=text name=register_business_title id=register_business_title size=50 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Location </td>
                            <td>
                                <select name=register_user_location>
                                        <option value=Hyderabad>Hyderabad</option>
                                        <option value=Bangalore>Bangalore</option>
                                        <option value=Delhi>Delhi</option>
                                </select>
                            </td>
                        </tr>
                        <tr><td width=\"150\" class='TableCellText'>Manager Username</td><td width=\"265\" class='TableCellText'><input type=text name=register_user_manager id=register_user_manager size=50 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Mantis Username</td><td width=\"265\" class='TableCellText'><input type=text name=register_mantis_id id=register_mantis_id size=50 /></td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'view_timecard_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'view_timecard_submit');
    &header($myname);
                        print qq~
                        <script type="text/javascript">
                        window.onload = function(){
                        new JsDatePick({
                        	useMode:2,
                        	target:"singledayField",
                        	dateFormat:"%d-%M-%Y"
                        	/*selectedDate:{
                        	day:5,
                        	month:9,
                        	year:2006
                        	},
                        	yearsRange:[1978,2020],
                        	limitToToday:false,
                        	cellColorScheme:"blue",
                        	dateFormat:"%m-%d-%Y",
                        	imgPath:"img/",
                        	weekStartDay:1*/
                          });
                        
                        };


                        </script>
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {

                           singledayField_val = document.getElementById("singledayField").value;

                           if(!singledayField_val)
                           {
                            alert("Please enter date");
                            return(false);
                           }


                        }
                        </script>
                        ~;
                        #my $hashref = getusers($myname);
                        #my %user_details = %$hashref;

                       getsubordinates($myname);
                       push(@final_sub_list,$myname);
                       my $final_sub_list_ref = \@final_sub_list;
                       my $hashref = getfullnametitle($final_sub_list_ref);
                       my %user_details = %$hashref;

                       print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <div></div>
                      <div><p></p><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >View Resource Time Card :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr class='TableCellText'><td width=\"150\" class='TableCellText'>Resource </td>
                            <td>
                                <select name=timecard_user>
                                ~;
                                foreach $key (keys %user_details)
                               {
                                 print "<option value=$key>$user_details{$key}</option>";
                               }

                                print qq~
                                </select>
                            </td>
                        </tr>
                        <tr><td width=\"265\" class='TableCellText'>Search Date</td><td class='TableCellText'><div id=div_form_single style="visibility:visible"><input type=text name=singledayField id=singledayField size=12></div></td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'view_tasks_under_activity')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'view_tasks_under_activity');
    &header($myname);
                        #my $hashref = getusers($myname);
                        #my %user_details = %$hashref;

                       getsubordinates($myname);
                       push(@final_sub_list,$myname);
                       my $final_sub_list_ref = \@final_sub_list;
                       my $hashref = getfullnametitle($final_sub_list_ref);
                       my %user_details = %$hashref;

                       print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="display_workload.pl" method="post">
                      <div></div>
                      <div><p></p><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >View Resource Time Card :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr class='TableCellText'><td width=\"150\" class='TableCellText'>Activity </td>
                            <td>
                                <select name=activity>
                                ~;
                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_desc FROM activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('Assigned','Planned','In Progress')order by a.activity_reported_date;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while (@resultset = $sth->fetchrow_array)
                       {
                        $activity_id = $resultset[0];
                        $activity_desc = $resultset[1];
                        print "<option value=$activity_id>[$activity_id] :: $activity_desc</option>";
                       }
                       $sth->finish();
                       $dbh->disconnect();

                                print qq~
                                </select>
                            </td>
                        </tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'mark_dependent_tasks')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mark_dependent_tasks_submit');
    &header($myname);
                        #my $hashref = getusers($myname);
                        #my %user_details = %$hashref;

                       getsubordinates($myname);
                       push(@final_sub_list,$myname);
                       my $final_sub_list_ref = \@final_sub_list;
                       my $hashref = getfullnametitle($final_sub_list_ref);
                       my %user_details = %$hashref;

                       print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Mark Task As Dependent Of Another Task :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"150\" class='TableCellText'>Specify Task ID </td><td width=\"265\" class='TableCellText'><input type=text name=input_task_id id=input_task_id size=25 /></td></tr>
                        <tr><td width=\"150\" class='TableCellText'>Specify Dependent Task ID</td><td width=\"265\" class='TableCellText'><input type=text name=dependent_task_id id=dependent_task_id size=25 /></td></tr>
                       </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'mark_dependent_tasks_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    &header($myname);




                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87% border=0 cellpadding=3 width=350px>
                       </table>

                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                      </table>

                        ~;

                      my $resource_name = $myname;
                      my $input_task_id = $session->param("input_task_id");
                      my $dependent_task_id = $session->param("dependent_task_id");

                      print "<table width=87% cellpadding=3 width=350px border=0>";
                      print "<th class='TableColumnHeader' width=100%> Activity Submission Status :</th>";
                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                      my $sth = $dbh->prepare("UPDATE task_global set task_depends_on = '$dependent_task_id' where task_id = '$input_task_id';");
                      $sth->execute() || die "$DBI::errstr\n";
                      $sth->finish();

#                      mail_activity_status_updates($activity_id,$myname);

                      print "<tr class='TableColumnHeader' width=100%><td><font color='green'><b>SUCCESS : </b></font>Dependent Task Set Successfully.</td></tr>";
                      print "</table>";

                       &footer();
}

elsif($cgi->param('action') eq 'view_gantt_chart')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);

    &header($myname);

    #$project_file = "/home/smitra/htdocs/webapp/javascript/jsgantt/project/output.xml";
    $project_file = "C://Program Files//Apache Software Foundation//Apache2.2//htdocs//webapp//javascript//jsgantt//project//output.xml";
	update_project_xml($project_file);

    print "<div id=Layer1 style='width:75%; height:87%; overflow: scroll;'><div style='position:right' class='gantt' id='GanttChartDIV' overflow: scroll;'></div></div>";
    #print "<div style='position:relative' class='gantt' id='GanttChartDIV'></div>";


                        print qq~

                        <script type="text/javascript">

                	var g = new JSGantt.GanttChart(document.getElementById('GanttChartDIV'), 'day' );
                	if( g.getDivId() != null ) {
                		g.setCaptionType('Complete');  // Set to Show Caption (None,Caption,Resource,Duration,Complete)
                		g.setQuarterColWidth(36);
                		g.setDateTaskDisplayFormat('day dd month yyyy'); // Shown in tool tip box
                		g.setDayMajorDateDisplayFormat('mon yyyy - Week ww') // Set format to display dates in the "Major" header of the "Day" view
                		g.setWeekMinorDateDisplayFormat('dd mon') // Set format to display dates in the "Minor" header of the "Week" view
                		g.setShowTaskInfoLink(1); //Show link in tool tip (0/1)
                		g.setShowEndWeekDate(0); // Show/Hide the date for the last day of the week in header for daily view (1/0)
                		g.setUseSingleCell(10000); // Set the threshold at which we will only use one cell per table row (0 disables).  Helps with rendering performance for large charts.
                		g.setFormatArr('Day', 'Week', 'Month', 'Quarter'); // Even with setUseSingleCell using Hour format on such a large chart can cause issues in some browsers
                		// Parameters                     (pID, pName,                  pStart,       pEnd,        pStyle,         pLink (unused)  pMile, pRes,       pComp, pGroup, pParent, pOpen, pDepend, pCaption, pNotes, pGantt)
                
                                JSGantt.parseXML('http://127.0.0.1/webapp/javascript/jsgantt/project/output.xml',g)

                		g.Draw();
                	} else {
                		alert("Error, unable to create Gantt Chart");
                	}

                        </script>

                        ~;

                        #print "<body onload='generate_gantt_chart()'>";
                        #print "</body></html>";
                        &footer();

}
elsif($cgi->param('action') eq 'view_advanced_gantt_chart')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);

    &header($myname);
    print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    ~;

    print "<div align='right' class='gantt' id='GanttChartDIV' style='width:100%; height:85%; overflow: scroll;'></div>";



                        print qq~

                        <script type="text/javascript">

                	var g = new JSGantt.GanttChart(document.getElementById('GanttChartDIV'), 'day' );
                	if( g.getDivId() != null ) {
                		g.setCaptionType('Complete');  // Set to Show Caption (None,Caption,Resource,Duration,Complete)
                		g.setQuarterColWidth(36);
                		g.setDateTaskDisplayFormat('day dd month yyyy'); // Shown in tool tip box
                		g.setDayMajorDateDisplayFormat('mon yyyy - Week ww') // Set format to display dates in the "Major" header of the "Day" view
                		g.setWeekMinorDateDisplayFormat('dd mon') // Set format to display dates in the "Minor" header of the "Week" view
                		g.setShowTaskInfoLink(1); //Show link in tool tip (0/1)
                		g.setShowEndWeekDate(0); // Show/Hide the date for the last day of the week in header for daily view (1/0)
                		g.setUseSingleCell(10000); // Set the threshold at which we will only use one cell per table row (0 disables).  Helps with rendering performance for large charts.
                		g.setFormatArr('Day', 'Week', 'Month', 'Quarter'); // Even with setUseSingleCell using Hour format on such a large chart can cause issues in some browsers
                		// Parameters                     (pID, pName,                  pStart,       pEnd,        pStyle,         pLink (unused)  pMile, pRes,       pComp, pGroup, pParent, pOpen, pDepend, pCaption, pNotes, pGantt)
                
                		g.AddTaskItem(new JSGantt.TaskItem(1,   'Define Chart API',     '',           '',          'ggroupblack',  '',                 0, 'Brian',    0,     1,      0,       1,     '',      '',      'Some Notes text', g ));
                		g.AddTaskItem(new JSGantt.TaskItem(11,  'Chart Object',         '2014-02-20','2014-02-20', 'gmilestone',   '',                 1, 'Shlomy',   100,   0,      1,       1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(12,  'Task Objects',         '',           '',          'ggroupblack',  '',                 0, 'Shlomy',   40,    1,      1,       1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(121, 'Constructor Proc',     '2014-02-21','2014-03-09', 'gtaskblue',    '',                 0, 'Brian T.', 60,    0,      12,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(122, 'Task Variables',       '2014-03-06','2014-03-11', 'gtaskred',     '',                 0, 'Brian',    60,    0,      12,      1,     121,     '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(123, 'Task by Minute/Hour',  '2014-03-09','2014-03-14 12:00', 'gtaskyellow', '',            0, 'Ilan',     60,    0,      12,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(124, 'Task Functions',       '2014-03-09','2014-03-29', 'gtaskred',     '',                 0, 'Anyone',   60,    0,      12,      1,     '123SS', 'This is a caption', null, g));
                		g.AddTaskItem(new JSGantt.TaskItem(2,   'Create HTML Shell',    '2014-03-24','2014-03-24', 'gtaskyellow',  '',                 0, 'Brian',    20,    0,      0,       1,     122,     '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(3,   'Code Javascript',      '',           '',          'ggroupblack',  '',                 0, 'Brian',    0,     1,      0,       1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(31,  'Define Variables',     '2014-02-25','2014-03-17', 'gtaskpurple',  '',                 0, 'Brian',    30,    0,      3,       1,     '',      'Caption 1','',   g));
                		g.AddTaskItem(new JSGantt.TaskItem(32,  'Calculate Chart Size', '2014-03-15','2014-03-24', 'gtaskgreen',   '',                 0, 'Shlomy',   40,    0,      3,       1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(33,  'Draw Task Items',      '',           '',          'ggroupblack',  '',                 0, 'Someone',  40,    2,      3,       1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(332, 'Task Label Table',     '2014-03-06','2014-03-09', 'gtaskblue',    '',                 0, 'Brian',    60,    0,      33,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(333, 'Task Scrolling Grid',  '2014-03-11','2014-03-20', 'gtaskblue',    '',                 0, 'Brian',    0,     0,      33,      1,     '332',   '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(34,  'Draw Task Bars',       '',           '',          'ggroupblack',  '',                 0, 'Anybody',  60,    1,      3,       0,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(341, 'Loop each Task',       '2014-03-26','2014-04-11', 'gtaskred',     '',                 0, 'Brian',    60,    0,      34,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(342, 'Calculate Start/Stop', '2014-04-12','2014-05-18', 'gtaskpink',    '',                 0, 'Brian',    60,    0,      34,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(343, 'Draw Task Div',        '2014-05-13','2014-05-17', 'gtaskred',     '',                 0, 'Brian',    60,    0,      34,      1,     '',      '',      '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(344, 'Draw Completion Div',  '2014-05-17','2014-06-04', 'gtaskred',     '',                 0, 'Brian',    60,    0,      34,      1,     "342,343",'',     '',      g));
                		g.AddTaskItem(new JSGantt.TaskItem(35,  'Make Updates',         '2014-07-17','2015-09-04', 'gtaskpurple',  '',                 0, 'Brian',    30,    0,      3,       1,     '333',   '',      '',      g));

                		g.Draw();
                	} else {
                		alert("Error, unable to create Gantt Chart");
                	}

                        </script>

                        ~;

                        #print "<body onload='generate_gantt_chart()'>";
                        #print "</body></html>";
                        &footer();

}
elsif($cgi->param('action') eq 'view_profile_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);

    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                       print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >View Profile for user $myname :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Personal Details :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                      ~;
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("select first_name,last_name,emailid,title,locale,manager from resources where username='$myname';");
                         $sth->execute() || die "$DBI::errstr\n";
                         while (@resultset = $sth->fetchrow_array)
                         {
                           $first_name = $resultset[0];
                           $last_name = $resultset[1];
                           $email_id = $resultset[2];
                           $business_title = $resultset[3];
                           $user_locale = $resultset[4];
                           $manager_username = getfullname($resultset[5]);
                         }
                          #print "NAME IS [$name]";
                         $sth->finish();
                         $dbh->disconnect();
                        print "<tr><td class='TableCellText'>First Name</td><td class='TableCellText'>$first_name</td></tr>";
                        print "<tr><td class='TableCellText'>Last Name</td><td class='TableCellText'>$last_name</td></tr>";
                        print "<tr><td class='TableCellText'>Email ID</td><td class='TableCellText'>$email_id</td></tr>";
                        print "<tr><td class='TableCellText'>Business Title</td><td class='TableCellText'>$business_title</td></tr>";
                        print "<tr><td class='TableCellText'>Locale</td><td class='TableCellText'>$user_locale</td></tr>";
                        print "<tr><td class='TableCellText'>Manager</td><td class='TableCellText'>$manager_username</td></tr>";
                        print qq~
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <th class='TableColumnHeader' width=100% >Role Details :</th>
                      ~;
                         my @user_roles =();

                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("select user_role from user_roles where user_name='$myname';");
                         $sth->execute() || die "$DBI::errstr\n";
                         while (@resultset = $sth->fetchrow_array)
                         {
                           push(@user_roles,$resultset[0]);

                         }
                          #print "NAME IS [$name]";
                         $sth->finish();
                         $dbh->disconnect();

                         foreach (@user_roles)
                         {
                          print "<tr><td class='TableCellText'>$_</td></tr>";
                         }
                        print qq~
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <th class='TableColumnHeader' width=100% >Default Role Based Skillset Details :</th>
                      ~;

                         my @skills = ();
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("select skillset_name from skillset where role in (select user_role from user_roles where user_name='$myname');");
                         $sth->execute() || die "$DBI::errstr\n";
                         while (@resultset = $sth->fetchrow_array)
                         {
                           push(@skills,$resultset[0]);

                         }
                          #print "NAME IS [$name]";
                         $sth->finish();
                         $dbh->disconnect();

                         foreach (@skills)
                         {
                          print "<tr><td class='TableCellText'>$_</td></tr>";
                         }
                        
                        ###

                        print qq~
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <th class='TableColumnHeader' width=100% >Additional Skillset Details :</th>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td class='TableCellText'>Skillset Name</td><td class='TableCellText'>Skillset Type</td></tr>
                      ~;

                         my @skills = ();
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("SELECT user_skillset_desc,user_skillset_type FROM user_skillset WHERE user_name='$myname';");
                         $sth->execute() || die "$DBI::errstr\n";
                         while (@resultset = $sth->fetchrow_array)
                         {
                           #push(@skills,$resultset[0]);
                           print "<tr><td class='TableCellText'>$resultset[0]</td><td class='TableCellText'>$resultset[1]</td></tr>";

                         }
                          #print "NAME IS [$name]";
                         $sth->finish();
                         $dbh->disconnect();

                         #foreach (@skills)
                         #{
                         #print "<tr><td class='TableCellText'>$_</td></tr>";
                         #}

                        ###
                        print qq~
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <th class='TableColumnHeader' width=100% >Project Experience :</th>
                      ~;

                         my @projects = ();
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("select distinct(task_projname) from task_global where task_username='$myname' and task_projname is not null;");
                         $sth->execute() || die "$DBI::errstr\n";
                         while (@resultset = $sth->fetchrow_array)
                         {
                           push(@projects,$resultset[0]);
                         }

                         $sth->finish();
                         $dbh->disconnect();

                         foreach (@projects)
                         {
                          print "<tr><td class='TableCellText'>$_</td></tr>";
                         }
                        print qq~
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <th class='TableColumnHeader' width=100% ></th>
                        </table>
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'view_goals')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session_id = $session->id();
    &header($myname);
    print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    ~;
    print "<div id=Layer1 style='width:87%; height:80%; overflow: scroll;'>";
    print "<table width=87%  border='0' cellpadding='3'>";
    print "<th class='TableColumnHeader'  >2015 Automation Goals :[$session_id]</th>";
    print "</table>";
    print "<p></p><p></p>";

    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";     # start of goal table
    print "<tr><td class='TableColumnHeader' width='5%'></td><td class='TableColumnHeader' width='75%'><a name='goal_summary_section'>Goal</a></td><td class='TableColumnHeader' width='7.5%'>Creation Date</td><td class='TableColumnHeader' width='7.5%'>Target Date</td><td class='TableColumnHeader' width='5%'>Percentage Complete</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select goal_id,goal_name,goal_creation_date,goal_target_date,goal_percentage_complete from goals;");
    $sth->execute() || die "$DBI::errstr\n";

    while (@resultset = $sth->fetchrow_array)
    {
      $goal_id = $resultset[0];
      $goal_name = $resultset[1];
      $goal_creation_date = $resultset[2];
      $goal_target_date = $resultset[3];
      $goal_percentage_complete = calculate_goal_achieved_percentage($goal_id);
      #print "<tr><td colspan=2 class='TableColumnHeader' width='5%'>Goal ID</td><td class='TableColumnHeader' width='75%'>Goal Name</td><td class='TableColumnHeader' width='7.5%'>Goal Creation Date</td><td class='TableColumnHeader' width='7.5%'>Goal Target Date</td><td class='TableColumnHeader' width='5%'>Goal Percentage Complete</td></tr>";
      print "<tr><td class='TableCellText' width='5%'><a href='#$goal_id'>$goal_id</a></td><td class='TableCellText' width='75%'>$goal_name</td><td class='TableCellText' width='7.5%'>$goal_creation_date</td><td class='TableCellText' width='7.5%'>$goal_target_date</td><td class='TableCellText' width='5%'>$goal_percentage_complete</td></tr>";
    }

    print "</table>";
    print "<p></p><p></p>";

    #print "<tr><td class='TableColumnHeader'>Goal ID</td><td class='TableColumnHeader'>Goal Name</td><td class='TableColumnHeader'>Goal Creation Date</td><td class='TableColumnHeader'>Goal Target Date</td><td class='TableColumnHeader'>Goal Percentage Complete</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select goal_id,goal_name,goal_creation_date,goal_target_date,goal_percentage_complete from goals;");
    $sth->execute() || die "$DBI::errstr\n";

    while (@resultset = $sth->fetchrow_array)
    {
      $goal_id = $resultset[0];
      $goal_name = $resultset[1];
      $goal_creation_date = $resultset[2];
      $goal_target_date = $resultset[3];
      $goal_percentage_complete = calculate_goal_achieved_percentage($goal_id);
      print "<table width=87% border=0 cellpadding=3 width=350px border=1>";     # start of goal table
      #print "<tr><td colspan=2 class='TableColumnHeader' width='5%'>Goal ID</td><td class='TableColumnHeader' width='75%'>Goal Name</td><td class='TableColumnHeader' width='7.5%'>Goal Creation Date</td><td class='TableColumnHeader' width='7.5%'>Goal Target Date</td><td class='TableColumnHeader' width='5%'>Goal Percentage Complete</td></tr>";
      print "<tr><td class='TableColumnHeader' width='5%'>Goal ID</td><td class='TableColumnHeader' width='75%'>Goal Name</td><td class='TableColumnHeader' width='7.5%'>Goal Creation Date</td><td class='TableColumnHeader' width='7.5%'>Goal Target Date</td><td class='TableColumnHeader' width='5%'>Goal Percentage Complete</td></tr>";

      #print "<tr><td class='TableCellText'><img width=\"100%\" src=http://127.0.0.1/webapp/images/goals.png></td><td class='TableCellText' width='5%'>$goal_id</td><td class='TableCellText' width='75%'>$goal_name</td><td class='TableCellText' width='7.5%'>$goal_creation_date</td><td class='TableCellText' width='7.5%'>$goal_target_date</td><td class='TableCellText' width='5%'>$goal_percentage_complete</td></tr>";
      print "<tr><td class='TableCellText' width='5%'><a href='#goal_summary_section' name='$goal_id'>$goal_id</a></td><td class='TableCellText' width='75%'>$goal_name</td><td class='TableCellText' width='7.5%'>$goal_creation_date</td><td class='TableCellText' width='7.5%'>$goal_target_date</td><td class='TableCellText' width='5%'>$goal_percentage_complete</td></tr>";
      
      print "<tr><td class='TableColumnHeader' width='5%'>Milestone ID</td><td class='TableColumnHeader' width='75%'>Milestone Desc</td><td class='TableColumnHeader' width='10%'>Milestone Date</td><td colspan=2 class='TableColumnHeader' width='10%'>Milestone Achievement Status</td></tr>";
      #print "</table>";
      my $dbh1 = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
      my $sth1 = $dbh->prepare("select milestone_id,milestone_desc,milestone_date,milestone_achieved from milestone where goal_id=$goal_id ;");
      $sth1->execute() || die "$DBI::errstr\n";
      $risk_count = "";
      while (@resultset = $sth1->fetchrow_array)
      {
       $milestone_id = $resultset[0];
       $milestone_desc = $resultset[1];
       $milestone_date = $resultset[2];
       $milestone_achieved_status = $resultset[3];
       if($milestone_achieved_status eq "Yes")
       {
        #print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
        #print "<tr><td class='TableCellText'><img width=\"30%\" src=http://127.0.0.1/webapp/images/on_track.png></td><td class='TableCellText' width='5%'>$milestone_id</td><td class='TableCellText' width='75%'>$milestone_desc</td><td class='TableCellText' width='10%'>$milestone_date</td><td colspan=2 class='TableCellText' width='10%' >$milestone_achieved_status</td></tr>";
        print "<tr><td class='TableCellText' width='5%'>$milestone_id</td><td class='TableCellText' width='75%'>$milestone_desc</td><td class='TableCellText' width='10%'>$milestone_date</td><td colspan=2 class='TableCellText' width='10%' >$milestone_achieved_status</td></tr>";
        #print "</table>";
       }
       else
       {
        $risk_count = get_milestone_risk_count($milestone_id);
        if($risk_count==0)
        {
         #print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
         #print "<tr><td class='TableCellText'><img width=\"30%\" src=http://127.0.0.1/webapp/images/on_track.png></td><td class='TableCellText' width='5%'>$milestone_id</td><td class='TableCellText' width='75%' >$milestone_desc</td><td class='TableCellText' width='10%'>$milestone_date</td><td colspan=2 class='TableCellText' width='10%'>$milestone_achieved_status</td></tr>";
         print "<tr><td class='TableCellText' width='5%'>$milestone_id</td><td class='TableCellText' width='75%' >$milestone_desc</td><td class='TableCellText' width='10%'>$milestone_date</td><td colspan=2 class='TableCellText' width='10%'>$milestone_achieved_status</td></tr>";
         #print "</table>";
        }
        else
        {
         #print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
         #print "<tr><td class='TableCellText'><img width=\"30%\" src=http://127.0.0.1/webapp/images/risk.png></td><td class='TableCellText' width='5%'><font color=red>$milestone_id</font></a></td><td class='TableCellText' width='75%'><font color=red>$milestone_desc</font></td><td class='TableCellText' width='10%'><font color=red>$milestone_date</font></td><td colspan=2 class='TableCellText' width='10%'><font color=red>$milestone_achieved_status</font></td></tr>";
         print "<tr><td class='TableCellText' width='5%'><font color=red>$milestone_id</font></a></td><td class='TableCellText' width='75%'><font color=red>$milestone_desc</font></td><td class='TableCellText' width='10%'><font color=red>$milestone_date</font></td><td colspan=2 class='TableCellText' width='10%'><font color=red>$milestone_achieved_status</font></td></tr>";

         #print "</table>";
         #print "<table width=87% border=0 cellpadding=3 width=350px border=1>"; #start of risk table
         print "<tr><td class='TableColumnHeader' width='5%'>Risk Raised On</td><td class='TableColumnHeader' width='75%'>Risk Desc</td><td class='TableColumnHeader' width='7.5%'>Risk Raised By</td><td class='TableColumnHeader' width='7.5%'>Quantitatve Risk Val</td><td colspan=2 class='TableColumnHeader' width='5%'>Risk Mitigation Plan</td></tr>";

         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
         my $sth = $dbh->prepare("select risk_desc,risk_raise_date,risk_raised_by,risk_impact,risk_probability,risk_mitigation_plan from risk_register where risk_affecting_milestone = $milestone_id;");
         $sth->execute() || die "$DBI::errstr\n";
         $risk_count = 0;
         $risk_quantitative_value = 0;
         while (@resultset = $sth->fetchrow_array)
         {
          $risk_count++;
          $risk_desc = $resultset[0];
          $risk_raise_date = $resultset[1];
          $risk_raised_by = $resultset[2];
          $risk_impact = $resultset[3];
          $risk_probability = $resultset[4];
          $risk_mitigation_plan = $resultset[5];

          $risk_quantitative_value = ($risk_impact*$risk_probability);

          print "<tr><td class='TableCellText' width='5%'>$risk_raise_date</td><td class='TableCellText' width='75%'>$risk_desc</td><td class='TableCellText' width='7.5%'>$risk_raised_by</td><td class='TableCellText' width='7.5%'>$risk_quantitative_value</td><td colspan=2 class='TableCellText' width='5%'>$risk_mitigation_plan</td></tr>";
         }
         $sth->finish();
         $dbh->disconnect();
         #print "</table>"; # end or risk table
         print "<tr><td colspan=10 class='TableColumnHeader'></td></tr>";
        }
       }
      } # end of milestone loop
     $sth1->finish();
     $dbh1->disconnect();
     print "</table>"; #end of goal table
     print "<p></p><p></p>";
    }


      #print "NAME IS [$name]";
    $sth->finish();
    $dbh->disconnect();
    print qq~
    </table>
    <table width=87% border=0 cellpadding=3 width=350px border=1>
    <th class='TableColumnHeader' width=100% ></th>
    </table>
   </div>
   ~;
   print "</div>";
   print "<iframe name='iframe_a' style=height:380px;width:85.25%;  frameborder=0 scrolling=auto ></iframe>";
   &footer();
}

elsif($cgi->param('action') eq 'view_goal_progress')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    tie(%goals, Tie::IxHash);
    tie(%milestones, Tie::IxHash);
    tie(%milestone_details, Tie::IxHash);
    tie(%activities, Tie::IxHash);

    &header($myname);
    print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    ~;
    print "<div id=Layer1 style='width:87%; height:80%; overflow: scroll;'>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select goal_id,goal_name from goals;");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
      $goal_id = $resultset[0];
      $goal_name = $resultset[1];
      $goals{$goal_id} = $goal_name;
    }
     #print "NAME IS [$name]";
    $sth->finish();
    $dbh->disconnect();

     $count = 0;
     foreach $goal (keys %goals)
     {
       $count++;
       %milestones = ();
       %milestone_details = ();
       @milestones = ();

        #print "</table>";

        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
        my $sth = $dbh->prepare("select a.milestone_id,a.milestone_desc,a.milestone_date from milestone a, goals b where a.goal_id = b.goal_id and b.goal_id = $goal;");
        $sth->execute() || die "$DBI::errstr\n";
        while (@resultset = $sth->fetchrow_array)
        {
         $milestone_id = $resultset[0];
         $milestone_desc = $resultset[1];
         $milestone_date = $resultset[2];
         $milestones{$milestone_id} = $milestone_desc;
         $milestone_details{$milestone_id} = $milestone_date;
        }
        $sth->finish();
        $dbh->disconnect();

        @milestones = keys (%milestones);
         
         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";   #starting_goal_table
         print "<th class='TableColumnHeader' width=100% >Goal Details :</th>";
         print "<tr><td class='TableCellText'>$goals{$goal}</td></tr>";
         print "<tr><td>";  # Starting_goal_row_for_milestone_table


        foreach $milestone (keys %milestones)
        {
                     print "<table width=87% border=0 cellpadding=3 width=350px border=1>"; # starting_milestone_table
                     print "<tr><td class='TableColumnHeader' width=75%>MileStone Name</td><td class='TableColumnHeader'>MileStone Date</td></tr>";
                     print "<tr><td class='TableCellText' width=75%>$milestones{$milestone}</td><td class='TableCellText'>$milestone_details{$milestone}</td></tr>";
          #print "</table>";
                            print "<tr><td colspan=3>"; # Starting_milestone_row_for_activities_table
                            print "<table width=87% border=0 cellpadding=3 width=350px border=1>"; # starting_activity_table
                            print "<tr><td class='TableColumnHeader'>Activity Desc</td><td class='TableColumnHeader'>Planned Start Date</td><td class='TableColumnHeader'>Planned End Date</td><td class='TableColumnHeader'>Actual Start Date</td><td class='TableColumnHeader'>Actual End Date</td></tr>";


          my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
          my $sth = $dbh->prepare("select a.activity_id,a.activity_desc,b.activity_planned_start_date,b.activity_planned_end_date,b.activity_actual_start_date,b.activity_actual_end_date from activities a, activity_details b, milestone c where a.activity_id = b.id and b.milestone_id = c.milestone_id and b.milestone_id = $milestone;");
          $sth->execute() || die "$DBI::errstr\n";
          while (@resultset = $sth->fetchrow_array)
          {
           $activity_id = $resultset[0];
           $activity_desc = $resultset[1];
           $activity_planned_start_date = $resultset[2];
           $activity_planned_end_date = $resultset[3];
           $activity_actual_start_date = $resultset[4];
           $activity_actual_end_date = $resultset[5];
           $activities{$activity_id} = $activity_desc;
                                        print "<tr><td class='TableCellText'>$activity_desc</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_actual_start_date</td><td class='TableCellText'>$activity_actual_end_date</td></tr>";
          }
          #print "NAME IS [$name]";
          $sth->finish();
          $dbh->disconnect();


          print "<tr><td>"; #Starting_activity_row_for_tasks_table
          foreach $activity (keys %activities)
          {
            print "<table width=87% border=0 cellpadding=3 width=350px border=1>"; #starting_tasks_table
            print "<tr><td class='TableColumnHeader'>Task Desc</td><td class='TableColumnHeader'>Resource</td><td class='TableColumnHeader'>Task Status</td></tr>";

            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
            my $sth = $dbh->prepare("select a.task_comments,a.task_username,a.task_status from task_global a,activity_details b where a.activity_id = b.id and b.milestone_id = $milestone and a.activity_id = '$activity';");
            $sth->execute() || die "$DBI::errstr\n";
            while (@resultset = $sth->fetchrow_array)
            {
             $task_comments = $resultset[0];
             $task_username = $resultset[1];
             $task_status = $resultset[2];
             print "<tr><td class='TableCellText'>$task_comments</td><td class='TableCellText'>$task_username</td><td class='TableCellText'>$task_status</td></tr>";
            }
          #print "NAME IS [$name]";
            $sth->finish();
            $dbh->disconnect();

            print "</table>" # #closing_tasks_table

          }
          print "</td></tr>"; #closing_activity_row_for_tasks_table
          print "</table>";  #closing_activity_table
          print "</td></tr>"; # closing_milestone_row_for_activities_table
          print "</table>"; # closing_milestone_table

       }

        #$goal = undef;


        #print "</table>";  # closing_milestone_table.
        print "</td></tr>"; #  closing_goal_row_for_milestone_table

        print "</table>";  # closing_ goal_ table.

      }
      print "</table>";  # closing_ goal_ table.
      print qq~
      </table>
      <table width=87% border=0 cellpadding=3 width=350px border=1>
      <th class='TableColumnHeader' width=100% ></th>
      </table>
     </div>
     ~;
     &footer();
}
elsif($cgi->param('action') eq 'change_passcode_form')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'change_passcode_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }

                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          oldpasscode = document.getElementById("oldpasscode").value;
                          newpasscode = document.getElementById("newpasscode").value;
                          confirmnewpasscode = document.getElementById("confirmnewpasscode").value;

                          if(!oldpasscode)
                          {
                            alert("Please enter Old Password");
                            return(false);
                          }
                          if(!newpasscode)
                          {
                            alert("Please enter New Password");
                            return(false);
                          }
                          if(!confirmnewpasscode)
                          {
                            alert("Please confirm New Password");
                            return(false);
                          }
                          if(newpasscode!=confirmnewpasscode)
                          {
                            alert("New Passcode entry and Confirm new passcode entries are mismatching");
                            return(false);
                          }


                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Change User Passcode :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"265\" class='TableCellText'>Old Password</td><td class='TableCellText'><input type=password name=oldpasscode id=oldpasscode size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>New Password</td><td class='TableCellText'><input type=password name=newpasscode id=newpasscode size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Confirm Password</td><td class='TableCellText'><input type=password name=confirmnewpasscode id=confirmnewpasscode size=25></td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" onclick=" return formvalidate()" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'change_passcode_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    &header($myname);

    my $oldpasscode = $session->param("oldpasscode");
    my $newpasscode = $session->param("newpasscode");
    my $confirmnewpasscode = $session->param("confirmnewpasscode");


                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function test(objid)
                         {
                           var radio_button = document.getElementById(objid);
                           var radio_button_id = radio_button.getAttribute("id");

                           if(radio_button_id == "singlentry")
                           {
                             document.getElementById("singlentry").checked=true;
                             document.getElementById("durationentry").checked=false;

                             document.getElementById("div_form_duration_from").style.visibility='hidden';
                             document.getElementById("div_form_duration_to").style.visibility='hidden';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='hidden';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='hidden';
                             document.getElementById("div_form_single").style.visibility='visible';
                             document.getElementById("div_form_single_date").style.visibility='visible';


                           }
                           else if (radio_button_id == "durationentry")
                           {
                             document.getElementById("singlentry").checked=false;
                             document.getElementById("durationentry").checked=true;

                             document.getElementById("div_form_duration_from").style.visibility='visible';
                             document.getElementById("div_form_duration_to").style.visibility='visible';
                             document.getElementById("div_form_duration_from_dialog").style.visibility='visible';
                             document.getElementById("div_form_duration_to_dialog").style.visibility='visible';
                             document.getElementById("div_form_single").style.visibility='hidden';
                             document.getElementById("div_form_single_date").style.visibility='hidden';

                           }
                           else
                           {
                           }
                          }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >User Passcode Change Status :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         #my $sth = $dbh->prepare("SELECT password FROM resources where username='$myname';");
                         my $sth = $dbh->prepare("SELECT username FROM resources where username='$myname' and password=MD5('$oldpasscode');");
                         $sth->execute() || die "$DBI::errstr\n";
                         while ($resultset = $sth->fetchrow_array)
                         {
                          if($resultset eq $myname)
                          {
                            if($newpasscode eq $confirmnewpasscode)
                            {
                              $flag ="validation_success";
                            }
                            else
                            {
                              $flag = "disimilar_passcde_and_confirmpasscode";
                            }
                          }
                          else
                          {
                            $flag ="validation_failure";
                          }
                         }
                          #print "NAME IS [$name]";
                         $sth->finish();
                         $dbh->disconnect();

                        if($flag eq "validation_success")
                        {
                         my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                         my $sth = $dbh->prepare("UPDATE resources SET password=MD5('$newpasscode') where username='$myname';");
                         $sth->execute() || die "$DBI::errstr\n";
                         $sth->finish();
                         $dbh->disconnect();
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Passcode Changed Successfully</th>";
                         print "</table>";
                        }
                        elsif($flag eq "validation_failure")
                        {
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Passcode Change Failed</th>";
                         print "</table>";
                        }
                        elsif($flag eq "disimilar_passcde_and_confirmpasscode")
                        {
                         print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                         print "<th class='TableColumnHeader' width=\"100%\">Passcode Change Failed</th>";
                         print "<tr><td class='TableCellText' >Passcode and Confirm Passcode is different</td></tr>";
                         print "</table>";
                        }
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'insert_roles_into_db')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");


    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'insert_roles_into_db_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Insert Roles Into DB :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"265\" class='TableCellText'>Role Name</td><td class='TableCellText'><input type=text name=rolename id=rolename size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Role Description</td><td class='TableCellText'><input type=text name=roledesc id=roldedesc size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Role Domain</td><td class='TableCellText'><input type=text name=roledomain id=roledomain size=25></td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'insert_roles_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->clear(["action"]);

    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Insert Roles Into DB  Status:</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                       $rolename = $session->param("rolename");
                       $roledesc = $session->param("roldedesc");
                       $roledomain = $session->param("roledomain");

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT rolename FROM job_role WHERE rolename='$rolename';");
                       $sth->execute() || die "$DBI::errstr\n";
                       while ($resultset = $sth->fetchrow_array)
                        {
                          if($resultset eq $rolename)
                          {
                            $flag = "already_exists";
                          }
                        }
                       $sth->finish();
                       $dbh->disconnect();


                       if($flag eq "already_exists")
                       {
                         print "<table width=87%  border='0' cellpadding='3'>";
                         print "<th class='TableColumnHeader' width=\"100%\"><font color=red>Failure</font></th>";
                         print "<tr><td>Role $rolename Already Exists In DB</td></tr>";
                         print "</table>";
                       }
                       else
                       {
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("INSERT INTO job_role (rolename,roledesc,role_domain) VALUES ('$rolename','$roledesc','$roledomain');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=\"100%\"><font color=green>Success</font></th>";
                       print "<tr><td>Role $rolename Successfully Inserted into DB</td></tr>";
                       print "</table>";


                       }
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'insert_skillset_into_db')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'insert_skillset_into_db_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        
                        my $rolehashref = getroles();
                        my %allroles =  %$rolehashref;


                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Insert Skillset Into DB :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"265\" class='TableCellText'>Skillset Name</td><td class='TableCellText'><input type=text name=skillsetname id=skillsetname size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Skillset Description</td><td class='TableCellText'><input type=text name=skillsetdesc id=skillsetdesc size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Skillset For Role</td><td style="width:50;">
                                <select name=skillsetrole>
                                ~;

                                foreach $key (keys %allroles)
                                {
                                 print "<option value='$key'>$key</option>";
                                 }

                                 print qq~
                                </select>
                                </td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Skillset Type</td><td style="width:50;">
                                <select name=skillsettype>
                                ~;
                                
                                my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                my $sth = $dbh->prepare("SELECT DISTINCT(user_skillset_type) FROM user_skillset;");
                                $sth->execute() || die "$DBI::errstr\n";
                                while ($resultset = $sth->fetchrow_array)
                                {
                                 print "<option value='$resultset'>$resultset</option>";
                                }
                                $sth->finish();
                                $dbh->disconnect();


                                print qq~
                                </select>
                          </td></tr>
                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'insert_skillset_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->clear(["action"]);

    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Skillset Insertion  Status:</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                       $skillsetname = $session->param("skillsetname");
                       $skillsetdesc = $session->param("skillsetdesc");
                       $skillsetrole = $session->param("skillsetrole");
                       $skillsettype = $session->param("skillsettype");

                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT skillset_name FROM skillset WHERE skillset_name='$skillsetname';");
                       $sth->execute() || die "$DBI::errstr\n";
                       while ($resultset = $sth->fetchrow_array)
                        {
                          if($resultset eq $skillsetname)
                          {
                            $flag = "already_exists";
                          }
                        }
                       $sth->finish();
                       $dbh->disconnect();


                       if($flag eq "already_exists")
                       {
                         print "<table width=87%  border='0' cellpadding='3'>";
                         print "<th class='TableColumnHeader' width=\"100%\"><font color=red>Failure</font></th>";
                         print "<tr><td>Skillset $skillsetname Already Exists In DB</td></tr>";
                         print "</table>";
                       }
                       else
                       {
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("INSERT INTO skillset (skillset_name,skillset_desc,role,skillset_type) VALUES ('$skillsetname','$skillsetdesc','$skillsetrole','$skillsettype');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=\"100%\"><font color=green>Success</font></th>";
                       print "<tr><td>Skillset $skillsetname Mapped Successfully Againt Role $skillsetrole</td></tr>";
                       print "</table>";


                       }
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'insert_project_into_db')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'insert_project_into_db_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        
                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("SELECT DISTINCT(proj_type) FROM projects;");
                        $sth->execute() || die "$DBI::errstr\n";
                        while (@resultset = $sth->fetchrow_array)
                        {
                          my $projtype = $resultset[0];
                          push(@projecttypes,$projtype);
                          #print "$task_details";
                        }
                        $sth->finish();
                        $dbh->disconnect();


                        #my $projecttypehashref = getprojects();
                        #my %allprojecttypes =  %$projecttypehashref;


                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Insert Project Into DB :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr><td width=\"265\" class='TableCellText'>Project Name</td><td class='TableCellText'><input type=text name=projectname id=projectname size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Project Description</td><td class='TableCellText'><input type=text name=projectdesc id=projectdesc size=25></td></tr>
                        <tr><td width=\"265\" class='TableCellText'>Project Type</td><td style="width:50;">
                                <select name=projecttype>
                                ~;

                                #foreach $key (keys %allprojecttypes)
                                foreach $projtype (@projecttypes)
                                {
                                 print "<option value='$projtype'>$projtype</option>";
                                 }

                                 print qq~
                                </select>
                                </td></tr>
                            </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Form\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'insert_project_into_db_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->clear(["action"]);

    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Project Insertion  Status:</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;


                       $projectname = $session->param("projectname");
                       $projectdesc = $session->param("projectdesc");
                       $projecttype = $session->param("projecttype");


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT projname FROM projects WHERE projname='$projectname';");
                       $sth->execute() || die "$DBI::errstr\n";
                       while ($resultset = $sth->fetchrow_array)
                        {
                          if($resultset eq $projectname)
                          {
                            $flag = "already_exists";
                          }
                        }
                       $sth->finish();
                       $dbh->disconnect();


                       if($flag eq "already_exists")
                       {
                         print "<table width=87%  border='0' cellpadding='3'>";
                         print "<th class='TableColumnHeader' width=\"100%\"><font color=red>Failure</font></th>";
                         print "<tr><td>Project $projectname Already Exists In DB</td></tr>";
                         print "</table>";
                       }
                       else
                       {
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("INSERT INTO projects (projname,projdesc,proj_type) VALUES ('$projectname','$projectdesc','$projecttype');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
                       
                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=\"100%\"><font color=green>Success</font></th>";
                       print "<tr><td>Project $projectname Successfully Inserted Into DB</td></tr>";
                       print "</table>";


                       }
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'log_a_bug')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'log_a_bug_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;

                        @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
                        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
                       ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
                        $year = 1900 + $yearOffset;
                        $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;


                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("SELECT count(*),max(bug_id) from bugs;");
                        $sth->execute() || die "$DBI::errstr\n";
                        while (@resultset = $sth->fetchrow_array)
                        {
                          if($resultset[0]==0)
			  {
			    $curr_bug_id = 1;							  
			  }
			  else
			  {		
			   $curr_bug_id = $resultset[1] + 1;	  
			  }
                        }
                       $sth->finish();
                       $dbh->disconnect();
			
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Bug Details :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                            <tr><td width=\"265\" class='TableCellText'>Bug ID</td><td class='TableCellText'><input type=text readonly=readonly value='$curr_bug_id' name=bugid id=bugid size=25></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>Bug Logger</td><td class='TableCellText'><input type=text readonly=readonly value='$myname' name=buglogger id=buglogger size=25></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>Bug Logged On</td><td class='TableCellText'><input type=text readonly=readonly name=buglogdate id=buglogdate value='$dbdate' size=25></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>Bug Description</td><td class='TableCellText'><input type=text name=bugdesc id=bugdesc size=75></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>Bug Status</td>
                                <td class='TableCellText'>
                                    <select name=bugstatus>
                                            <option value='open'>Open</option>
                                    </select>
                                </td>
                            </tr>
                            <tr><td width=\"265\" class='TableCellText'>Bug Severity</td>
                                <td class='TableCellText'>
                                    <select name=bugseverity>
                                            <option value='sev1'>Sev 1</option>
                                            <option value='sev2'>Sev 2</option>
                                            <option value='sev3'>Sev 3</option>
                                    </select>
                                </td>
                            </tr>
                        </table>
                        <table width=87%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=100% >Steps To Reproduce :</th>
                            <tr>
                                <td class='TableCellText'>
                                <textarea rows=20 cols=100 name=bugdetails id=bugdetails ></textarea>
                                </td>
                            </tr>


                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Submit Bug\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'log_a_bug_submit')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->clear(["action"]);

    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Project Insertion  Status:</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        ~;

                       $bugid = $session->param("bugid");
                       $buglogger = $session->param("buglogger");
                       $buglogdate = $session->param("buglogdate");
                       $bugseverity = $session->param("bugseverity");
                       $bugdetails = $session->param("bugdetails");
                       $bugstatus = $session->param("bugstatus");
                       $bugdesc = $session->param("bugdesc");


                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("INSERT INTO bugs (bug_id,bug_logger,bug_logdate,bug_severity,bug_details,bug_status,bug_desc) VALUES ($bugid,'$buglogger','$buglogdate','$bugseverity','$bugdetails','$bugstatus','$bugdesc')");
                       $sth->execute() || die "$DBI::errstr\n";
                       $sth->finish();
                       $dbh->disconnect();

                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=\"100%\"><font color=green>Bug Submission Status </font></th>";
                       print "<tr><td>Bug with ID $bugid Submitted <font color=green>Successfuly</font></td></tr>";
                       print "</table>";

                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($cgi->param('action') eq 'view_a_bug')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");

    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'view_bug_body');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;

                        @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
                        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
                       ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
                        $year = 1900 + $yearOffset;
                        $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;



                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Bug Details :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        <tr class='TableColumnHeader' ><td>Bug ID</td><td>Bug Logger</td><td>Bug Severity</td><td>Bug Status</td><td>Bug Description</td></tr>
                        ~;

                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("SELECT bug_id,bug_logger,bug_severity,bug_status,bug_desc from bugs;");
                        $sth->execute() || die "$DBI::errstr\n";
                        while (@resultset = $sth->fetchrow_array)
                        {
                          $bug_id = $resultset[0];
                          $bug_logger = $resultset[1];
                          $bug_severity = $resultset[2];
                          $bug_status = $resultset[3];
                          $bug_desc = $resultset[4];
                          print "<tr><td class='TableCellText'><a target='iframe_a' href='http://127.0.0.1:80/webapp/reshome.pl?defectid=$bug_id'>$bug_id</a></td><td class='TableCellText'>$bug_logger</td><td class='TableCellText'>$bug_severity</td><td class='TableCellText'>$bug_status</td><td class='TableCellText'>$bug_desc</td></tr>";

                        }
                       $sth->finish();
                       $dbh->disconnect();


                        print qq~
                        </table>
                        </div>
                        <div>
                        <iframe name='iframe_a' style=height:400px;width:87%;  frameborder=0 scrolling=auto ></iframe>
                        </div>
                       ~;
                       &footer();
}
elsif($session->param('action') eq 'view_bug_body')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");


                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }

                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;
                        $defectid = $session->param("defectid");
                        print qq~
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                      <th class='TableColumnHeader' width=100% >Bug Body :</th>
                      </table>


                        ~;



                       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                       my $sth = $dbh->prepare("SELECT bug_details FROM bugs WHERE bug_id=$defectid;");
                       $sth->execute() || die "$DBI::errstr\n";
                       while ($resultset = $sth->fetchrow_array)
                       {
                        $bug_details = $resultset;
                       }
                       $sth->finish();
                       $dbh->disconnect();



                       print qq~
                       <div align=center>
                       <table width=87%  border='0' cellpadding='3'>

                            <tr>
                                <td class='TableCellText'>
                                <textarea readonly=readonly rows=20 cols=100 name=bugbody id=bugbody >$bug_details</textarea>
                                </td>
                            </tr>


                        </table>
                       </div>
                       ~;

}
elsif($cgi->param('action') eq 'send_feedback')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'send_feedback_submit');
    &header($myname);
                        print qq~
                        <script language="javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        
                        function formvalidate()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          if(resourcename_val=="")
                          {
                            alert("Please select a resourcename from drop down");
                          }

                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           //alert("["+singledayField_val+"]")
                           if(singledayField_val=="")
                           {
                            alert("Please select a date");
                            window.location.reload();
                           }
                          }
                          else if(document.getElementById("durationentry").checked == true)
                          {
                           durationfrom_Field_val = document.getElementById("durationfromField").value;
                           durationto_Field_val = document.getElementById("durationtoField").value;
                           if((durationfrom_Field_val=="" ) || (durationto_Field_val==""))
                           {
                            alert("Please select From and To dates");
                            window.location.reload();
                           }
                          }

                        }
                        </script>
                        ~;

                        @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
                        @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
                       ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
                        $year = 1900 + $yearOffset;
                        $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;

                        my $from_email_id = getemailid($myname);
                        my $to_email_id = "saurabh.mitra\@amadeus.com";


                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <form id=timecardentry action="reshome.pl" method="post">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Email Feedback / Suggestions :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                            <tr><td width=\"265\" class='TableCellText'>From </td><td class='TableCellText'><input type=text readonly=readonly value='$from_email_id' name=mailfrom id=mailfrom size=25></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>To</td><td class='TableCellText'><input type=text readonly=readonly value='$to_email_id' name=mailto id=mailto size=25></td></tr>
                            <tr><td width=\"265\" class='TableCellText'>Subject</td><td class='TableCellText'><input type=text name=mailsubject id=mailsubject size=88></td></tr>
                        </table>
                        <table width=87%  border='0' cellpadding='3'>
                        <th class='TableColumnHeader' width=100% >Mail Body :</th>
                            <tr>
                                <td class='TableCellText'>
                                <textarea rows=20 cols=100 name=mailbody id=mailbody ></textarea>
                                </td>
                            </tr>


                        </table>

                       <table width=87%  border='0' cellpadding='3'>
                       <tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Send E-Mail\" /></td>
                       <td align='center' border=0 cellpadding=3><input type=button class=TableCellIconButton value=\"Clear Form\" onclick="formReset()" /></td>
                       </tr>
                       </table>
                       </form>
                       </div>
                       ~;
                       &footer();
}
elsif($session->param("action") eq "send_feedback_submit")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->load_param($cgi);
    $session->clear(["action"]);

    @parameters = $cgi->param();

    $mailfrom = $session->param("mailfrom");
    $mailto = $session->param("mailto");
    $mail_subject = $session->param("mailsubject");
    $mail_body = $session->param("mailbody");


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'></th>";
    print "</table>";

    $msg = MIME::Lite->new(
        From     => $mailfrom,
        To       => $mailto,
        Subject  => $mail_subject,
        Type     => 'multipart/mixed',
    );

    $message_body = "<html><head><title>Resource Tool Feedback</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1+\"></head><body marginwidth=\"0\" marginheight=\"0\">";
    

    $message_body = $message_body . "<table border='0' cellpadding='3'><tr class='TableColumnHeader' width=\"100%\">";
    $message_body = $message_body . "<tr><td><font face=\"Arial, Helvetica, sans-serif\" size=\"-1\">$mail_body</font></td></tr>";
    $message_body = $message_body . "</table>";


    #### Sending the mail
    $msg->attach(
         Type     => 'text/html',
         Data     => $message_body
    );

   $msg->send('smtp','smtp.office365.com', Debug=>1 ); # send via default


    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader' width=100%>Thank you for your valuable feedback</th>";
    print "</table>";
    print "</div>";
    &footer();
}




sub getfullnametitle()
{
   my $user_array_ref = @_[0];
   my $resultset = "";
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();
   my $role = "";
   my $query = "";

   my @passeduserslist = @$user_array_ref;

   foreach $passeduser(@passeduserslist)
   {
       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
       my $sth = $dbh->prepare("SELECT username,first_name,last_name,title FROM resources WHERE username='$passeduser';");
       $sth->execute() || die "$DBI::errstr\n";
       while (@resultset = $sth->fetchrow_array)
        {
          my $username = $resultset[0];
          my $first_name = $resultset[1];
          my $last_name = $resultset[2];
          my $title = $resultset[3];
          my $name_title = $first_name . " " . $last_name . " - ". $title;
          $returnhash{$username} = $name_title;
        }
       $sth->finish();
       $dbh->disconnect();
   }
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}


sub getusers()
{
   my $name = @_[0];
   my $resultset = "";
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();
   my $role = "";
   my $query = "";

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT role FROM resources where username='$name'");
   $sth->execute() || die "$DBI::errstr\n";
   while ($resultset = $sth->fetchrow_array)
   {
    if($resultset eq "admin")
    {
      $query = "SELECT username,first_name,last_name,title FROM resources;";
    }
    else
    {
      $query = "SELECT username,first_name,last_name,title FROM resources where username='$name';";
    }
   }
    #print "NAME IS [$name]";
   $sth->finish();
   $dbh->disconnect();


   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("$query");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $username = $resultset[0];
      my $first_name = $resultset[1];
      my $last_name = $resultset[2];
      my $title = $resultset[3];
      my $name_title = $first_name . " " . $last_name . " - ". $title;
      $returnhash{$username} = $name_title;
    }
   $sth->finish();
   $dbh->disconnect();
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}


sub checkadmin()
{
   my $name = @_[0];
   my $resultset = "";
   my $role = "";

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT role FROM resources where username='$name'");
   $sth->execute() || die "$DBI::errstr\n";
   while ($resultset = $sth->fetchrow_array)
   {
    $role = $resultset;
   }
   #print "NAME IS [$name]";
   $sth->finish();
   $dbh->disconnect();
   return($role);
}

# sub header()
# {
#   # New Header
#   my $myname =  @_[0];
#   my $role = "";
#   my $resultset = "";
# 
#   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#   my $sth = $dbh->prepare("SELECT role FROM resources where username='$myname'");
#   $sth->execute() || die "$DBI::errstr\n";
#   while ($resultset = $sth->fetchrow_array)
#   {
#    $role = $resultset;
#   }
#    #print "NAME IS [$name]";
#   $sth->finish();
#   $dbh->disconnect();
# 
#   if($role eq "admin")
#   {
#     $usercolor = "red";
#   }
#   else
#   {
#     $usercolor = "blue";
#   }
# 
# 
#   print "<html>\n";
#   print "<head>\n";
#   print "<title>QA Resourcing : Time Card Entry </title>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/.css type=text/css>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/jsDatePick_ltr.min.css>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/site.css type=text/css>\n";
#   print "<style type=\"text/css\" media=print></style></head>\n";
#   print "<script src=http://127.0.0.1/webapp/javascript/jsDatePick.min.1.3.js></script>\n";
#   print qq~
#   <script type=text/javascript>
#    function open_win(url)
#    {
#     window.open(url);
#     }
#   
#   </script>
# 
#   ~;
#   print "<div id=\"header\">\n";
#   print "<div class=\"wrap\">\n";
#   print "<div class=\"logo\"><img src=http://127.0.0.1/webapp/images/pogo_header.png></div>\n";
#   print "<p></p>\n";
#   print "</div></div>\n";
#   print "<div id=breadcrumbs>";
#   #print "<div class=xright>";
#   print "<a href=http://127.0.0.1:80/webapp/reshome.pl?action=home><font GlobalLink:active'>Home</font></a>  |  <a href=http://127.0.0.1:80/webapp/login.pl?action=logout><font color='$usercolor'>$myname&nbsp;&nbsp;</font> Logout</a>";
# 
#   print "<table width='100%' align='left' border='1' cellpadding='3'>";
#   print  "<th class='TableColumnHeader' width='100%'><marquee> </font> Welcome <font color=green>$myname </font> To <font color='blue'><b>SaMTrack</b></font><font color='red'><b> Ver 1.0</b></font></marquee></th>";
#  print "</table>";
# 
#   print "</div>";
#   print "<div class=clear><hr /></div></div>";
#   print "<div id=leftColumn>";
#   print "<div id=navcolumn>";
#   print "<h5><b>Time Card<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=capture_timecard'>Enter Time Card</a></li>";
#   print "<li><a href='reshome.pl?action=edit_timecard_form'>Edit Time Card</a></li>";
#   print "<li><a href='reshome.pl?action=view_timecard_form'>View Time Card</a></li>";
#   print "</ul>";
#   print "<h5>My Profile</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=add_skillset_form'>Request Skillset Update</a></li>";
#   print "<li><a href='reshome.pl?action=change_passcode_form'>Change Password</a></li>";
#   print "</ul>";
#   print "<h5>My Reports</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=view_profile_form'>View Profile</a></li>";
#   print "<li><a href='reshome.pl?action=workload_search'>View Workload</a></li>";
#   print "<li><a href='display_workload.pl?action=daily_status_report'>Preview Daily Status Report</a></li>";
#   print "</ul>";
#   print "<h5>Search</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=resource_lookup'>Search Resource</a></li>";
#   print "</ul>";
# 
#   if($role eq "admin")
#   {
#    print "<h5>Admin</h5>";
#    print "<ul>";
#    print "<li><a href='reshome.pl?action=register_user_form'>Register User</a></li>";
#    print "<li><a href='reshome.pl?action=insert_roles_into_db'>Add Role</a></li>";
#    print "<li><a href='reshome.pl?action=insert_skillset_into_db'>Add Skillset</a></li>";
#    print "<li><a href='reshome.pl?action=insert_project_into_db'>Add Projects</a></li>";
#    print "</ul>";
#   }
# 
#   print "<h5>Support</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=log_a_bug'>Log a Bug</a></li>";
#   print "<li><a href='reshome.pl?action=view_a_bug'>View Bugs</a></li>";
#   print "<li><a href='reshome.pl?action=send_feedback'>Send Feedback / Suggestions</a></li>";
#   print "</ul>";
# 
# 
# 
# }

# sub footer()
# {
#   print "<div class=clear>";
#   print "<hr />";
#   print "</div>";
#   print "<div id=footer>";
#   print "<div class=xright>&#169; <dotj:date outformat=yyyy /> - QA</div>";
#   print "<div class=clear><hr /></div></div>";
#   print "</body>";
#   print "</head>";
#   print "</html>";
# }

sub gettaskcat()
{
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT taskcatname,taskcattype FROM taskcat;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $taskcatame = $resultset[0];
      my $taskcattype = $resultset[1];
      my $task_details = $taskcatame . "-" . $taskcattype;
      $returnhash{$task_details} = $taskcatame;
      #print "$task_details";
    }
   $sth->finish();
   $dbh->disconnect();
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}
sub gettaskcategory()
{
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT taskcatname,taskcattype FROM taskcat;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $taskcatname = $resultset[0];
      my $taskcattype = $resultset[1];
      $returnhash{$taskcatname} = $taskcattype;
      #print "$task_details";
    }
   $sth->finish();
   $dbh->disconnect();
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}


sub getprojects()
{
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();

   tie(%returnhash, Tie::IxHash);

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT projname,proj_type FROM projects ORDER BY projname ASC;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $projname = $resultset[0];
      my $projtype = $resultset[1];
      $returnhash{$projname} = $projtype;
      #print "$task_details";
    }
   $sth->finish();
   $dbh->disconnect();
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}

sub getskillset()
{
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT skillset_name,proj_type FROM projects;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $projname = $resultset[0];
      my $projtype = $resultset[1];
      $returnhash{$projname} = $projtype;
      #print "$task_details";
    }
   $sth->finish();
   $dbh->disconnect();
   my $returnhash_ref = \%returnhash;
   return($returnhash_ref);
}

sub getsubordinates()
{
   my $mgrname = @_[0];
   my @resultset = ();
   my %returnhash = ();
   my $returnhash_ref = ();
   my @subordinates = ();
   my $name = "";
   my $subordinates_array_length = "";


   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT username FROM resources WHERE manager='$mgrname' order by username asc;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      push(@subordinates,$resultset[0]);
    }
   $sth->finish();
   $dbh->disconnect();

   $subordinates_array_length = scalar(@subordinates);

   if ($subordinates_array_length<=0)
   {

   }
   else
   {
    foreach $name (@subordinates)
    {
     push(@final_sub_list,$name);
     #print("$name\n");
     getsubordinates($name);
    }
   }

}

sub getskillsetagainstroles()
{
  my $name_array_ref = @_[0];
  my @resultset = ();
  my %skillsethash = ();
  my $skillsethash_ref = ();
  my $name = "";
  my @passed_user_list = ();

  @passed_user_list = @$name_array_ref;
  
  foreach $name(@passed_user_list)
  {
   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT skillset_name FROM skillset WHERE role IN (SELECT user_role FROM user_roles WHERE user_name='$name');");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      if(not exists $skillsethash{$resultset[0]})
      {
       $skillsethash{$resultset[0]} = $name;
      }
    }
   $sth->finish();
   $dbh->disconnect();
  }
  $skillsethash_ref = \%skillsethash;
  return($skillsethash_ref);
}


sub getroles()
{

  my @resultset = ();
  my %role_list = ();
  my $role_list_ref = ();

   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT rolename FROM job_role;");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
     $role_list{$resultset[0]} = "";
    }
   $sth->finish();
   $dbh->disconnect();

  $role_list_ref = \%role_list;
  return($role_list_ref);
}


sub getfullname()
{
  my $name = @_[0];
  
  my @resultset = ();
  my $full_name = "";
  my $first_name = "";
  my $last_name = "";


  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
  my $sth = $dbh->prepare("SELECT first_name,last_name FROM resources WHERE username='$name';");
  $sth->execute() || die "$DBI::errstr\n";

  while (@resultset = $sth->fetchrow_array)
  {
   $first_name = $resultset[0];
   $last_name = $resultset[1];
   $full_name = $first_name . " " . $last_name;
  }
  $sth->finish();
  $dbh->disconnect();
  return($full_name);
}

sub getemailid()
{
  my $name = @_[0];
  my @resultset = ();
  

  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
  my $sth = $dbh->prepare("SELECT emailid FROM resources WHERE username='$name';");
  $sth->execute() || die "$DBI::errstr\n";

  while ($resultset = $sth->fetchrow_array)
  {
   $email = $resultset;   
  }
  $sth->finish();
  $dbh->disconnect();
  return($email);
}

sub gettodaysdate()
{
my @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
my $year = 1900 + $yearOffset;
my $date = $year ."-" . $months[$month] ."-" . $dayOfMonth;
my $current_date = "";

my $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";
my $month = $month + 1;



 if($month=~/^\d$/)
 {
  $month = "0" . $month;
 }
 if($dayOfMonth=~/^\d$/)
 {
  $dayOfMonth = "0" . $dayOfMonth;
  }



$current_date = $year . "-". $month . "-" . $dayOfMonth;
return($current_date);
}


sub convert_jquerydate_to_mysql_date()
{
my $jquery_date = @_[0];

%months = ( "JAN" , "01",
                                  "FEB" , "02",
                                  "MAR",  "03",
                                  "APR" , "04",
                                  "MAY" , "05",
                                  "JUN",  "06",
                                  "JUL" , "07",
                                  "AUG" , "08",
                                  "SEP",  "09",
                                  "OCT" , "10",
                                  "NOV" , "11",
                                  "DOC",  "12");

if($jquery_date=~/(\d+)-(.*)-(\d+)/)
{
  $today = $1;
  $tomonth_alphabetic = $2;
  $tomonth = $months{$tomonth_alphabetic};
  $toyear = $3;

}

$mysql_date = $toyear . "-" . $tomonth . "-" .  $today;
return($mysql_date);
}


sub calculate_activity_completion_percentage()
{
 my $activity_id = @_[0];
 my $activity_percentage = "";

 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 my $sth = $dbh->prepare("SELECT task_percentage_complete FROM task_global where activity_id = '$activity_id';");
 $sth->execute() || die "$DBI::errstr\n";
 my $task_count =  0;
 my $aggregrate_percentage = 0;
 while (@resultset = $sth->fetchrow_array)
 {
    $task_percentage = $resultset[0];
    $aggregrate_percentage = $aggregrate_percentage + $task_percentage;
    $task_count++;
 }
$sth->finish();
$dbh->disconnect();

 $activity_percentage = ($aggregrate_percentage/$task_count);
 return($activity_percentage);
}

sub calculate_goal_completion_percentage()
{
 my $goal_id = @_[0];
 my $goal_percentage = "";

 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 #my $sth = $dbh->prepare("select b.activity_percentage_complete from activities a, activity_details b where a.activity_id = b.id and a.goal_id = $goal_id ;");
 my $sth = $dbh->prepare("select b.activity_percentage_complete from activities a, activity_details b where a.activity_id = b.id and a.goal_id = '$goal_id' ;");

 $sth->execute() || die "$DBI::errstr\n";
 my $activity_count =  0;
 my $aggregrate_activity_percentage = 0;
 while (@resultset = $sth->fetchrow_array)
 {
    $activity_percentage = $resultset[0];
    $aggregrate_activity_percentage = $aggregrate_activity_percentage + $activity_percentage;
    $activity_count++;
 }
$sth->finish();
$dbh->disconnect();

 $goal_percentage = ($aggregrate_activity_percentage/$activity_count);
 return($goal_percentage);
}

sub calculate_goal_achieved_percentage()
{
 my $goal_id = @_[0];
 my $goal_percentage = "";

 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 #my $sth = $dbh->prepare("select b.activity_percentage_complete from activities a, activity_details b where a.activity_id = b.id and a.goal_id = $goal_id ;");
 my $sth = $dbh->prepare("select milestone_achieved from milestone where goal_id = '$goal_id' ;");
 $sth->execute() || die "$DBI::errstr\n";
 my $milestone_count =  0;
 my $milestone_achieved_count = 0;

 while (@resultset = $sth->fetchrow_array)
 {
    $milestone_achieved = $resultset[0];
    $milestone_count++;
    if($milestone_achieved eq "Yes")
    {
     $milestone_achieved_count = $milestone_achieved_count + 1;
    }
 }
$sth->finish();
$dbh->disconnect();

 if($milestone_achieved_count==0)
 {
  $goal_percentage = 0;
 }
 else
 {
   $goal_percentage = (($milestone_achieved_count/$milestone_count)*100);
 }
 $goal_percentage   = ceil($goal_percentage);
 return($goal_percentage);
}

sub get_milestone_risk_count()
{
    my $milestone_id = @_[0];
    my $risk_count = "";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select id from risk_register where risk_affecting_milestone = $milestone_id;");
    $sth->execute() || die "$DBI::errstr\n";
    $risk_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $risk_count++
    }
   $sth->finish();
   $dbh->disconnect();

   return($risk_count);
}

sub update_project_xml()
{
 my $project_xml = @_[0];
 
 if(-e $project_xml)
 {
  system("rm -rf $project_xml");
 }

 my $output = IO::File->new(">$project_xml");
 my $writer = XML::Writer->new(OUTPUT => $output);

   $writer->startTag("project");



    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.id,a.activity_planned_start_date,a.activity_planned_end_date,b.activity_desc,a.activity_percentage_complete from activity_details a,activities b where a.id=b.activity_id;");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     $activity_id = $resultset[0];
     $activity_planned_start_date = $resultset[1];
     $activity_planned_end_date = $resultset[2];
     $activity_desc = $resultset[3];
     $activity_percentage_complete = $resultset[4];


     map {s/'/&quot;/g} $activity_desc;

     $writer->startTag("task");

     $writer->startTag("pID");
     $writer->characters($activity_id);
     $writer->endTag("pID");

     $writer->startTag("pName");
     $writer->characters($activity_desc);
     $writer->endTag("pName");

     $writer->startTag("pStart");
     $writer->characters($activity_planned_start_date);
     $writer->endTag("pStart");

     $writer->startTag("pEnd");
     $writer->characters($activity_planned_end_date);
     $writer->endTag("pEnd");

     $writer->startTag("pClass");
     $writer->characters("ggroupblack");
     $writer->endTag("pClass");

     $writer->startTag("pLink");
     $writer->characters("");
     $writer->endTag("pLink");

     $writer->startTag("pMile");
     $writer->characters("0");
     $writer->endTag("pMile");

     $writer->startTag("pRes");
     $writer->characters("");
     $writer->endTag("pRes");

     $writer->startTag("pComp");
     $writer->characters($activity_percentage_complete);
     $writer->endTag("pComp");

     $writer->startTag("pGroup");
     $writer->characters("1");
     $writer->endTag("pGroup");

     $writer->startTag("pParent");
     $writer->characters("0");
     $writer->endTag("pParent");

     $writer->startTag("pOpen");
     $writer->characters("1");
     $writer->endTag("pOpen");

     $writer->startTag("pDepend");
     $writer->characters("");
     $writer->endTag("pDepend");

     $writer->endTag("task");
    
    ### Task Details

    $task_id = "";
    $task_planned_start_date = "";
    $task_planned_end_date = "";
    $task_desc = "";
    $task_percentage_complete = "";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select task_id,task_date,task_enddate,task_comments,task_percentage_complete,task_depends_on,task_username from task_global where activity_id='$activity_id';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     $task_id = $resultset[0];
     $task_planned_start_date = $resultset[1];
     $task_planned_end_date = $resultset[2];
     $task_desc = $resultset[3];
     $task_percentage_complete = $resultset[4];
     $task_depends_on = $resultset[5];
     $task_user_name = $resultset[6];

     map {s/'/&quot;/g} $activity_desc;

     $writer->startTag("task");

     $writer->startTag("pID");
     $writer->characters($task_id);
     $writer->endTag("pID");

     $writer->startTag("pName");
     $writer->characters($task_desc);
     $writer->endTag("pName");

     $writer->startTag("pStart");
     $writer->characters($task_planned_start_date);
     $writer->endTag("pStart");

     $writer->startTag("pEnd");
     $writer->characters($task_planned_end_date);
     $writer->endTag("pEnd");

     $writer->startTag("pClass");
     $writer->characters("gtaskblue");
     $writer->endTag("pClass");

     $writer->startTag("pLink");
     $writer->characters("");
     $writer->endTag("pLink");

     $writer->startTag("pMile");
     $writer->characters("0");
     $writer->endTag("pMile");

     $writer->startTag("pRes");
     $writer->characters($task_user_name);
     $writer->endTag("pRes");

     $writer->startTag("pComp");
     $writer->characters($task_percentage_complete);
     $writer->endTag("pComp");

     $writer->startTag("pGroup");
     $writer->characters("0");
     $writer->endTag("pGroup");

     $writer->startTag("pParent");
     $writer->characters($activity_id);
     $writer->endTag("pParent");

     $writer->startTag("pOpen");
     $writer->characters("1");
     $writer->endTag("pOpen");

     $writer->startTag("pDepend");
     $writer->characters($task_depends_on);
     $writer->endTag("pDepend");

     $writer->endTag("task");
    }

     $activity_id = "";
     $activity_planned_start_date = "";
     $activity_planned_end_date = "";
     $activity_desc = "";
     $activity_percentage_complete = "";
    }

  $writer->endTag("project");

  $writer->end();
  $output->close();

   $sth->finish();
   $dbh->disconnect();

}



