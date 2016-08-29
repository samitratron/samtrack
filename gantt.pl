#!/usr/bin/perl
#!/usr/bin/perl
use lib "/usr/bin/htdocs/webapp/lib/chartdirector";
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
use Tie::IxHash;
use MIME::Lite;
#require 'header.pl';


# Include current script directory in the module path (needed on Microsoft IIS).
# This allows this script to work by copying ChartDirector to the same directory
# as the script (as an alternative to installation in Perl module directory)
use File::Basename;
use lib dirname($0) =~ /(.*)/;

use perlchartdir;

$session = CGI::Session->load();
$cgi = new CGI;
$session->save_param($cgi);


if($session->is_expired)
  {
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "Your has session expired. Please login again.";
      print "<br/><a href='login.pl>Login</a>";
  }
  elsif($session->is_empty)
  {
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "You have not logged in. Click here to <a href=http://192.168.60.83:80/webapp/login.pl>login</a>";
  }
elsif($cgi->param('action') eq 'view_gantt_chart')
{
         print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
         $myname = $session->param("usr");

         $session->clear();
         $session->param(usr=>$myname);

         &header($myname);

          my $filename = "samtrack.png";
          my $name = "";

           $image_url = generateganttchart($filename);

           print "<div id='bodyColumn'><div id='contentBox'><div class='section'>";
           print "<div align='center'>";
           print "<div></div><div><p></p><p></p></div>";
           print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
           print "<th class='EATableColumnHeader' width=100% >Gantt Chart [$image_url]:</th>";
           print "</table>";
           print "<div></div><div><p><img src='$image_url'></img</p><p></p></div>";
          &footer();
}


sub header()
{
  # New Header
  my $myname =  @_[0];
  my $role = "";
  my $resultset = "";

  #my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.60.83","mysqluser", "t3str",{'RaiseError' => 1});
  #my $sth = $dbh->prepare("SELECT role FROM resources where username='$myname'");
  #$sth->execute() || die "$DBI::errstr\n";
  #while ($resultset = $sth->fetchrow_array)
  #{
  # $role = $resultset;
  #}
   #print "NAME IS [$name]";
  #$sth->finish();
  #$dbh->disconnect();

  $role = "admin";

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
  print "<title>Apalya QA Resourcing : Time Card Entry </title>\n";
  print "<link rel=stylesheet href=http://192.168.60.83/webapp/css/EA.css type=text/css>\n";
  #print "<link rel=stylesheet href=http://192.168.60.83/webapp/css/jsDatePick_ltr.min.css>\n";
  print "<link rel=stylesheet href=http://192.168.60.83/webapp/css/site.css type=text/css>\n";
  print "<style type=\"text/css\" media=print></style></head>\n";
  #print "<script src=http://192.168.60.83/webapp/javascript/jsDatePick.min.1.3.js></script>\n";
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
  print "<div class=\"logo\"><img width=\"100%\" src=http://192.168.60.83/webapp/images/pogo_header.png></div>\n";
  #print "<div class=\"logo\"><img src=http://192.168.60.83/webapp/images/rotating_earth.gif></div>\n";

  print "<p></p>\n";
  print "</div></div>\n";
  print "<body bgcolor=\"#cfe0f1\">";
  #print "<div id=breadcrumbs >";

  #print "<div class=xright>";
  print "<a href=http://192.168.60.83:80/webapp/reshome.pl?action=home><font GlobalLink:active'><b>Home</b></font></a>  |  <a href=http://192.168.60.83:80/webapp/login.pl?action=logout><font color='$usercolor'><b>Logout</b></font></a>";

  print "<table width='100%' align='left' border='1' cellpadding='3'>";
  print  "<th class='EATableColumnHeader' width='100%'><marquee> </font> Welcome <font color=green>$myname </font> To <font color='blue'><b>SaMTrack</b></font><font color='red'><b> Ver 1.0</b></font></marquee></th>";
  print "</table>";

  print "</div>";
  print "<div class=clear><hr /></div></div>";
  print "<div id=leftColumn >";
  print "<div id=navcolumn >";
  print "<h5><b>Activity<b></h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=insert_activity'>Submit Activity</a></li>";
  print "<li><a href='reshome.pl?action=update_activity_form'>Update Activity</a></li>";
  print "<li><a href='reshome.pl?action=search_activity'>Retrieve Activity</a></li>";
  print "<li><a href='reshome.pl?action=activity_resourcing_form'>Activity Resourcing</a></li>";
  print "</ul>";
  print "<h5><b>Tasks<b></h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=capture_timecard'>Enter Task</a></li>";
  print "<li><a href='reshome.pl?action=edit_timecard_form'>Edit Task</a></li>";
  print "<li><a href='reshome.pl?action=view_timecard_form'>View Task</a></li>";
  print "</ul>";
  print "<h5>My Profile</h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=add_skillset_form'>Request Skillset Update</a></li>";
  print "<li><a href='reshome.pl?action=change_passcode_form'>Change Password</a></li>";
  print "<li><a href='reshome.pl?action=insert_usercalendar_into_db'>Apply Leave</a></li>";
  print "</ul>";
  print "<h5>My Reports</h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=view_profile_form'>View Profile</a></li>";
  print "<li><a href='reshome.pl?action=workload_search'>View Workload</a></li>";
  print "<li><a href='display_workload.pl?action=daily_status_report'>Daily Status Report</a></li>";
  print "<li><a href='reshome.pl?action=view_usercalendar'>View Leave Calendar</a></li>";
  print "</ul>";
  print "<h5>Search</h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=resource_lookup'>Search Resource</a></li>";
  print "</ul>";

  if($role eq "admin")
  {
   print "<h5>Admin</h5>";
   print "<ul>";
   print "<li><a href='reshome.pl?action=register_user_form'>Register User</a></li>";
   print "<li><a href='reshome.pl?action=insert_roles_into_db'>Add Role</a></li>";
   print "<li><a href='reshome.pl?action=insert_skillset_into_db'>Add Skillset</a></li>";
   print "<li><a href='reshome.pl?action=insert_project_into_db'>Add Projects</a></li>";
   print "<li><a href='reshome.pl?action=view_daily_unassigned_activity'>Daily Unassigned Activities</a></li>";
   print "<li><a href='reshome.pl?action=delete_activity_form'>Delete Activity</a></li>";
   print "<li><a href='gantt.pl?action=view_gantt_chart'>View Gantt Chart</a></li>";
   print "</ul>";
  }

  print "<h5>Support</h5>";
  print "<ul>";
  print "<li><a href='reshome.pl?action=log_a_bug'>Log a Bug</a></li>";
  print "<li><a href='reshome.pl?action=view_a_bug'>View Bugs</a></li>";
  print "<li><a href='reshome.pl?action=send_feedback'>Send Feedback / Suggestions</a></li>";
  print "</ul>";


  print "<h5>Useful Links</h5>";
  print "<ul>";
  print "<li><a href='' onclick=open_win'('https://192.168.200.211/my_view_page.php')'>Mantis</a></li>";
  print "<li><a href='http://http://apalyasupport.com/ctrlops/' id='controlops'>Control Ops</a></li>";
  print "<li><a href='http://192.168.60.83/testlink/login.php' id='testlink'>Test Link</a></li>";
  print "<li><a href='https://paybooks.in/useremplogin.aspx' id='paybooks'>Pay Books</a></li>";
  print "</ul>";
  print "</div></div>";

}
sub footer()
{
  print "<div class=clear>";
  print "<hr />";
  print "</div>";
  print "<div id=footer>";
  print "<div class=xright>&#169; <dotj:date outformat=yyyy /> - Apalya QA</div>";
  print "<div class=clear><hr /></div></div>";
  print "</body>";
  print "</head>";
  print "</html>";
}


sub generateganttchart()
{
my $gantt_chart_image_filename =  @_[0];
my $final_image = "";

my $startDate = [perlchartdir::chartTime(2004, 8, 16), perlchartdir::chartTime(2004,
    8, 30), perlchartdir::chartTime(2004, 9, 13), perlchartdir::chartTime(2004, 9, 20
    ), perlchartdir::chartTime(2004, 9, 27), perlchartdir::chartTime(2004, 10, 4),
    perlchartdir::chartTime(2004, 10, 25), perlchartdir::chartTime(2004, 11, 1),
    perlchartdir::chartTime(2004, 11, 8)];
my $endDate = [perlchartdir::chartTime(2004, 8, 30), perlchartdir::chartTime(2004, 9,
    13), perlchartdir::chartTime(2004, 9, 27), perlchartdir::chartTime(2004, 10, 4),
    perlchartdir::chartTime(2004, 10, 11), perlchartdir::chartTime(2004, 11, 8),
    perlchartdir::chartTime(2004, 11, 8), perlchartdir::chartTime(2004, 11, 22),
    perlchartdir::chartTime(2004, 11, 22)];
my $labels = ["Market Research", "Define Specifications", "Overall Archiecture",
    "Project Planning", "Detail Design", "Software Development", "Test Plan",
    "Testing and QA", "User Documentation"];

# Create a XYChart object of size 620 x 280 pixels. Set background color to light
# blue (ccccff), with 1 pixel 3D border effect.
my $c = new XYChart(620, 280, 0xccccff, 0x000000, 1);

# Add a title to the chart using 15 points Times Bold Itatic font, with white
# (ffffff) text on a deep blue (000080) background
$c->addTitle("Simple Gantt Chart Demo", "timesbi.ttf", 15, 0xffffff)->setBackground(
    0x000080);

# Set the plotarea at (140, 55) and of size 460 x 200 pixels. Use alternative
# white/grey background. Enable both horizontal and vertical grids by setting their
# colors to grey (c0c0c0). Set vertical major grid (represents month boundaries) 2
# pixels in width
$c->setPlotArea(140, 55, 460, 200, 0xffffff, 0xeeeeee, $perlchartdir::LineColor,
    0xc0c0c0, 0xc0c0c0)->setGridWidth(2, 1, 1, 1);

# swap the x and y axes to create a horziontal box-whisker chart
$c->swapXY();

# Set the y-axis scale to be date scale from Aug 16, 2004 to Nov 22, 2004, with ticks
# every 7 days (1 week)
$c->yAxis()->setDateScale(perlchartdir::chartTime(2004, 8, 16),
    perlchartdir::chartTime(2004, 11, 22), 86400 * 7);

# Set multi-style axis label formatting. Month labels are in Arial Bold font in "mmm
# d" format. Weekly labels just show the day of month and use minor tick (by using
# '-' as first character of format string).
$c->yAxis()->setMultiFormat(perlchartdir::StartOfMonthFilter(),
    "<*font=arialbd.ttf*>{value|mmm d}", perlchartdir::StartOfDayFilter(),
    "-{value|d}");

# Set the y-axis to shown on the top (right + swapXY = top)
$c->setYAxisOnRight();

# Set the labels on the x axis
$c->xAxis()->setLabels($labels);

# Reverse the x-axis scale so that it points downwards.
$c->xAxis()->setReverse();

# Set the horizontal ticks and grid lines to be between the bars
$c->xAxis()->setTickOffset(0.5);

# Add a green (33ff33) box-whisker layer showing the box only.
$c->addBoxWhiskerLayer($startDate, $endDate, undef, undef, undef, 0x00cc00,
    $perlchartdir::SameAsMainColor, $perlchartdir::SameAsMainColor);

# Output the chart
#binmode(STDOUT);
#print "Content-type: image/png\n\n";
print $c->makeChart2($perlchartdir::PNG);

$final_image = "http://192.168.60.83/webapp/images/" . $gantt_chart_image_filename;
return($final_image);
}
