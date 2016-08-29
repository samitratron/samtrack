#!c:/perl/bin/perl.exe
use lib "/usr/bin/htdocs/webapp/lib";
use DBI;
use DBD::mysql;
use DBI qw(:sql_types);
use CGI;
use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
use CGI::Session ( '-ip_match' );
require 'header.pl';

#test
$session = CGI::Session->load();
$cgi = new CGI;
$session->save_param($cgi);

#print "Content-type: text/html; charset=iso-8859-1\n\n";

# Variables passed from query string
#
#my $action=$cgi->param("action");

# Set autoflush on always.
#
#$|=1;

if($session->is_expired)
  {
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "Your has session expired. Please login again.";
      print "<br/><a href='login.pl>Login</a>";
  }
elsif($session->is_empty)
{
      print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
      print "You have not logged in";
}

#elsif(defined $cgi->param('action'))
elsif($session->param("action") eq "submit_project")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $session->load_param($cgi);
    @parameters = $cgi->param();
    $myname = $session->param("usr");
    $action_val = $session->param("action");
    &header($myname);


             $taskcatname = $session->param("taskcatname");
             $taskcatdesc = $session->param("taskcatdesc");
             $taskcattype = $session->param("taskcattype");




             print qq~
             <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Task Category Submission :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        ~;
                        if(($taskcatname ne "") and ($taskcatdesc ne "") and ($taskcattype))
                        {
                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("INSERT INTO taskcat(taskcatname,taskcatdesc,taskcattype,taskcataddedby) VALUES ('$taskcatname','$taskcatdesc','$taskcattype','$myname');");
                            $sth->execute() || die "$DBI::errstr\n";
                            #while ($resultset = $sth->fetchrow_array)
                            #{
                            # $role = $resultset;
                            #}
                            #print "NAME IS [$name]";
                            $sth->finish();
                            $dbh->disconnect();
                            print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                            print "<th class='TableColumnHeader' width=100% >[$action_val]Task Category Added Successfully</th>";
                            print "</table>";
                        }
                        else
                        {
                            print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                            print "<th class='TableColumnHeader' width=100% >Task Category Addition : FAILURE</th>";
                            print "<tr><td width=150 class='HeaderSub'>Please enter data for all fields and retry</td></tr>";
                            print "</table>";
                        }
                       print qq~
                       </div>
                       ~;
                       &footer();
}
elsif($session->param("action") eq "submit_user")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $session->load_param($cgi);
    @parameters = $cgi->param();
    $myname = $session->param("usr");
    $action_val = $session->param("action");
    &header($myname);


             $register_username = $session->param("register_username");
             $register_password = $session->param("register_password");
             $register_first_name = $session->param("register_first_name");
             $register_last_name = $session->param("register_last_name");
             $register_email_id = $session->param("register_email_id");
             $register_business_title = $session->param("register_business_title");
             $register_user_location = $session->param("register_user_location");
             $register_user_manager = $session->param("register_user_manager");
             $register_mantis_id = $session->param("register_mantis_id");

             print qq~
             <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <table width=87%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >Task Category Submission :</th>
                      </table>
                      <table width=87% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=87% border=0 cellpadding=3 width=350px border=1>
                        ~;
                        if(($register_username ne "") and ($register_password ne "") and ($register_first_name)and ($register_last_name ne "") and ($register_email_id ne "") and ($register_business_title)and ($register_user_location ne "") and ($register_user_manager))
                        {
                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("SELECT username from resources WHERE username='$register_username';");
                            $sth->execute() || die "$DBI::errstr\n";
                            while ($resultset = $sth->fetchrow_array)
                            {
                             if($resultset eq $register_username)
                             {
                                $error_condition = "user_already_exists";

                             }
                             else
                             {
                               $error_condition = "false";
                             }
                            }
                            #print "NAME IS [$name]";
                            $sth->finish();
                            $dbh->disconnect();
                            
                            if($error_condition ne "user_already_exists")
                            {
                              my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                              my $sth = $dbh->prepare("insert into resources (username,first_name,last_name,emailid,title,locale,password,manager,role,mantis_username) values ('$register_username','$register_first_name','$register_last_name','$register_email_id','$register_business_title','$register_user_location',MD5('$register_password'),'$register_user_manager','user','$register_mantis_id');
");
                              $sth->execute() || die "$DBI::errstr\n";
                              $sth->finish();
                              $dbh->disconnect();
                              
                              print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                              print "<th class='TableColumnHeader' width=100% >User $register_username registered Successfully</th>";
                              print "</table>";
                            }
                            else
                            {
                              print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                              print "<th class='TableColumnHeader' width=100% >Register User : FAILURE</th>";
                              print "<tr><td width=150>User $register_username already registered</td></tr>";
                              print "</table>";

                            }
                        }
                        else
                        {
                            print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
                            print "<th class='TableColumnHeader' width=100% >Register User : FAILURE</th>";
                            print "<tr><td width=150 class='HeaderSub'>Please enter data for all fields and retry</td></tr>";
                            print "</table>";
                        }
                       print qq~
                       </div>
                       ~;
                       &footer();
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
#   print "<title>Pogo QA Resourcing : Time Card Entry </title>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/~samitra/css/my.css type=text/css>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/~samitra/css/jsDatePick_ltr.min.css>\n";
#   print "<link rel=stylesheet href=http://127.0.0.1/~samitra/css/site.css type=text/css>\n";
#   print "<style type=\"text/css\" media=print></style></head>\n";
#   print "<script src=http://127.0.0.1/~samitra/javascript/jsDatePick.min.1.3.js></script>\n";
#   print "<div id=\"header\">\n";
#   print "<div class=\"wrap\">\n";
#   print "<div class=\"logo\"><img width=\"100%\" src=http://127.0.0.1/~samitra/images/pogo_header.png></div>\n";
#   print "<p></p>\n";
#   print "</div></div>\n";
#   print "<div id=breadcrumbs>";
#   print "<div class=xright>";
#   print "<a href=http://127.0.0.1:80/webapp/reshome.pl?action=home>Home</a>  |  <a href=http://127.0.0.1:80/webapp/login.pl?action=logout><font color='$usercolor'>$myname&nbsp;&nbsp;</font> Logout</a>";
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
#   print "<h5>Help</h5>";
#   print "<ul>";
#   print "<li><a href=''>FAQ</a></li>";
#   print "</ul>";
#   print "</div></div>";
# 
# }
# 
# 
# 
# 
# sub footer()
# {
#   print "<div class=clear>";
#   print "<hr />";
#   print "</div>";
#   print "<div id=footer>";
#   print "<div class=xright>&#169; <dotj:date outformat=yyyy /> - Pogo QA</div>";
#   print "<div class=clear><hr /></div></div>";
#   print "</body>";
#   print "</head>";
#   print "</html>";
# }
