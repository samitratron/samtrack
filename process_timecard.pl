#!/usr/bin/perl
  
  use lib "/usr/bin/htdocs/webapp/lib/";
  
  use DBI;
  use DBD::mysql;
  use DBI qw(:sql_types);
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DateTime;
  use MIME::Lite;
  use Time::Piece;
  require 'header.pl';

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
      print "You have not logged in";
  }
  #elsif($cgi->param('action') eq 'submit_timecard')
  else
  {
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);
    @parameters = $cgi->param();
    $myname = $session->param("usr");
    &header($myname);
                        print qq~
                        <script type="text/javascript">

                        function formReset()
                        {
                         document.getElementById("timecardentry").reset();
                        }
                        function display()
                        {
                          resourcename_val = document.getElementById("resourcename").value;
                          //alert("Resource Name :"+ resourcename_val);
                          if(document.getElementById("singlentry").checked == true)
                          {
                           //alert("Single Day selected");
                           singledayField_val = document.getElementById("singledayField").value;
                           alert("Date Selected is :"+singledayField_val);
                          }
                          for (i=0; i<document.getElementById('dataTable').rows.length; i++)
                          {
                            taskname = document.getElementById('dataTable').rows[i].cells[1].childNodes[0].value;
                            taskcat = document.getElementById('dataTable').rows[i].cells[2].childNodes[0].value;
                            taskduration = document.getElementById('dataTable').rows[i].cells[3].childNodes[0].value;

                            //alert("Taskname is :["+ taskname + "]Task Cat is[" + taskcat + "]Task Duration:[" + taskduration + "]");

                          }
                        }
                        </script>


                        
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
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
                      

                      $username = $session->param("resourcename");
                      $activity_id = $session->param("activity_id");
                      $singleday = $session->param("singledayField");
                      $duration_from = $session->param("durationfromField");
                      $duration_to = $session->param("durationtoField");
                      $singleendday = $session->param("singleenddayField");

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

                      
                      my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});



                      if(($singleday ne "") and ($singleendday ne ""))
                      {
                          if($singleendday=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }

                          $taskenddate = $year . "-" . $month . "-" .  $day;
                          $mandatory_task_end_date = get_activity_end_date($activity_id);

                          $taskenddate_obj = Time::Piece->strptime($taskenddate, "%Y-%m-%d");
                          $mandatory_task_end_date_obj = Time::Piece->strptime($mandatory_task_end_date, "%Y-%m-%d");

                          $date_diff = $mandatory_task_end_date_obj - $taskenddate_obj;

                          $date_diff_days = int($date_diff->days);


                          if($date_diff_days>=0)
                          {

                                foreach (@task_ids)
                                {
                                  $unique_part_in_task_id = unique_date_time_string();

                                  $taskcomments_param = "taskrow_" . $_ . "_taskcomments"; #
                                  $taskskillset_param = "taskrow_" . $_ . "_taskcat"; #project
                                  $taskmanhrs_param = "taskrow_" . $_ . "_manhours";
                                  $taskpriority_param = "taskrow_" . $_ . "_priority";
                                  $taskprojname_param = "taskrow_" . $_ . "_projname";
                                  $taskstatus_param = "taskrow_" . $_ . "_status";
        
        
                                  $task_id = $unique_part_in_task_id . $_;
                                  $taskcomments = $session->param("$taskcomments_param"); #comments
                                  $taskcat = $session->param("$taskskillset_param");   #projname
                                  $taskmanhr = $session->param("$taskmanhrs_param"); #manhours
                                  $taskpriority = $session->param("$taskpriority_param"); #priority
                                  $taskprojname = $session->param("$taskprojname_param");
                                  $taskstatus = $session->param("$taskstatus_param");

                                  

                                  if($singleday=~/(\d+)-(.*)-(\d+)/)
                                  {
                                    $day = $1;
                                    $month_alphabetic = $2;
                                    $month = $months{$month_alphabetic};
                                    $year = $3;
                                  }
                                  
                                  $taskdate = $year . "-" . $month . "-" .  $day;
        
        
                                  #my $sth = $dbh->prepare("INSERT INTO task_global (task_id,task_username,task_cat,task_comments,task_projname,task_date,task_manhour,task_priority,task_assigned_by,task_percentage_complete,task_status,activity_id) values ('$task_id','$username','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority','$myname',0,'$taskstatus','$activity_id');");
                                  my $sth = $dbh->prepare("INSERT INTO task_global (task_id,task_username,task_cat,task_comments,task_projname,task_date,task_manhour,task_priority,task_assigned_by,task_status,activity_id,task_enddate) values ('$task_id','$username','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority','$myname','$taskstatus','$activity_id','$taskenddate');");
                                  $sth->execute() || die "$DBI::errstr\n";
                                  $sth->finish();
        
                                  $todays_date = gettodaysdate();
                                  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                  my $sth = $dbh->prepare("INSERT INTO task_transactions (task_id,task_username,task_cat,task_comments,task_projname,task_update_date,task_manhour,task_priority,task_percentage_complete,task_status,activity_id,transaction_type) VALUES ('$task_id','$myname','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority',0,'$taskstatus','$activity_id','INSERT');");
                                  $sth->execute() || die "$DBI::errstr\n";
                                  $sth->finish();
        
        
        
        
                                  ### Update activity status. If Activity status is Assigned move it to Planned else do nothing
        
                                  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                  my $sth = $dbh->prepare("SELECT activity_status FROM activities WHERE activity_id='$activity_id';");
                                  $sth->execute() || die "$DBI::errstr\n";
                                  while ($resultset = $sth->fetchrow_array)
                                  {
                                   $activity_status = $resultset;
                                  }
                                  $sth->finish();
                                  $dbh->disconnect();
        
                                  if($activity_status eq "Assigned")
                                  {
                                   $activity_status = "Planned";
                                   
                                   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                   my $sth = $dbh->prepare("UPDATE activities SET activity_status='$activity_status' WHERE activity_id='$activity_id'");
                                   $sth->execute() || die "$DBI::errstr\n";
                                   $sth->finish();
                                   $dbh->disconnect();
                                  
        #                           mail_activity_status_updates($activity_id);
        
                                  }
        
                                  ###
                                }
        
                                  print "<table width=85%  border=0 cellpadding=3>";
                                  print "<th class=TableColumnHeader width=100%>Task Submission Status </th>";
                                  print "<tr><td class=TableCellText >Task successfully added to activity $activity_id.Activity status is $activity_status</td></tr>";
                                  print "</table>";
                        }
                        else
                        {
                            print "<table width=85%  border=0 cellpadding=3>";
                            print "<th class=TableColumnHeader width=100%>Time Card Submission : Status </th>";
                            print "<tr><td class=TableCellText >Time Card Submission : <font color=red><b>Failure</b></font></td></tr>";
                            print "<tr><td class=TableCellText >The Task End Date is set more than Milestone Date $mandatory_task_end_date.</td></tr>";
                            print "<tr><td class=TableCellText >Either remove the milestone from the activity of which this task is a child or have task end date lesser than mielstone date.</td></tr>";
                            print "</table>";
                        }

                      }
                      elsif(($duration_from ne "") or ($duration_to ne ""))
                      {
                        if(($duration_from ne "") and ($duration_to ne "") and ($duration_from ne $duration_to))
                        {
                        ###
                            $loop = "correct";
                            if($duration_from=~/(\d+)-(.*)-(\d+)/)
                            {
                              $fromday = $1;
                              $frommonth_alphabetic = $2;
                              $frommonth = $months{$frommonth_alphabetic};
                              $fromyear = $3;

                            }
                            
                            if($duration_to=~/(\d+)-(.*)-(\d+)/)
                            {
                              $today = $1;
                              $tomonth_alphabetic = $2;
                              $tomonth = $months{$tomonth_alphabetic};
                              $toyear = $3;
                            
                            }
                            
                            $fromdate = $fromyear . "-" . $frommonth . "-" .  $fromday;
                            $todate =   $toyear . "-" . $tomonth . "-" .  $today;

                            my $start = DateTime->new(
                                day   => $fromday,
                                month => $frommonth,
                                year  => $fromyear,
                            );
                            
                            my $stop = DateTime->new(
                                day   => $today,
                                month => $tomonth,
                                year  => $toyear,
                            );
                            
                            push(@dates,$fromdate);
                            
                            while ( $start->add(days => 1) < $stop ) {
                                #printf "Date: %s\n", $start->ymd('-');
                                if($start=~/(.*)T.*/)
                                {
                                 push(@dates,$1);
                                }
                            }
                            push(@dates,$todate);
                            $query = join(",",@dates);
                            foreach $date (@dates)
                            {
                              #if($date=~/(\d+)-(.*)-(\d+)/)
                              #{
                              #  $day = $1;
                              #  $month_alphabetic = $2;
                              #  $month = $months{$month_alphabetic};
                              #  $year = $3;
                              # }
                              # $taskdate = $year . "-" . $month . "-" .  $day;
                              $taskdate = $date;

                              foreach (@task_ids)
                              {

                                $unique_part_in_task_id = unique_date_time_string();

                                $taskcomments_param = "taskrow_" . $_ . "_taskcomments"; #
                                $taskskillset_param = "taskrow_" . $_ . "_taskcat"; #project
                                $taskmanhrs_param = "taskrow_" . $_ . "_manhours";
                                $taskpriority_param = "taskrow_" . $_ . "_priority";
                                $taskprojname_param = "taskrow_" . $_ . "_projname";
      
                                $task_id = $unique_part_in_task_id . $_;
                                $taskcomments = $session->param("$taskcomments_param"); #comments
                                $taskcat = $session->param("$taskskillset_param");   #projname
                                $taskmanhr = $session->param("$taskmanhrs_param"); #manhours
                                $taskpriority = $session->param("$taskpriority_param"); #priority
                                $taskprojname = $session->param("$taskprojname_param");


                                 #$query = "INSERT INTO task_global (username,task_cat,task_desc,task_date,task_manhour) values $taskdate";
                                 
                                 my $sth = $dbh->prepare("INSERT INTO task_global (task_id,task_username,task_cat,task_comments,task_projname,task_date,task_manhour,task_priority,task_assigned_by,task_percentage_complete,task_status,activity_id) values ('$task_id','$username','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority','$myname',0,'$taskstatus','$activity_id');");
                                 $sth->execute() || die "$DBI::errstr\n";
                                 $sth->finish();
  
                                 $todays_date = gettodaysdate();
                                 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                 my $sth = $dbh->prepare("INSERT INTO task_transactions (task_id,task_username,task_cat,task_comments,task_projname,task_update_date,task_manhour,task_priority,task_percentage_complete,task_status,activity_id,transaction_type) VALUES ('$task_id','$myname','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority',0,'$taskstatus','$activity_id','INSERT');");
                                 $sth->execute() || die "$DBI::errstr\n";
                                 $sth->finish();


                                 ### Update activity status. If Activity status is Assigned move it to Planned else do nothing

                                  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                  my $sth = $dbh->prepare("SELECT activity_status FROM activities WHERE activity_id='$activity_id';");
                                  $sth->execute() || die "$DBI::errstr\n";
                                  while ($resultset = $sth->fetchrow_array)
                                  {
                                   $activity_status = $resultset;
                                  }
                                  $sth->finish();
                                  $dbh->disconnect();
        
                                  if($activity_status eq "Assigned")
                                  {
                                   $activity_status = "Planned";
                                   
                                   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                                   my $sth = $dbh->prepare("UPDATE activities SET activity_status='$activity_status' WHERE activity_id='$activity_id'");
                                   $sth->execute() || die "$DBI::errstr\n";
                                   $sth->finish();
                                   $dbh->disconnect();
                                  
#                                   mail_activity_status_updates($activity_id);
                                  }
        
                                  ###


                              }

                            }
                        ###
                          print "<table width=85%  border=0 cellpadding=3>";
                          print "<th class=TableColumnHeader width=100%>Time Card Submission : Status </th>";
                          print "<tr><td class=TableCellText >Time Card Submission : <font color=orange>Successful</font></b></td></tr>";
                          print "</table>";

                        }
                        elsif(($duration_from ne "") and ($duration_to ne "") and ($duration_from eq $duration_to))
                        {
                           
                           if($duration_from=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }
                          
                           $taskdate = $year . "-" . $month . "-" .  $day;
                           

                            foreach (@task_ids)
                            {
                              
                              $unique_part_in_task_id = unique_date_time_string();

                              $taskcomments_param = "taskrow_" . $_ . "_taskcomments"; #
                              $taskskillset_param = "taskrow_" . $_ . "_taskcat"; #project
                              $taskmanhrs_param = "taskrow_" . $_ . "_manhours";
                              $taskpriority_param = "taskrow_" . $_ . "_priority";
                              $taskprojname_param = "taskrow_" . $_ . "_projname";
    
                              $task_id = $unique_part_in_task_id . $_;
                              $taskcomments = $session->param("$taskcomments_param"); #comments
                              $taskcat = $session->param("$taskskillset_param");   #projname
                              $taskmanhr = $session->param("$taskmanhrs_param"); #manhours
                              $taskpriority = $session->param("$taskpriority_param"); #priority
                              $taskprojname = $session->param("$taskprojname_param");
    
    
    
                              if($singleday=~/(\d+)-(.*)-(\d+)/)
                              {
                                $day = $1;
                                $month_alphabetic = $2;
                                $month = $months{$month_alphabetic};
                                $year = $3;
                              }
                              
                              $taskdate = $year . "-" . $month . "-" .  $day;
    
                             my $sth = $dbh->prepare("INSERT INTO task_global (task_id,task_username,task_cat,task_comments,task_projname,task_date,task_manhour,task_priority,task_assigned_by,task_percentage_complete,task_status,activity_id) values ('$task_id','$username','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority','$myname',0,'$taskstatus','$activity_id');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
  
                             $todays_date = gettodaysdate();
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("INSERT INTO task_transactions (task_id,task_username,task_cat,task_comments,task_projname,task_update_date,task_manhour,task_priority,task_percentage_complete,task_status,activity_id,transaction_type) VALUES ('$task_id','$myname','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority',0,'$taskstatus','$activity_id','INSERT');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();


                              ### Update activity status. If Activity status is Assigned move it to Planned else do nothing

                              my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                              my $sth = $dbh->prepare("SELECT activity_status FROM activities WHERE activity_id='$activity_id';");
                              $sth->execute() || die "$DBI::errstr\n";
                              while ($resultset = $sth->fetchrow_array)
                              {
                               $activity_status = $resultset;
                              }
                              $sth->finish();
                              $dbh->disconnect();
      
                              if($activity_status eq "Assigned")
                              {
                               $activity_status = "Planned";
                               
                               my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                               my $sth = $dbh->prepare("UPDATE activities SET activity_status='$activity_status' WHERE activity_id='$activity_id'");
                               $sth->execute() || die "$DBI::errstr\n";
                               $sth->finish();
                               $dbh->disconnect();
                              
#                               mail_activity_status_updates($activity_id);
                              }

                          ###




                            }

                            print "<table width=85%  border=0 cellpadding=3>";
                            print "<th class=TableColumnHeader width=100%>Time Card Submission : Status </th>";
                            print "<tr><td class=TableCellText >Time Card Submission : <font color=blue><b>Successful</b></font></td></tr>";
                            print "</table>";

                        }
                        elsif(($duration_from eq "") or ($duration_to eq ""))
                        {
                          $loop = "wrong";
                          if($duration_from eq "")
                          {
                           $date = $duration_to;
                          }
                          elsif($duration_to eq "")
                          {
                            $date = $duration_from;
                          }

                          if($date=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }
                          $taskdate = $year . "-" . $month . "-" .  $day;

                          foreach (@task_ids)
                          {
                            
                            $unique_part_in_task_id = unique_date_time_string();

                            $taskcomments_param = "taskrow_" . $_ . "_taskcomments"; #
                            $taskskillset_param = "taskrow_" . $_ . "_taskcat"; #project
                            $taskmanhrs_param = "taskrow_" . $_ . "_manhours";
                            $taskpriority_param = "taskrow_" . $_ . "_priority";
                            $taskprojname_param = "taskrow_" . $_ . "_projname";
  
                            $task_id = $unique_part_in_task_id . $_;
                            $taskcomments = $session->param("$taskcomments_param"); #comments
                            $taskcat = $session->param("$taskskillset_param");   #projname
                            $taskmanhr = $session->param("$taskmanhrs_param"); #manhours
                            $taskpriority = $session->param("$taskpriority_param"); #priority
                            $taskprojname = $session->param("$taskprojname_param");



                            #$query = "INSERT INTO task_global (username,task_cat,task_desc,task_date,task_manhour) values ('".$username."','".$taskcat."','".$taskdesc."','".$taskdate."',".$taskmanhr.")";

                             my $sth = $dbh->prepare("INSERT INTO task_global (task_id,task_username,task_cat,task_comments,task_projname,task_date,task_manhour,task_priority,task_assigned_by,task_percentage_complete,task_status,activity_id) values ('$task_id','$username','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority','$myname',0,'$taskstatus','$activity_id');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
  
                             $todays_date = gettodaysdate();
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("INSERT INTO task_transactions (task_id,task_username,task_cat,task_comments,task_projname,task_update_date,task_manhour,task_priority,task_percentage_complete,task_status,activity_id,transaction_type) VALUES ('$task_id','$myname','$taskcat','$taskcomments','$taskprojname','$taskdate',$taskmanhr,'$taskpriority',0,'$taskstatus','$activity_id','INSERT');");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();


                            ### Update activity status. If Activity status is Assigned move it to Planned else do nothing

                            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                            my $sth = $dbh->prepare("SELECT activity_status FROM activities WHERE activity_id='$activity_id';");
                            $sth->execute() || die "$DBI::errstr\n";
                            while ($resultset = $sth->fetchrow_array)
                            {
                             $activity_status = $resultset;
                            }
                            $sth->finish();
                            $dbh->disconnect();

                            if($activity_status eq "Assigned")
                            {
                             $activity_status = "Planned";
                             
                             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                             my $sth = $dbh->prepare("UPDATE activities SET activity_status='$activity_status' WHERE activity_id='$activity_id'");
                             $sth->execute() || die "$DBI::errstr\n";
                             $sth->finish();
                             $dbh->disconnect();
                            
#                             mail_activity_status_updates($activity_id);
                            }
  
                            ###

                          }
                          print "<table width=85%  border=0 cellpadding=3>";
                          print "<th class=TableColumnHeader width=100%>Time Card Submission : Status </th>";
                          print "<tr><td class=TableCellText >Time Card Submission : <font color=red><b>Successful</b></font></td></tr>";
                          print "</table>";
                         }

                      }
                      else
                      {
                          print "<table width=85%  border=0 cellpadding=3>";
                          print "<th class=TableColumnHeader width=100%>Time Card Submission : Status </th>";
                          print "<tr><td class=TableCellText >Time Card Submission : <font color=red><b>Failure</b></font></td></tr>";
                          print "<tr><td class=TableCellText >Date or Resource Name Not Selected.</td></tr>";
                          print "</table>";
                      }


                      $dbh->disconnect();


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
#   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
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
#   print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/.css type=text/css>\n";
#   print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/jsDatePick_ltr.min.css>\n";
#   print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/site.css type=text/css>\n";
#   print "<style type=\"text/css\" media=print></style></head>\n";
#   print "<script src=http://192.168.56.228/webapp/javascript/jsDatePick.min.1.3.js></script>\n";
#   print "<div id=\"header\">\n";
#   print "<div class=\"wrap\">\n";
#   print "<div class=\"logo\"><img width=\"100%\" src=http://192.168.56.228/webapp/images/pogo_header.png></div>\n";
#   print "<p></p>\n";
#   print "</div></div>\n";
#   print "<div id=breadcrumbs>";
#   print "<div class=xright>";
#   print "<a href=http://192.168.56.228:80/cgi-bin/webapp/reshome.pl?action=home>Home</a>  |  <a href=http://192.168.56.228:80/cgi-bin/webapp/login.pl?action=logout><font color='$usercolor'>$myname&nbsp;&nbsp;</font> Logout</a>";
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


sub unique_date_time_string()
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



$unique_date_time = $dayOfMonth .  $month .  $year . $hour . $minute . $second;

return($unique_date_time);
}

sub get_activity_end_date()
{
 my $activity_id = @_[0];
 my $milestone_date = "";

 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 my $sth = $dbh->prepare("select b.milestone_date from activity_details a,milestone b where a.milestone_id=b.milestone_id and a.id='$activity_id';");
 $sth->execute() || die "$DBI::errstr\n";
 while (@resultset = $sth->fetchrow_array)
 {
  $milestone_date = $resultset[0];
 }
 $sth->finish();
 $dbh->disconnect();
 
 return($milestone_date);

}


