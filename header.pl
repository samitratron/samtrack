#!c:/perl/bin/perl.exe
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Tie::IxHash;
use MIME::Lite;


sub header()
{
  # New Header
  my $myname =  @_[0];
  my $role = "";
  my $resultset = "";

  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
  my $sth = $dbh->prepare("SELECT role FROM resources where username='$myname'");
  $sth->execute() || die "$DBI::errstr\n";
  while ($resultset = $sth->fetchrow_array)
  {
   $role = $resultset;
  }
   #print "NAME IS [$name]";
  $sth->finish();
  $dbh->disconnect();

  if($role eq "admin")
  {
    $usercolor = "red";
  }
  else
  {
    $usercolor = "blue";
  }


  print "<html>\n";
  print "<head>\n";
  print "<title>SaMTrack</title>\n";
  print "<link rel='SHORTCUT ICON' href='http://127.0.0.1/webapp/images/favicon.ico'>";
  print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/my.css type=text/css>";
  print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/jsDatePick_ltr.min.css>";
  print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/site.css type=text/css>";
  print "<style type=\"text/css\" media=print></style></head>\n";
  print "<script src=http://127.0.0.1/webapp/javascript/jsDatePick.min.1.3.js></script>\n";
  print "<link rel='stylesheet' href='http://127.0.0.1/webapp/css/demo.css'>";
  print "<link rel='stylesheet' href='http://127.0.0.1/webapp/css/horizontal_menu.css'>";

  print "<script src='http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js'></script>";
  print "<script src='http://127.0.0.1/webapp/javascript/demo.js'></script>";

  print "<script type='text/javascript' src='http://127.0.0.1/webapp/javascript/jsgantt/jsgantt.js'></script>";
  print "<link rel='stylesheet' type='text/css' href='http://127.0.0.1/webapp/javascript/jsgantt/jsgantt.css'>";


  print qq~
  <script type=text/javascript>
   function open_win(url)
   {
    window.open(url);
    }
  
  </script>

  ~;
  print "<div id=\"header\" style=\"background-color:#cfe0f1;\">\n";
  #print "<div class=\"wrap\">\n";
  print "<div class=\"logo\"><img width=\"100%\" src=http://127.0.0.1/webapp/images/samtrack_header.png></div>\n";
  #print "<div class=\"logo\"><img src=http://127.0.0.1/webapp/images/rotating_earth.gif></div>\n";

  print "<p></p>\n";
  print "</div></div>\n";
  print "<body bgcolor=\"#cfe0f1\">";
  #print "<div id=breadcrumbs >";

  #print "<div class=xright>";
  print "<a href=http://127.0.0.1:80/webapp/reshome.pl?action=home><font GlobalLink:active'><b>Home</b></font></a>  |  <a href=http://127.0.0.1:80/webapp/login.pl?action=logout><font color='$usercolor'><b>Logout <font color='$usercolor'>[$myname] </font></b></font></a>";

  #print "<table width='100%' align='left' border='1' cellpadding='3'>";
  #print  "<th class='TableColumnHeader' width='100%'></font><font color='blue'><b>SaMTrack</b></font><font color='red'><b> Ver 1.0</b></font></th>";
  #print "</table>";
  print qq~
  <table width='100%' align='left' border='1' cellpadding='3'>
  </table>
  <table width='100%' align='left' border='0' cellpadding='3'>
  <tr>
  <td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>
  <td>
        <div align='right'>

        <ul class="menu">
		<li><a href="http://127.0.0.1/webapp/reshome.pl?action=home">HOME</a></li>
		<li><a href="#">REMINDERS</a></li>
		<li><a href="#">FAQ</a></li>
		<li><a href="#">ARTICLES</a></li>
	</ul>
        </div>
  </td></tr>
  </table>
  <table width='100%' align='left' border='1' cellpadding='3'>
  </table>


  ~;
  print "</div>";
  print "<div class=clear><hr /></div></div>";
  print "<div id=leftColumn >";
  print "<div id=navcolumn >";
  print qq~
  <div class="wrap">
	
	<ul class="goo-collapsible goo-coll-stacked">
		<li class='dropdown'><a class='' href='#'><span class='icon-table'></span>Goals</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=view_goals'>View 2015 Goals</a></li>
 		    </ul>
		</li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Milestone</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=insert_milestone'>Define Milestone</a></li>
		    <li ><a href='reshome.pl?action=search_milestone'>Retrieve Milestone</a></li>
   		    </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Risks</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=register_risk'>Register Risk</a></li>
		    <li ><a href='reshome.pl?action=unregister_risk'>Unregister Risk</a></li>
   		    </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Activity</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=insert_activity'>Submit Activity</a></li>
		    <li ><a href='reshome.pl?action=search_activity'>Retrieve Activity</a></li>
               	    <li ><a href='reshome.pl?action=view_daily_unassigned_activity'>Unassigned Activities</a></li>
		    <li ><a href='reshome.pl?action=unregister_risk'>Unregister Risk</a></li>
                   </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Tasks</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=capture_timecard'>Add Task</a></li>
		    <li ><a href='reshome.pl?action=edit_timecard_form'>Edit Task</a></li>
               	    <li ><a href='reshome.pl?action=view_timecard_form'>View Task</a></li>
		    <li ><a href='reshome.pl?action=mark_dependent_tasks'>Mark Dependent Task</a></li>
                    <li ><a href='reshome.pl?action=view_tasks_under_activity'>Tasks In An Activity</a></li>
                   </ul>
                </li>
                <li class='dropdown'><a href='reshome.pl?action=view_gantt_chart'><span class='icon-user'></span>Gantt Chart</a>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Reports</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=workload_search'>Workload</a></li>
		    <li ><a href='reshome.pl?action=view_goal_progress'>Goal Progress</a></li>
               	    <li ><a href='display_workload.pl?action=today_deadline'>Today's Deadline</a></li>
		    <li ><a href='display_workload.pl?action=delayed_activities'>Delayed Activities</a></li>
                    <li ><a href='display_workload.pl?action=weekly_status_report'>Weekly Status Report</a></li>
                    <li ><a href='display_workload.pl?action=current_milestone_report'>Milestone Report</a></li>
                   </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Resource</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=resource_lookup'>Resource Lookup</a></li>
   		    </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Resource</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=resource_lookup'>Resource Lookup</a></li>
   		    </ul>
                </li>
                <li class='dropdown'><a href='#'><span class='icon-user'></span>Profile</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=view_profile_form'>My Profile</a></li>
		    <li ><a href='reshome.pl?action=add_skillset_form'>Skillset Update Req</a></li>
               	    <li ><a href='reshome.pl?action=change_passcode_form'>Change Passcode</a></li>
                   </ul>
                </li>
              ~;
                 if($role eq "admin")
                   {
                    print "<li class='dropdown'><a href='#'><span class='icon-user'></span>Admin</a>";
                    print "<ul>";
                    print "<li><a href='reshome.pl?action=register_user_form'>Register User</a></li>";
                    print "<li><a href='reshome.pl?action=insert_roles_into_db'>Add Role</a></li>";
                    print "<li><a href='reshome.pl?action=insert_skillset_into_db'>Add Skillset</a></li>";
                    print "<li><a href='reshome.pl?action=insert_project_into_db'>Add Projects</a></li>";
                    print "<li><a href='reshome.pl?action=delete_activity_form'>Delete Activity</a></li>";
                    #print "<li><a href='reshome.pl?action=view_gantt_chart'>View Gantt Chart</a></li>";
                    #print "<li><a href='reshome.pl?action=view_advanced_gantt_chart'>View Gantt Chart</a></li>";
                    print "<li><a href='reshome.pl?action=link_activity_to_milestone'>Add Milestone</a></li>";
                    print "</ul>";
                    print "<li>";
                   }

              print qq~
               <li class='dropdown'><a href='#'><span class='icon-user'></span>Support</a>
        	    <ul>
            	    <li ><a href='reshome.pl?action=log_a_bug'>Log a Bug</a></li>
		    <li ><a href='reshome.pl?action=view_a_bug'>Bugs Logged List</a></li>
               	    <li ><a href='reshome.pl?action=send_feedback'>Send Feedback</a></li>
                   </ul>
                </li>

	</ul>

</div>
~;
#   print "<h5><b>Goals<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=view_goals'>View 2015 Goals</a></li>";
#   print "</ul>";
# 
#   print "<h5><b>Success Criteria<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=view_goals'>Success Criteria</a></li>";
#   print "<li><a href='reshome.pl?action=view_goals'>Success Data Points</a></li>";
#   print "</ul>";
# 
# 
#   print "<h5><b>Milestone<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=insert_milestone'>Define Milestone</a></li>";
#   #print "<li><a href='reshome.pl?action=update_activity_form'>Update Activity</a></li>";
#   print "<li><a href='reshome.pl?action=search_milestone'>Retrieve Milestone</a></li>";
#   print "</ul>";
# 
#   print "<h5><b>Risks<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=register_risk'>Register Risk</a></li>";
#   #print "<li><a href='reshome.pl?action=update_activity_form'>Update Activity</a></li>";
#   print "<li><a href='reshome.pl?action=unregister_risk'>Unregister Risk</a></li>";
#   print "</ul>";
# 
# 
#   print "<h5><b>Activity<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=insert_activity'>Submit Activity</a></li>";
#   #print "<li><a href='reshome.pl?action=update_activity_form'>Update Activity</a></li>";
#   print "<li><a href='reshome.pl?action=search_activity'>Retrieve Activity</a></li>";
#   print "<li><a href='reshome.pl?action=view_daily_unassigned_activity'>Unassigned Activities</a></li>";
#   #print "<li><a href='reshome.pl?action=activity_resourcing_form'>Activity Resourcing</a></li>";
#   print "</ul>";
# 
# 
#   print "<h5><b>Tasks<b></h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=capture_timecard'>Enter Task</a></li>";
#   print "<li><a href='reshome.pl?action=edit_timecard_form'>Edit Task</a></li>";
#   print "<li><a href='reshome.pl?action=view_timecard_form'>View Task</a></li>";
#   print "<li><a href='reshome.pl?action=mark_dependent_tasks'>Mark Task as Dependent</a></li>";
#   print "<li><a href='reshome.pl?action=view_tasks_under_activity'>Tasks Under Activity</a></li>";
# 
#   print "</ul>";
#   
#   print "<h5>My Profile</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=view_profile_form'>View Profile</a></li>";
#   print "<li><a href='reshome.pl?action=add_skillset_form'>Request Skillset Update</a></li>";
#   print "<li><a href='reshome.pl?action=change_passcode_form'>Change Password</a></li>";
#   #print "<li><a href='reshome.pl?action=insert_usercalendar_into_db'>Apply Leave</a></li>";
#   print "</ul>";
#   
#   print "<h5>My Reports</h5>";
#   print "<ul>";
# 
#   print "<li><a href='reshome.pl?action=workload_search'>View Workload</a></li>";
#   print "<li><a href='reshome.pl?action=view_goal_progress'>View Goal Progress</a></li>";
#   print "<li><a href='display_workload.pl?action=today_deadline'>Today's Deadline</a></li>";
#   print "<li><a href='display_workload.pl?action=delayed_activities'>Delayed Activities</a></li>";
#   #print "<li><a href='display_workload.pl?action=daily_status_report'>Daily Status Report</a></li>";
#   print "<li><a href='display_workload.pl?action=weekly_status_report'>Weekly Status Report</a></li>";
#   print "<li><a href='display_workload.pl?action=current_milestone_report'>Milestone Report</a></li>";
#   #print "<li><a href='reshome.pl?action=view_usercalendar'>View Leave Calendar</a></li>";
#   print "</ul>";
#   
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
#    print "<li><a href='reshome.pl?action=delete_activity_form'>Delete Activity</a></li>";
#    print "<li><a href='reshome.pl?action=view_gantt_chart'>View Gantt Chart</a></li>";
#    print "<li><a href='reshome.pl?action=view_advanced_gantt_chart'>View Gantt Chart</a></li>";
#    print "<li><a href='reshome.pl?action=link_activity_to_milestone'>Add Milestone</a></li>";
#    print "</ul>";
#   }
# 
#   print "<h5>Support</h5>";
#   print "<ul>";
#   print "<li><a href='reshome.pl?action=log_a_bug'>Log a Bug</a></li>";
#   print "<li><a href='reshome.pl?action=view_a_bug'>View Bugs</a></li>";
#   print "<li><a href='reshome.pl?action=send_feedback'>Send Feedback</a></li>";
#   print "</ul>";



    print "</div></div>";

}

sub footer()
{
  print "<div class=clear>";
  print "<hr />";
  print "</div>";
  print "<div id=footer>";
  print "<div class=xright>&#169; <dotj:date outformat=yyyy /> - QA</div>";
  print "<div class=clear><hr /></div></div>";
  print "</body>";
  print "</head>";
  print "</html>";
}


sub mail_activity_status_updates()
{

    my $activity_id = @_[0];

    my $fromemailid = "SaMTrack\@amadeus.com";
    #my $toemailid = "saurabh.mitra\@amadeus.com";

    $message_body = "<html><head>";
    #<title>Daily Status Report</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1+\"></head><body marginwidth=\"0\" marginheight=\"0\">";

    $message_body = $message_body . "<title></title>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://127.0.0.1/webapp/css/.css type=text/css>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://127.0.0.1/webapp/css/jsDatePick_ltr.min.css>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://127.0.0.1/webapp/css/site.css type=text/css>\n";
    $message_body = $message_body . "<style type=\"text/css\" media=print></style></head>\n";



    $message_body = $message_body . "<p></p><p></p>";


    ##################################################################################################################################################

    $message_body = $message_body . "<table border=1 cellpadding=3>";
    ########## Activities completed today ##################
    

    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Details of Activity Requested By You</th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Activity Owner</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments,b.activity_owner from activities a, activity_details b where a.activity_id=b.id and a.activity_id='$activity_id';");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     $activity_id = $resultset[0];
     $activity_type = $resultset[1];
     $activity_status = $resultset[2];
     $activity_reqemail = $resultset[3];
     $activity_planned_start_date = $resultset[4];
     $activity_planned_end_date = $resultset[5];
     $activity_desc = $resultset[6];
     $activity_comments = $resultset[7];
     $activity_owner = $resultset[8];




     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_owner</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }

    $message_body = $message_body .  "</table>";

    #### Sending the mail
    

    #my $toemailid = "saurabh.m\@apalya.com";
    my $mail_subject = "[SaMTrack Automated Email : Activity Status Update:]" . $activity_id . " - " . $activity_desc . " is having status " . $activity_status;



    $msg = MIME::Lite->new(
        From     => $fromemailid,
        To       => $activity_reqemail,
        Subject  => $mail_subject,
        Type     => 'multipart/mixed',
    );



    $msg->attach(
         Type     => 'text/html',
         Data     => $message_body
    );

   $msg->send('smtp','smtp.amadeus.com', Debug=>1 ); # send via default
   $sth->finish();
   $dbh->disconnect();

}
1;
