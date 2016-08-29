#!/usr/bin/perl

  use lib "/usr/bin/htdocs/webapp/lib";
  use DBI;
  use DBD::mysql;
  use DBI qw(:sql_types);
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );
  use DateTime;
  use Tie::IxHash;
  use MIME::Lite;
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
  elsif($cgi->param('action') eq 'view_searched_activities')
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    @parameters = $cgi->param();
    
    #$session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'display_taskbyactivityid');
    
    
    
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
                        

                        print qq~
                       <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      <div></div>
                      <div><p></p><p></p></div>
                      <table width=100%  border='0' cellpadding='3'>
                      <th class='TableColumnHeader' width=100% >View Activity Details :</th>
                      </table>
                      <table width=100% border=0 cellpadding=3 width=350px border=1>
                       <tr>
                       </tr>
                        </table>
                        <table width=100% border=0 cellpadding=3 width=350px border=1>
                        <tr class='TableColumnHeader' ><td>Activity ID</td><td>Activity Type</td><td>Status</td><td>Priority</td><td>Requested By</td><td>Description</td><td>Comments</td></tr>
                        ~;

                        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
                        my $sth = $dbh->prepare("select a.activity_id,a.activity_type,a.activity_status,a.activity_priority,a.activity_reqemail,a.activity_desc,a.activity_comments from activities a  where a.activity_type like '$activity_type' and a.activity_status like '$activity_status' and a.activity_priority like '$activity_priority';");
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

                          print "<tr><td class='HeaderSub'><a target='iframe_a' href='http://192.168.56.228:80/webapp/reshome.pl?activityid=$activity_id'>$activity_id</a></td><td class='HeaderSub'>$activity_type</td><td class='HeaderSub'>$activity_status</td><td class='HeaderSub'>$activity_priority</td><td class='HeaderSub'>$activity_reqemail</td><td class='HeaderSub'>$activity_desc</td><td class='HeaderSub'>$activity_comments</td></tr>";

                        }
                       $sth->finish();
                       $dbh->disconnect();

                       # style=height:400px;width:87%; frameborder=0

                        print "</table>";
                        print "</div>";
                        print "<div></div>";
                        print "<div><p></p></div>";
                        print "<iframe name='iframe_a' align=center style=height:150px;width:100%;  frameborder=0 scrolling=auto ></iframe>";
                        &footer();
}
  elsif($session->param("action") eq "submit_timecard")
  {
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);
    
    


    $session->clear(["action"]);
    $session->param(action=>'display_user_task');

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    $myname = $session->param("usr");
    &header($myname);
                        print qq~
                        <script type="text/javascript">



                        var Content;
                        var rowHTML;
                        var chartMaxValue = 8;
                        var chartHeight = 400;
                        var colNum;
                        var barHeight = 10;
                        var XAxisScale = 8 ;

                        function createChartObject(calday,manhrload,caldate){
                        	VerY = new Array();
                        	HorX = new Array();
                        	var j = 0;
                                var progressbarval = manhrload * 18.90;
                                var percentageloaded = (manhrload/8)*100;
                        
                                if(manhrload <=4)
                                {
                                 taskcolor = "green";
                                }
                                else if(manhrload >=4 && manhrload <7)
                                {
                                  taskcolor = "orange";
                                }
                                else
                                {
                                  taskcolor = "red";
                                }
                        
                                //alert(taskcolor);
                        
                        	//parse pairs
                        	for(i = 0; i < 1; i++)
                                {
                                   //VerY[j] = "";
                                   VerY[j] = calday;
                           	   HorX[j] = progressbarval;
                                   j++;
                        
                        	}
                        
                        	// Reset the Column Count to the length of Array WITH VALUES
                        
                                colNum = VerY.length;
                                nSeriesType = 2;
                        	if (colNum == 0){
                        		alert ("No data found.");
                        	} else {
                        		if (nSeriesType == 2)
                        		{
                        			// Horizontal Bar Chart
                        			//Content = "<html><head><title>Horizontal Chart</title></head><body bgcolor=white text=black>";
                        			//if (document.getElementById("chkseparators").checked == true)
                        			//	Content = "<table id=tblgraph align=center width=48 cellpadding=1 cellspacing=0 border=1>";
                        			//else
                        			//	Content += "<table id=tblgraph align=center width=" + (chartMaxValue+40) + " cellpadding=1 cellspacing=0 border=1>";
                        
                                                Content = "<table id=tblgraph align=center width=48 cellpadding=1 cellspacing=0 border=1>";
                                                // Add the row for X Axis
                        			Content+= "<tr bgcolor=white>";
                        			// Add the first blank Cell
                        			//Content += "<td align=right><div><font face=arial size='-2'>&nbsp;</font></div></td>";
                                                Content += "<td colspan=9 align=center ><div><font  face=arial size='-2'>"+caldate+"</font></div></td>";
                                                Content += "</tr>";
                        
                                                Content += "<tr bgcolor=white>";
                        			//Content += "<td align=right><div><font face=arial size='-2'>&nbsp;</font></div></td>";
                                                for (i = 1; i <= XAxisScale; i++){
                        			//if (document.getElementById("chkseparators").checked == true)
                        				Content += "<td align=right><div style='background-color:white; width:" + parseInt(chartMaxValue/XAxisScale - 4) + "; height:" + (barHeight-2) + ";'><font face=arial size='-2'>" + parseInt(i * chartMaxValue / XAxisScale) + "hr"+ "</font></div></td>";
                        			//else
                        			//	Content += "<td align=right><div style='background-color:white; width:" + parseInt(chartMaxValue/XAxisScale - 4) + "; height:" + (barHeight-2) + ";'><font face=arial size='-2'>" + parseInt(i * chartMaxValue / XAxisScale) + "|</font></div></td>";
                        			}
                        
                                                //alert(VerY.length)
                        			for (i = 0; i < VerY.length; i++){

                                                        w = parseInt(HorX[i]);
                        
                                                        rowHTML = "";
                        				rowHTML += "<tr style='width:100%'>";
                        				// Add the abels of Y Axis
                        
                                                        //rowHTML+= "<td align=right><div style='background-color:white; width:40; height:" + (barHeight-2) + ";'><font face=arial size='-2'>" + VerY[i] + "</font></div></td>";
                        				rowHTML+= "<td name=caldate onclick=javascript:showCellData();  bgcolor=white align=left width=" + (chartMaxValue) + " height=" + (barHeight-2) + " colspan=" + XAxisScale + ">";
                        				if (w>2)
                        					rowHTML+= "<div style='background-color:"+taskcolor+"; width:" + (w-1) + ";' />";
                        
                        				// Display Value for each bar in graph
                        				rowHTML+= "<p style='position:relative; left:" + w + "'><font face=arial size='-2'>&nbsp;"
                        				// See if Values needs to be displayed on graphs
                        				//if (document.getElementById("chkvaluepoint").checked == true)
                        				//	rowHTML+= percentageloaded +"%"
                        				rowHTML+= "</font></p>";
                        				rowHTML+= "</td></tr>";
                        				Content += rowHTML;
                        
                        			}
                        
                        
                        
                        			Content += "</tr>";
                        			Content += "</table>";
                        
                        			//if (document.getElementById("optShowInSameWindow").checked == true)
                        			//	    document.getElementById("dvChart").innerHTML = Content;
                        
                        		}
                        	}
                        return(Content)
                        }

                        function showCellData(data)
                        {
                         curr_element = document.getElementById(tableID);
                         alert("You are currently viewing resource loading data for date"+data);
                        }
                        
                        function generateChart(src)
                        {
                              var fso, fin, fout;
                              var data = new Array();
                              // Define constants for file access
                              var forReading   = 1;
                              var forWriting   = 2;
                              var forAppending = 8;
                              var mycontent = "<table id=tblgraph align=center width=48 cellpadding=1 cellspacing=0 border=0><tr><td>Uday</td>";
                              // Create File System Object and open input and output files
                              fso  = new ActiveXObject( "Scripting.FileSystemObject" );
                              fin  = fso.OpenTextFile( src, forReading );
                              // Loop through entire file
                              while( !fin.AtEndOfStream )
                              {
                                try
                                 {
                                  // Read the next line
                                   var line = fin.ReadLine();
                                    // If line if blank - skip it
                                  if( line == "" )
                                   continue;
                                  data = line.split( "," );
                                   calday = data[0];
                                   manhour = data[1];
                                   caldate = data[2];
                                   //mycontent = mycontent + "<td>";
                                   tempcontent = createChartObject(calday,manhour,caldate);
                                   //alert(tempcontent);
                                   mycontent = mycontent + "<td>" + tempcontent + "</td>";
                        
                                }
                                catch( e )
                                {
                                     //WScript.Echo( "Error: " + e.description );
                                }
                              }
                              fin.Close();
                              mycontent += "</tr></table>";
                        
                              document.getElementById("dvChart").innerHTML = mycontent;
                        }

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

                        function sizeFrame()
                        {
                          var F = document.getElementById("iframe_a");
                          if(F.contentDocument)
                           {
                            F.height = F.contentDocument.documentElement.scrollHeight+30; //FF 3.0.11, Opera 9.63, and Chrome
                           }
                            else
                           {
                             F.height = F.contentWindow.document.body.scrollHeight+30; //IE6, IE7 and Chrome
                           }
                        }

                        </script>


                        
                      <div id="bodyColumn"><div id="contentBox"><div class="section">
                      <div align="center">
                      ~;

                      $username_arrayref = $session->param("resourcename");

                      @usernames = @$username_arrayref;
                      $number_of_resources = scalar(@usernames);

                      if($number_of_resources>0)
                      {
                        $testing_name = join(",",@usernames);
                      }
                      else
                      {
                       @usernames = ();
                       $username = $session->param("resourcename");

                       if($username_arrayref=~/^\w+,.*$/)
                       {
                        @usernames = split(",",$username_arrayref);
                       }

                       push(@usernames,$username);
                      }
                      $testing_name = join(",",@usernames);
                      $singleday = $session->param("singledayField");
                      $duration_from = $session->param("durationfromField");
                      $duration_to = $session->param("durationtoField");

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

                       print "<table width=87%  border='0' cellpadding='3'>";
                       print "<th class='TableColumnHeader' width=85%>Resource Workload :</th>";
                       print "</table>";
                       print "<div style=height:310px;width:85%;overflow:scroll >";
                       print "<table id=tblgraph cellpadding=0 cellspacing=0 border=1>";

                      if($singleday ne "")
                      {

                          if($singleday=~/(\d+)-(.*)-(\d+)/)
                          {
                            $day = $1;
                            $month_alphabetic = $2;
                            $month = $months{$month_alphabetic};
                            $year = $3;
                          }

                          $taskdate = $year . "-" . $month . "-" .  $day;
                          #######
                          foreach $name (@usernames)
                          {
                                $query = "SELECT SUM(task_manhour),task_date from task_global where task_date='$taskdate' and username='$username';";
                                my $sth = $dbh->prepare("SELECT SUM(task_manhour),task_date from task_global where task_date='$taskdate' and task_username='$name';");
                                $sth->execute() || die "$DBI::errstr\n";
                                while (@resultset = $sth->fetchrow_array) 
                                {
                                      #$size = $resultset[0];
                                      if(($resultset[0] ne "") and ($resultset[1] ne ""))
                                      {
                                        #$flag = "if";
                                        $totalmanhr = $resultset[0];
                                        $searchdate = $resultset[1];
                                        $workload{$searchdate} = $totalmanhr;
                                      }
                                      else
                                      {
                                        #$flag = "else";
                                        $workload{$taskdate} = 0;
                                      }
                                }
                                $sth->finish();

                                print "<tr>";
                                $full_name = getfullname($name);
                                print "<td ><font color=black><b>$full_name&nbsp;&nbsp;&nbsp;&nbsp;<b><font></td>";
                                foreach $key (keys %workload)
                                {

                                  $calendarday = "";
                                  $manhourrload = $workload{$key};
                                  $calendardate = $key;

                                  $manhourrload = ($manhourrload/60);

                                  $tempcontent = createChartObject($calendarday,$manhourrload,$calendardate,$name);
                                  print "<td width=75 >" . $tempcontent . "</td>";

                                }
                                print "</tr>";


                          }
                          $dbh->disconnect();
                          #print "<tr><td>Query</td><td>$query</td></tr>";
                          print "</table>";
                          ########

                      }
                      elsif(($duration_from ne "") or ($duration_to ne ""))
                      {
                        
                        ####
                        if(($duration_from ne "") and ($duration_to ne ""))
                        {
                          
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


                          foreach $name (@usernames)
                          {


                            print "<tr>";
                            $full_name = getfullname($name);
                            print "<td><font color=black><b>$full_name&nbsp;&nbsp;&nbsp;&nbsp;<b><font></td>";


                            foreach $date (@dates)
                            {
                             
                                    #$query = "SELECT SUM(task_manhour),task_date from task_global where task_date='$date' and username='$name';";
                                    my $sth = $dbh->prepare("SELECT SUM(task_manhour),task_date from task_global where task_date='$date' and task_username='$name';");
                                    $sth->execute() || die "$DBI::errstr\n";
                                    while (@resultset = $sth->fetchrow_array) 
                                    {
                                      #$size = $resultset[0];
                                        if(($resultset[0] ne "") and ($resultset[1] ne ""))
                                        {
                                          #$flag = "if";
                                          #$totalmanhr = $resultset[0];
                                          #$searchdate = $resultset[1];
                                          #$workload{$searchdate} = $totalmanhr;
                                          $calendarday = "";
                                          $manhourrload = $resultset[0];
                                          $calendardate = $resultset[1];
                                        }
                                        else
                                        {
                                          #$flag = "else";
                                          #$workload{$date} = 0;
                                          $calendarday = "";
                                          $calendardate = $date;
                                          $manhourrload = 0;
                                        }
                                    }
                                    $sth->finish();

                                    #foreach $key (keys %workload)
                                    #{

                                    #  $calendarday = "";
                                    #  $manhourrload = $workload{$key};
                                    #  $calendardate = $key;
                                    #}
                                      
                                      
                                      $manhourrload = ($manhourrload/60);
                                      $tempcontent = createChartObject($calendarday,$manhourrload,$calendardate,$name);
                                      print "<td width=75 >" . $tempcontent . "</td>";



                                }
                                print "</tr>";
                                $dbh->disconnect();
                                #print "<tr><td>Query</td><td>$query</td></tr>";
                        
                        
                        
                            } # name loop ends
                            print "</table>";
                        
                        } # Outside if loop ends
                        #########
                        elsif(($duration_from eq "") or ($duration_to eq ""))
                        {
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

                          foreach $name (@usernames)
                          {
                                #my $query = "SELECT SUM(task_manhour),task_date from task_global where task_date='$taskdate' and username='$username';";
                                my $sth = $dbh->prepare("SELECT SUM(task_manhour),task_date from task_global where task_date='$taskdate' and username='$name';");
                                $sth->execute() || die "$DBI::errstr\n";
                                while (@resultset = $sth->fetchrow_array) {
                                      $totalmanhr = $resultset[0];
                                      $searchdate = $resultset[1];
                                      $workload{$searchdate} = $totalmanhr;
                                }
                                $sth->finish();

                                print "<tr>";
                                print "<td>$name</td>";
                                foreach $key (keys %workload)
                                {

                                  $calendarday = "";
                                  $manhourrload = $workload{$key};
                                  $calendardate = $key;



                                  $manhourrload = ($manhourrload/60);
                                  $tempcontent = createChartObject($calendarday,$manhourrload,$calendardate);
                                  print "<td>" . $tempcontent . "</td>";

                                }
                                print "</tr>";


                          }
                          $dbh->disconnect();
                          print "</table>";



                         }
                       }
                       ######



                       #@keys = keys(%workload);
                       #$number_of_keys = scalar(@keys);
                       #print "<table width=87%  border='0' cellpadding='3'>";
                       #print "<th class='TableColumnHeader' width=85%>Resource Workload. Number of keys is $number_of_keys</th>";
                       #print "</table>";
                       #print "<div style=height:460px;width:800px;overflow:scroll >";
                       #print "<table id=tblgraph cellpadding=0 cellspacing=0 border=0>";
                       #print "<tr>";
                       #print "<td>$username</td>";

                       #foreach $key (keys %workload)
                       #{
                       #
                       # $calendarday = "";
                       # $manhourrload = $workload{$key};
                       # $calendardate = $key;
                       #
                       # $tempcontent = createChartObject($calendarday,$manhourrload,$calendardate);
                       # print "<td>" . $tempcontent . "</td>";

                       #}
                      #print "</tr>";
                      print "</table>";
                      print "</div>";
                      print "<iframe name='iframe_a' style=height:150px;width:81%;  frameborder=0 scrolling=auto ></iframe>";
                      #print qq~


                      &footer();

}
elsif($session->param("action") eq "display_user_task")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    #$myname = $session->param("usr");
    $myclickname = $session->param("clickedusername");
    $myclickdate = $session->param("clickeduserdate");

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

    if($myclickdate=~/(\d+)-(.*)-(\d+)/)
   {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


    print "<html>\n";
    print "<head>\n";
    print "<meta http-equiv=Content-Type content=text/html; charset=windows-1251>";
    print "<title>Pogo QA Resourcing : Time Card Entry </title>\n";
    print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/.css type=text/css>\n";
    print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/jsDatePick_ltr.min.css>\n";
    print "<link rel=stylesheet href=http://192.168.56.228/webapp/css/site.css type=text/css>\n";
    print "<style type=\"text/css\" media=print></style></head>\n";
    print "<table width=100%  border='0' cellpadding='3'>";
    print "<th class='TableColumnHeader'>Workload Details of user $myclickname on date $date</th>";
    print "<tr class='TableColumnHeader'><td>Task Category</td><td>Task Comments</td><td>Project</td><td>Task Duration</td><td>Task Priority</td><td>Task By</td><td>Task Status</td><td>Activity ID</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select task_cat,task_comments,task_projname,task_manhour,task_priority,task_assigned_by,task_status,activity_id from task_global where task_username='$myclickname' and task_date='$date';");
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
     my $activity_id = $resultset[7];

     $task_manhour = ($task_manhour/60);
     print "<tr><td class='TableCellText'>$task_cat</td><td class='TableCellText'>$task_comments</td><td class='TableCellText'>$task_projname</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_priority</td><td class='TableCellText'>$task_assignedby</td><td class='TableCellText'>$task_status</td><td class='TableCellText'>$activity_id</td></tr>";
    }
    print "</table>";
    print "</head>";
    print "</html>";
}
elsif($session->param("action") eq "view_tasks_under_activity")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);

    $myname = $session->param("usr");
    &header($myname);


    $myclickname = $session->param("timecard_user");
    $myclickdate = $session->param("singledayField");
    $activity = $session->param("activity");
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

    if($myclickdate=~/(\d+)-(.*)-(\d+)/)
   {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


    print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    <table width=87%  border='0' cellpadding='3'>
    <th class='TableColumnHeader' width=100% >Tasks Under Activity $activity:</th>
    </table>
    ~;
    print "<table width=87%  border='0' cellpadding='3'>";
    print "<tr class='TableColumnHeader'><td>Task Category</td><td>Task Comments</td><td>Project</td><td>Task Duration in Hr</td><td>Task Priority</td><td>Task Assigned By</td><td>Task Status</td><td>Activity ID</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select task_id,task_comments,task_projname,task_manhour,task_priority,task_assigned_by,task_status,activity_id from task_global where activity_id='$activity';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     my $task_id = $resultset[0];
     my $task_comments = $resultset[1];
     my $task_projectname = $resultset[2];
     my $task_manhour = $resultset[3];
     my $task_priority = $resultset[4];
     my $task_assignedby = $resultset[5];
     my $task_status = $resultset[6];
     my $activity_id = $resultset[7];

     $task_manhour = ($task_manhour/60);
     print "<tr><td class='TableCellText'>$task_id</td><td class='TableCellText'>$task_comments</td><td class='TableCellText'>$task_projectname</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_priority</td><td class='TableCellText'>$task_assignedby</td><td class='TableCellText'>$task_status</td><td class='TableCellText'>$activity_id</td></tr>";
    }
    print "</table>";
    print "</div>";
    &footer();
}
elsif($session->param("action") eq "view_timecard_submit")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    #$myname = $session->param("resourcename");
    $session->load_param($cgi);

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);

    $myname = $session->param("usr");
    &header($myname);


    $myclickname = $session->param("timecard_user");
    $myclickdate = $session->param("singledayField");

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

    if($myclickdate=~/(\d+)-(.*)-(\d+)/)
   {
      $today = $1;
      $tomonth_alphabetic = $2;
      $tomonth = $months{$tomonth_alphabetic};
      $toyear = $3;

    }

    $date = $toyear . "-" . $tomonth . "-" .  $today;


    print qq~
    <div id="bodyColumn"><div id="contentBox"><div class="section">
    <div align="center">
    <div></div>
    <div><p></p><p></p></div>
    <table width=87%  border='0' cellpadding='3'>
    <th class='TableColumnHeader' width=100% >View Resource Time Card :</th>
    </table>
    ~;
    print "<table width=87%  border='0' cellpadding='3'>";
    print "<th width=100% class='TableColumnHeader'>Workload Details of user $myclickname on date $date</th>";
    print "</table>";
    print "<table width=87%  border='0' cellpadding='3'>";
    print "<tr class='TableColumnHeader'><td>Task Category</td><td>Task Comments</td><td>Project</td><td>Task Duration in Hr</td><td>Task Priority</td><td>Task Assigned By</td><td>Task Status</td><td>Activity ID</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select task_cat,task_comments,task_projname,task_manhour,task_priority,task_assigned_by,task_status,activity_id from task_global where task_username='$myclickname' and task_date='$date';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
     my $task_category = $resultset[0];
     my $task_comments = $resultset[1];
     my $task_projectname = $resultset[2];
     my $task_manhour = $resultset[3];
     my $task_priority = $resultset[4];
     my $task_assignedby = $resultset[5];
     my $task_status = $resultset[6];
     my $activity_id = $resultset[7];

     $task_manhour = ($task_manhour/60);
     print "<tr><td class='TableCellText'>$task_category</td><td class='TableCellText'>$task_comments</td><td class='TableCellText'>$task_projectname</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_priority</td><td class='TableCellText'>$task_assignedby</td><td class='TableCellText'>$task_status</td><td class='TableCellText'>$activity_id</td></tr>";
    }
    print "</table>";
    print "</div>";
    &footer();
}
elsif($session->param("action") eq "daily_status_report")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("resourcename");
    $myname = $session->param("usr");
    #$session->load_param($cgi);
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mail_daily_status_report');

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    $myname = $session->param("usr");

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
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;

    my %sev_name_id = (10 => 'Minor',20 => 'Medium',30 => 'Major',40 => 'Critical');
    my %pri_name_id = (10 => 'None',20 => 'Low',30 => 'Normal',40 => 'High',50 => 'Urgent',60 => 'Immediate');
    my %status_name_id = (10 => 'New',20 => 'Clarifcation Needed',80 => 'Resolved',90 => 'Closed');


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<div></div><div><p></p><p></p></div>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Daily Status Report For user $myname on date $mysql_date</th>";
    print "</table>";


    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table border=1 cellpadding=3>";
    ########## Activities completed today ##################
    

    print  "<th colspan=9 class='TableColumnHeader'>Activities Completed By <font color=green>$myname</font> today</th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status = 'Completed' and b.activity_owner='$myname' and b.activity_actual_end_date = '$mysql_date' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }


    #######################################################################
    
    ########### Activities assigned to and Status is  assigned ##############
    print  "<th colspan=9 class='TableColumnHeader'>Activities Assigned To <font color=green>$myname</font> and Status is <font color=green>'Assigned'</font></th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('Assigned') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }

    
    
    ############################

    ########### Activities assigned to and Status is planned #################
    print  "<th colspan=9 class='TableColumnHeader'>Activities Assigned To <font color=green>$myname</font> and Status is <font color=green>'Planned'</font></th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('Planned') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }

    
    
    ############################

    ########### Activities assigned to and Status is in progress #################
    print  "<th colspan=9 class='TableColumnHeader'>Activities Assigned To <font color=green>$myname</font> and Status is <font color=blue>'In Progress'</font></th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('In Progress') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }

    
    
    ############################
    print  "<th colspan=9 class='TableColumnHeader'>Tasks Worked on</th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Task Cat</td><td class='TableColumnHeader' colspan='3'>Comments</td><td class='TableColumnHeader'>Project Name</td><td class='TableColumnHeader'>Man Hr</td><td class='TableColumnHeader'>Assigned By</td><td class='TableColumnHeader' >Status</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT task_cat,task_comments,task_projname,task_manhour,task_assigned_by,task_status,activity_id from task_global where task_username='$myname' and task_date='$mysql_date';");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $task_cat = $resultset[0];
     my $task_comments = $resultset[1];
     my $task_projname = $resultset[2];
     my $task_manhour = $resultset[3];
     my $task_assigned_by = $resultset[4];
     my $task_status = $resultset[5];
     my $activity_id = $resultset[6];



     $task_manhour = ($task_manhour/60);
     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$task_cat</td><td class='TableCellText' colspan='3'>$task_comments</td><td class='TableCellText'>$task_projname</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_assigned_by</td><td class='TableCellText'>$task_status</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }


    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT first_name from resources where username='$myname';");
    $sth->execute() || die "$DBI::errstr\n";
    while ($resultset = $sth->fetchrow_array)
    {
      $user_first_name = $resultset;
    }
    $sth->finish();
    $dbh->disconnect();
    print "<form id=timecardentry action=display_workload.pl method=post>";
    #print "</table>";
    #print "<p></p>";
    #print "<p></p>";
    #print "<p></p>";


    $mantis_username = getmantisusername($myname);

    #print  "<table cellpadding=3 border=0>";
    ##############################################
  
    print  "<th colspan=9 class='TableColumnHeader'>Bugs Logged</th>";
    #print  "</table>";
    #print  "<table border=0 cellpadding=3 >";
    print  "<tr>";
    print  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Logged By</td><td class=TableColumnHeader>Date Logged</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    print  "</tr>";

  
    # Bugs logged today
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.id,b.name as 'Project',c.name as 'Category',d.username as 'Reported By', FROM_UNIXTIME(a.date_submitted,'%Y-%m-%d') as 'Logged Date',a.severity, a.priority,a.status,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e where a.project_id=b.id and a.category_id=c.id and a.id=e.id and a.reporter_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(a.date_submitted,'%Y-%m-%d') = '$mysql_date';");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
       $row_count++;
       print  "<tr>";
       print  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td></td><td class=TableCellText>$resultset[8]</td>";
       print  "</tr>";
     }
    $sth->finish();
    
    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }
   
    ##############################################
  
     print  "<th colspan=9 class='TableColumnHeader'>Bugs Reopened </th>";
    #print BUGREP "</table>";
    #print BUGREP "<table border=0 cellpadding=3 >";
    print  "<tr>";
    print  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Reopened By</td><td class=TableColumnHeader>Reopened On</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    print  "</tr>";
  
  
    # Bugs reopened
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select f.bug_id as 'Bug ID', b.name as 'Project',c.name as 'Category',d.username as 'Updated By', FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') as 'Updated Date', a.severity, a.priority,f.new_value,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e , mantis_bug_history_table f where f.field_name='status' and ((f.old_value='80' and f.new_value='10') or (f.old_value='90' and f.new_value='10')) and f.bug_id=a.id and a.project_id=b.id and a.category_id=c.id and a.id=e.id and f.user_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') = '$mysql_date' order by f.bug_id ;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
      $row_count++;
      print  "<tr>";
      print  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td><td class=TableCellText>$resultset[8]</td>";
      print  "</tr>";
     }
    $sth->finish();
  
    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }
    ##############################################
  
    print  "<th colspan=9 class='TableColumnHeader'>Bugs Closed </th>";
    #print BUGREP "</table>";
    #print BUGREP "<table border=0 cellpadding=3 >";
    print  "<tr>";
    print  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Closed By</td><td class=TableColumnHeader>Closed On</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    print  "</tr>";
  
  
    # Bugs Closed
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select f.bug_id as 'Bug ID', b.name as 'Project',c.name as 'Category',d.username as 'Updated By', FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') as 'Updated Date', a.severity, a.priority,f.new_value,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e , mantis_bug_history_table f where f.field_name='status' and f.old_value='80' and f.new_value='90' and f.bug_id=a.id and a.project_id=b.id and a.category_id=c.id and a.id=e.id and f.user_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') = '$mysql_date' order by f.bug_id ;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
      $row_count++;
      print  "<tr>";
      print  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td><td class=TableCellText>$resultset[8]</td>";
      print  "</tr>";
     }
    $sth->finish();
  
    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }
    ##############################################
  
  
    $dbh->disconnect();
    #print  "</table>";
    #print "<table border=1 cellpadding=3>";
    print  "<th colspan=9 class='TableColumnHeader'>Leave Plan</th>";
    print "<tr><td class='TableColumnHeader'>Leave From Date</td><td class='TableColumnHeader'>Leave To Date</td><td class='TableColumnHeader'>Leave Type</td><td colspan=6 class='TableColumnHeader'>Leave Justification</td></tr>";
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT leave_fromdate,leave_todate,leave_type,leave_justification FROM user_leaves WHERE username='$myname'");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $leave_fromdate = $resultset[0];
     my $leave_todate = $resultset[1];
     my $leave_type = $resultset[2];
     my $leave_justification = $resultset[3];
     print "<tr><td class='TableCellText'>$leave_fromdate</td><td class='TableCellText'>$leave_todate</td><td class='TableCellText'>$leave_type</td><td colspan=6 class='TableCellText'>$leave_justification</td></tr>";
    }
    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }
    $sth->finish();
    $dbh->disconnect();
    print "</table>";

    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "<form id=timecardentry action=display_workload.pl method=post>";
    print "<tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Mail Report \" onclick=\"formvalidate()\"/></td>";
    #print "<td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick=\"formReset()\" /></tr>";
    print "</table>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "</table>";
    print "</form>";
    print "</div>";
    &footer();
}
elsif($session->param("action") eq "current_milestone_report")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("resourcename");
    $myname = $session->param("usr");
    #$session->load_param($cgi);
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mail_weekly_status_report');

    @parameters = $cgi->param();
    %goals = ();
    tie(%goals, Tie::IxHash);
    tie(%workload, Tie::IxHash);
    tie(%tasks_and_status, Tie::IxHash);
    $myname = $session->param("usr");

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
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<div></div><div><p></p><p></p></div>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Milestone Report</th>";
    print "</table>";


    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    #print "<table border=1 cellpadding=3>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Milestones Where Milestone Achieve Date Has Crossed or Is Today</th>";
    print "<tr><td class='TableColumnHeader'>Goal</td><td class='TableColumnHeader'>Milestone ID</td><td class='TableColumnHeader'>Milestone</td><td class='TableColumnHeader'>Milestone Target Date</td><td class='TableColumnHeader'>Milestone Status</td></tr>";

    ########## Select All Milestones whose end date has already crossed or is ending today ##################

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select b.goal_name,a.milestone_desc,a.milestone_date,a.milestone_achieved,a.milestone_id from milestone a, goals b WHERE a.goal_id = b. goal_id and a.milestone_achieved='No' and a.milestone_date <= CURDATE();");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $goal_name = $resultset[0];
     $milestone_desc = $resultset[1];
     $milestone_date = $resultset[2];
     $milestone_status = $resultset[3];
     $milestone_id = $resultset[4];

     print "<tr><td class='TableCellText'>$goal_name</td><td class='TableCellText'>$milestone_id</td><td class='TableCellText'>$milestone_desc</td><td class='TableCellText'>$milestone_date</td><td class='TableCellText'>$milestone_status</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();
    print "</table>";
    print "<p></p>";
    print "<p></p>";
    print "<p></p>";

    ########## Select All Milestones whose end date is 7 days from today ##################
    
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Upcoming Milestones</th>";
    print "<tr><td class='TableColumnHeader'>Goal</td><td class='TableColumnHeader'>Milestone ID</td><td class='TableColumnHeader'>Milestone</td><td class='TableColumnHeader'>Milestone Target Date</td><td class='TableColumnHeader'>Milestone Status</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select b.goal_name,a.milestone_desc,a.milestone_date,a.milestone_achieved,a.milestone_id from milestone a, goals b WHERE a.goal_id = b. goal_id and date(a.milestone_date) > CURDATE() and date(a.milestone_date) <= date_add(curdate(), interval 7 day)");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $goal_name = $resultset[0];
     $milestone_desc = $resultset[1];
     $milestone_date = $resultset[2];
     $milestone_status = $resultset[3];
     $milestone_id = $resultset[4];
     print "<tr><td class='TableCellText'>$goal_name</td><td class='TableCellText'>$milestone_id</td><td class='TableCellText'>$milestone_desc</td><td class='TableCellText'>$milestone_date</td><td class='TableCellText'>$milestone_status</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();
    print "</table>";



    #######################################################################

#     $message_body = $message_body . "</table>";
#     $message_body = $message_body . "</html>";


    print "</table>";

    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";

    #print "<form id=timecardentry action=display_param.pl method=post>";
    #print "<input type=hidden name=hidden_message_body id=hidden_message_body value=$message_body >";
    print "<form id=timecardentry action=display_workload.pl method=post>";

    #print "<tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Mail Report \" onclick=\"formvalidate()\"/></td>";
    #print "<td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick=\"formReset()\" /></tr>";
    print "</table>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "</table>";
    print "</form>";
    print "</div>";
    &footer();
}

elsif($session->param("action") eq "weekly_status_report")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("resourcename");
    $myname = $session->param("usr");
    #$session->load_param($cgi);
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mail_weekly_status_report');

    @parameters = $cgi->param();
    %goals = ();
    tie(%goals, Tie::IxHash);
    tie(%workload, Tie::IxHash);
    tie(%tasks_and_status, Tie::IxHash);
    $myname = $session->param("usr");

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
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<div></div><div><p></p><p></p></div>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Weekly Status Report of Automation Team</th>";
    print "</table>";


    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table border=1 cellpadding=3>";
    

    ########## Select All Goals That Were Worked on In the Last 7 days ##################
    
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select distinct(b.goal_id),b.goal_name from  activities a,goals b, task_transactions c  where a.activity_id=c.activity_id and b.goal_id = a.goal_id and date(c.task_update_date) >= date_sub(curdate(), interval 7 day);  ");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $goal_id = $resultset[0];
     $goal_name = $resultset[1];
     $goals{$goal_id} = $goal_name;
     }
    $sth->finish();
    $dbh->disconnect();

    @my_goals = keys (%goals);

    my $goal_count = 0;
    foreach $goal (@my_goals)
    {
       
       %activities = ();
       $task_id = "";
       $task_comments = "";
       $task_status = "";
       $goal_count++;
       print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
       print "<tr><td class='TableColumnHeader' colspan=5>Goal : $goal_count</td></tr>";
       print "<tr><td class='TableCellText' colspan=5>$goals{$goal}</td></tr>";
       print "</table>";
       
       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
       my $sth = $dbh->prepare("select distinct(a.activity_id),a.activity_desc from  activities a, task_transactions c  where a.activity_id=c.activity_id and a.goal_id = '$goal' and date(c.task_update_date) >= date_sub(curdate(), interval 7 day);  ");
       $sth->execute() || die "$DBI::errstr\n";
       my $row_count = 0;
       while (@resultset = $sth->fetchrow_array)
       {
        $activity_id = $resultset[0];
        $activity_desc = $resultset[1];
        $activities{$activity_id} = $activity_desc;
        }
       $sth->finish();
       $dbh->disconnect();

       my $activity_count = 0;

       foreach $activity (keys %activities)
       {
         
         $activity_count++;
          print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
          print "<tr><td class='TableColumnHeader' colspan=5>&nbsp;&nbsp;&nbsp;&nbsp;Activity : $activity_count</td></tr>";
          print "<tr><td class='TableCellText' colspan=5>&nbsp;&nbsp;&nbsp;&nbsp;$activities{$activity}</p></td></tr>";

          print "</table>";

#           $message_body = $message_body . "<table border='0' cellpadding='3' width=350px>";
#           $message_body = $message_body . "<th class='TableColumnHeader'>Activity : $activities{$activity}</th>";
#           $message_body = $message_body . "</table>";


          print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
          
          print "<tr><td class='TableColumnHeader'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Task Details</td><td class='TableColumnHeader'>Resource</td><td class='TableColumnHeader'>Last Update</td><td class='TableColumnHeader'>% Complete</td><td class='TableColumnHeader'>ETA</td></tr>";
          
#           $message_body = $message_body . "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#           $message_body = $message_body . "<tr><td class='TableColumnHeader'>Task Details</td><td class='TableColumnHeader'>Resource</td><td class='TableColumnHeader'>Last Update</td><td class='TableColumnHeader'>% Complete</td><td class='TableColumnHeader'>ETA</td></tr>";

          %tasks_and_status = ();

          my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
          my $sth = $dbh->prepare("select a.task_id,a.task_update_date from task_transactions a where a.activity_id = '$activity' and date(a.task_update_date) >= date_sub(curdate(), interval 7 day) ;");
          $sth->execute() || die "$DBI::errstr\n";
          my $row_count = 0;
          while (@resultset = $sth->fetchrow_array)
          {
           $task_id = $resultset[0];
           $task_update_date = $resultset[1];
           $tasks_and_status{$task_id} = $task_update_date;
          }



          foreach $key (keys %tasks_and_status)
          {
            my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
            my $sth = $dbh->prepare("select task_username,task_comments,task_percentage_complete,task_eta from task_global where task_id='$key';");
            $sth->execute() || die "$DBI::errstr\n";
            my $row_count = 0;
            while (@resultset = $sth->fetchrow_array)
            {
             $task_resource = $resultset[0];
             $task_comments = $resultset[1];
             $task_percentage_complete = $resultset[2];
             $task_eta = $resultset[3];

             print "<tr><td class='TableCellText'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$task_comments</td><td class='TableCellText'>$task_resource</td><td class='TableCellText'>$tasks_and_status{$key}</td><td class='TableCellText'>$task_percentage_complete</td><td class='TableCellText'>$task_eta</td></tr>";
#              $message_body = $message_body . "<tr><td class='TableCellText'>$task_comments</td><td class='TableColumnHeader'>$task_resource</td><td class='TableCellText'>$tasks_and_status{$key}</td><td class='TableCellText'>$task_percentage_complete</td><td class='TableCellText'>$task_eta</td></tr>";
            }
          }

          print "<table>";
#           $message_body = $message_body . "<table>";

          $sth->finish();
          $dbh->disconnect();
       } # end of activity

    }



    #######################################################################
    
#     $message_body = $message_body . "</table>";
#     $message_body = $message_body . "</html>";


    print "</table>";

    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";

    #print "<form id=timecardentry action=display_param.pl method=post>";
    #print "<input type=hidden name=hidden_message_body id=hidden_message_body value=$message_body >";
    print "<form id=timecardentry action=display_workload.pl method=post>";

    print "<tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Mail Report \" onclick=\"formvalidate()\"/></td>";
    #print "<td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick=\"formReset()\" /></tr>";
    print "</table>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "</table>";
    print "</form>";
    print "</div>";
    &footer();
}
elsif($session->param("action") eq "mail_weekly_status_report")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->load_param($cgi);
    $session->clear(["action"]);

    @parameters = $cgi->param();
    @my_goals = ();
    %goals = ();
    tie(%goals, Tie::IxHash);

    #$message_body = $session->param("hidden_message_body");
    
    
    
    $message_body = "<html><head><title>Weekly Test Execution By QA Team</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1+\"><link rel=stylesheet href=http://192.168.56.228/webapp/css/my.css type=text/css></head><body marginwidth=\"0\" marginheight=\"0\">";



    ########## Select All Goals That Were Worked on In the Last 7 days ##################
    
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("select distinct(b.goal_id),b.goal_name from  activities a,goals b, task_transactions c  where a.activity_id=c.activity_id and b.goal_id = a.goal_id and date(c.task_update_date) >= date_sub(curdate(), interval 7 day);  ");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $goal_id = $resultset[0];
     $goal_name = $resultset[1];
     $goals{$goal_id} = $goal_name;
     }
    $sth->finish();
    $dbh->disconnect();

    @my_goals = keys (%goals);
    
    my $goal_count = 0;
    foreach $goal (@my_goals)
    {

       $goal_count++;
       %activities = ();
       $task_id = "";
       $task_comments = "";
       $task_status = "";


       $message_body = $message_body . "<table border='0' cellpadding='3' width=350px>";  # start of goal table
       $message_body = $message_body . "<tr><td class='TableColumnHeader' colspan=5>Goal : $goal_count</td></tr>";
       $message_body = $message_body . "<tr><td class='TableCellText' colspan=5>$goals{$goal}</td></tr>";




#        my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#        my $sth = $dbh->prepare("select distinct(a.activity_id),a.activity_desc from  activities a, task_transactions c  where a.activity_id=c.activity_id and a.goal_id = '$goal' and date(c.task_update_date) >= date_sub(curdate(), interval 7 day);  ");
#        $sth->execute() || die "$DBI::errstr\n";
#        my $row_count = 0;
#        while (@resultset = $sth->fetchrow_array)
#        {
#         $activity_id = $resultset[0];
#         $activity_desc = $resultset[1];
#         $activities{$activity_id} = $activity_desc;
#         }
#        $sth->finish();
#        $dbh->disconnect();
# 
#        my $activity_count = 0;
#        foreach $activity (keys %activities)
#        {
#           $activity_count++;
#           $message_body = $message_body . "<tr><td>"; # start of row for activity table
#           $message_body = $message_body . "<table border='0' cellpadding='3' width=350px>"; # start of activity table
#           $message_body = $message_body . "<tr><td class='TableColumnHeader' colspan=5>Activity : $activity_count</td></tr>";
#           $message_body = $message_body . "<tr><td class='TableCellText' colspan=5>$activities{$activity}</td></tr>";
#           #$message_body = $message_body . "</table>";
# 
# 
#           #$message_body = $message_body . "<table width=87% border=0 cellpadding=3 width=350px border=1>";
#           #$message_body = $message_body . "<th class='TableColumnHeader'>Tasks : </th>";
#           $message_body = $message_body . "<tr><td class='TableColumnHeader'>Task Details</td><td class='TableColumnHeader'>Resource</td><td class='TableColumnHeader'>Last Update</td><td class='TableColumnHeader'>% Complete</td><td class='TableColumnHeader'>ETA</td></tr>";
# 
#           %tasks_and_status = ();
# 
#           my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#           my $sth = $dbh->prepare("select a.task_id,a.task_update_date from task_transactions a where a.activity_id = '$activity' and date(a.task_update_date) >= date_sub(curdate(), interval 7 day) ;");
#           $sth->execute() || die "$DBI::errstr\n";
#           my $row_count = 0;
#           while (@resultset = $sth->fetchrow_array)
#           {
#            $task_id = $resultset[0];
#            $task_update_date = $resultset[1];
#            $tasks_and_status{$task_id} = $task_update_date;
#           }
# 
#           foreach $key (keys %tasks_and_status)
#           {
#             my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
#             my $sth = $dbh->prepare("select task_username,task_comments,task_percentage_complete,task_eta from task_global where task_id='$key';");
#             $sth->execute() || die "$DBI::errstr\n";
#             my $row_count = 0;
#             while (@resultset = $sth->fetchrow_array)
#             {
#              $task_resource = $resultset[0];
#              $task_comments = $resultset[1];
#              $task_percentage_complete = $resultset[2];
#              $task_eta = $resultset[3];
# 
#              $message_body = $message_body . "<tr><td class='TableCellText'>$task_comments</td><td class='TableColumnHeader'>$task_resource</td><td class='TableCellText'>$tasks_and_status{$key}</td><td class='TableCellText'>$task_percentage_complete</td><td class='TableCellText'>$task_eta</td></tr>";
#             }
#           }
# 
#           #$message_body = $message_body . "<table>";
# 
#           $sth->finish();
#           $dbh->disconnect();
#           
#           $message_body = $message_body . "<table>"; # end of activity table
#           $message_body = $message_body . "</td></tr>"; # end of row for holding activity table
#        } # end of activity
# 
# 
#       $message_body = $message_body . "<table>"; # end of goal table
    } # end of goal





    #######################################################################
    
    $message_body = $message_body . "</table>";
    $message_body = $message_body . "</html>";


    $mailfrom = "smitra\@yodlee.com";
    $mailto = "smitra\@yodlee.com";
    #$mailto = "sjain\@yodlee.com";
    #$mailcc = "smitra\@yodlee.com,SDharmaraj\@yodlee.com";

    $mail_subject = "[Automated Weekly Status Report] Activities Worked By Automation Team In The Last Week";

   $msg = MIME::Lite->new(
        From     => $mailfrom,
        To       => $mailto,
        Cc       => $mail_cc,
        Subject  => $mail_subject,
        Type     => 'multipart/mixed',
    );
   $msg->attach(
         Type     => 'text/html',
         Data     => $message_body
    );

  $msg->send('smtp','192.168.211.175', Debug=>1 ); # send via default

    
    &header($myname);
    
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Status Report Send Status</th>";
    print "</table>";


    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader' width=100%></th>";
    print "<tr><td>Status Report Sent successfully</td></tr>";
    print "</table>";
    print "</div>";
    &footer();


}
elsif($session->param("action") eq "delayed_activities")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("resourcename");
    $myname = $session->param("usr");
    #$session->load_param($cgi);
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mail_daily_status_report');

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    $myname = $session->param("usr");

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
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;

    my %sev_name_id = (10 => 'Minor',20 => 'Medium',30 => 'Major',40 => 'Critical');
    my %pri_name_id = (10 => 'None',20 => 'Low',30 => 'Normal',40 => 'High',50 => 'Urgent',60 => 'Immediate');
    my %status_name_id = (10 => 'New',20 => 'Clarifcation Needed',80 => 'Resolved',90 => 'Closed');


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<div></div><div><p></p><p></p></div>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Activities That Have Crossed Planned End Date</th>";
    print "</table>";


    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table border=1 cellpadding=3>";
    ########## Activities completed today ##################


    print  "<th colspan=9 class='TableColumnHeader'>Delayed Activities</th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Activity Owner</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments,b.activity_owner from activities a, activity_details b where a.activity_id=b.id and DATEDIFF(CURDATE(),b.activity_planned_end_date) >= 1;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];
     my $activity_owner = $resultset[8];



     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_owner</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }


    #######################################################################

    ########### Activities assigned to and Status is  assigned ##############
    print "</table>";
    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    #print "<tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Mail Report \" onclick=\"formvalidate()\"/></td>";
    #print "<td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick=\"formReset()\" /></tr>";
    print "</table>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "</table>";
    print "</form>";
    print "</div>";
    &footer();
}

elsif($session->param("action") eq "today_deadline")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("resourcename");
    $myname = $session->param("usr");
    #$session->load_param($cgi);
    
    $session->clear();
    $session->param(usr=>$myname);
    $session->param(action=>'mail_daily_status_report');

    @parameters = $cgi->param();
    tie(%workload, Tie::IxHash);
    $myname = $session->param("usr");

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
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;

    my %sev_name_id = (10 => 'Minor',20 => 'Medium',30 => 'Major',40 => 'Critical');
    my %pri_name_id = (10 => 'None',20 => 'Low',30 => 'Normal',40 => 'High',50 => 'Urgent',60 => 'Immediate');
    my %status_name_id = (10 => 'New',20 => 'Clarifcation Needed',80 => 'Resolved',90 => 'Closed');


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<div></div><div><p></p><p></p></div>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Activities Whose Planned End Date Is Today</th>";
    print "</table>";


    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table border=1 cellpadding=3>";
    ########## Activities completed today ##################


    print  "<th colspan=9 class='TableColumnHeader'>Today's Deadline</th>";
    print "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Activity Owner</td><td class='TableColumnHeader'>Activity Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments,b.activity_owner from activities a, activity_details b where a.activity_id=b.id and DATEDIFF(CURDATE(),b.activity_planned_end_date) = 0;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];
     my $activity_owner = $resultset[8];




     print "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_owner</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      print  "<tr>";
      print  "<td colspan=9 class=TableCellText>None</td>";
      print  "</tr>";
    }


    #######################################################################

    ########### Activities assigned to and Status is  assigned ##############
    print "</table>";
    print "<p></p>";
    print "<p></p>";
    print "<p></p>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    #print "<tr><td align='center' border=0 cellpadding=3><input type=submit class=TableCellIconButton value=\"Mail Report \" onclick=\"formvalidate()\"/></td>";
    #print "<td  border=0 cellpadding=3><input type=button class=submitButtonEnable1 value=\"Clear Form\" onclick=\"formReset()\" /></tr>";
    print "</table>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    #print "<th class='TableColumnHeader' width=100%></th>";
    print "</table>";
    print "</form>";
    print "</div>";
    &footer();
}

elsif($session->param("action") eq "mail_daily_status_report")
{
    print $cgi->header(-cache_control=>"no-cache, no-store, must-revalidate");
    $myname = $session->param("usr");
    $session->load_param($cgi);
    $session->clear(["action"]);

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT first_name from resources where username='$myname';");
    $sth->execute() || die "$DBI::errstr\n";
    while ($resultset = $sth->fetchrow_array)
    {
      $user_first_name = $resultset;
    }
    $sth->finish();
    $dbh->disconnect();


    @parameters = $cgi->param();

    $outstanding_user_bug_count = $session->param("outstanding_user_bug_count");
    $bugs_written_url = $session->param("bugs_written_url");
    $blocking_issues = $session->param("blocking_issues");
    $training_needed = $session->param("training_needed");
    $what_i_learned_today = $session->param("what_i_learned_today");
    $objectives_for_next_day = $session->param("objectives-for_next_day");

    @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $htmldate = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";

    @months = qw(01 02 03 04 05 06 07 08 09 10 11 12);
    @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
   ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    $year = 1900 + $yearOffset;
    $dbdate = $year ."-" . $months[$month] ."-" . $dayOfMonth;

    $month = $month + 1;

    if($month=~/^\d$/)
    {
     $month = "0" . $month;
    }
    if($dayOfMonth=~/^\d$/)
    {
     $dayOfMonth = "0" . $dayOfMonth;
     }
    $mysql_date = $year . "-". $month . "-" . $dayOfMonth;

    my %sev_name_id = (10 => 'Minor',20 => 'Medium',30 => 'Major',40 => 'Critical');
    my %pri_name_id = (10 => 'None',20 => 'Low',30 => 'Normal',40 => 'High',50 => 'Urgent',60 => 'Immediate');
    my %status_name_id = (10 => 'New',20 => 'Clarifcation Needed',80 => 'Resolved',90 => 'Closed');


    &header($myname);
    print "<div id=bodyColumn><div id=contentBox><div class=section>";
    print "<div align=center>";
    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader'>Daily Status Report Send Status</th>";
    print "</table>";

    my $fullname = getfullname($myname);

    my $fromemailid = getemailid($myname);
    my $toemailid = "smitra\@yodlee.com";
    #my $toemailid = "saurabh.m\@apalya.com";
    #my $ccemailid = "janardhan.venkat\@apalya.myplex.tv,nagaraju.meka\@apalya.myplex.tv,sruthi.chekuri\@apalya.myplex.tv,kavya.kumari\@apalya.myplex.tv,anvesh.yalamarthy\@apalya.myplex.tv";
    my $ccemailid = "smitra\@yodlee.com";
    $mail_subject = "[Automated Daily status Report][Yodlee: Automation Team]" . $fullname  . "- " . $htmldate;



    $msg = MIME::Lite->new(
        From     => $fromemailid,
        To       => $toemailid,
	Cc       => $ccemailid,
        Subject  => $mail_subject,
        Type     => 'multipart/mixed',
    );

    $message_body = "<html><head>";
    #<title>Daily Status Report</title><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1+\"></head><body marginwidth=\"0\" marginheight=\"0\">";

    $message_body = $message_body . "<title>Daily Status Report : </title>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://192.168.56.228/webapp/css/.css type=text/css>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://192.168.56.228/webapp/css/jsDatePick_ltr.min.css>\n";
    $message_body = $message_body . "<link rel=stylesheet href=http://192.168.56.228/webapp/css/site.css type=text/css>\n";
    $message_body = $message_body . "<style type=\"text/css\" media=print></style></head>\n";



    $message_body = $message_body . "<p></p><p></p>";


    ##################################################################################################################################################

    $message_body = $message_body . "<table border=1 cellpadding=3>";
    ########## Activities completed today ##################
    

    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Activities Completed By <font color=green>$myname</font> today</th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status = 'Completed' and b.activity_owner='$myname' and b.activity_actual_end_date = '$mysql_date' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }


    #######################################################################
    
    
        ########### Activities Assigned to  and Status is Assigned #################
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Activities Assigned  To <font color=green>$myname</font> and Status is <font color=orange>'Assiged/'</font></th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('Assigned') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }

    
    
    ############################

         ########### Activities assigned to and Status is planned #################
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Activities Assigned  To <font color=green>$myname</font> and Status is <font color=green>'Planned/'</font></th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('Planned') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }

    
    
    ############################

    ########### Activities assigned to and Status is in progress #################
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Activities Currently Owned by <font color=blue>$myname</font> and Status is <font color=red>'In Progress'</font></th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Type</td><td class='TableColumnHeader'>Status</td><td class='TableColumnHeader'>Requestor Email</td><td class='TableColumnHeader'>Planned Start</td><td class='TableColumnHeader' >Planned End</td><td class='TableColumnHeader' >Description</td><td class='TableColumnHeader' colspan='2'>Comments</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT a.activity_id,a.activity_type,a.activity_status,a.activity_reqemail,b.activity_planned_start_date,b.activity_planned_end_date,a.activity_desc,a.activity_comments from activities a, activity_details b where a.activity_id=b.id and a.activity_status in ('In Progress') and b.activity_owner='$myname' order by b.activity_planned_end_date;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $activity_id = $resultset[0];
     my $activity_type = $resultset[1];
     my $activity_status = $resultset[2];
     my $activity_reqemail = $resultset[3];
     my $activity_planned_start_date = $resultset[4];
     my $activity_planned_end_date = $resultset[5];
     my $activity_desc = $resultset[6];
     my $activity_comments = $resultset[7];




     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$activity_type</td><td class='TableCellText'>$activity_status</td><td class='TableCellText'>$activity_reqemail</td><td class='TableCellText'>$activity_planned_start_date</td><td class='TableCellText'>$activity_planned_end_date</td><td class='TableCellText'>$activity_desc</td><td class='TableCellText' colspan='2'>$activity_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }

    
    
    ############################
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Tasks Worked on</th>";
    $message_body = $message_body . "<tr><td class='TableColumnHeader'>Activity ID</td><td class='TableColumnHeader'>Task Cat</td><td class='TableColumnHeader' colspan='3'>Comments</td><td class='TableColumnHeader'>Project Name</td><td class='TableColumnHeader'>Man Hr</td><td class='TableColumnHeader'>Assigned By</td><td class='TableColumnHeader' >Status</td></tr>";

    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT task_cat,task_comments,task_projname,task_manhour,task_assigned_by,task_status,activity_id from task_global where task_username='$myname' and task_date='$mysql_date';");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
     $row_count++;
     my $task_cat = $resultset[0];
     my $task_comments = $resultset[1];
     my $task_projname = $resultset[2];
     my $task_manhour = $resultset[3];
     my $task_assigned_by = $resultset[4];
     my $task_status = $resultset[5];
     my $activity_id = $resultset[6];



     $task_manhour = ($task_manhour/60);
     $message_body = $message_body . "<tr><td class='TableCellText'>$activity_id</td><td class='TableCellText'>$task_cat</td><td class='TableCellText' colspan='3'>$task_comments</td><td class='TableCellText'>$task_projname</td><td class='TableCellText'>$task_manhour</td><td class='TableCellText'>$task_assigned_by</td><td class='TableCellText'>$task_status</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }


    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT first_name from resources where username='$myname';");
    $sth->execute() || die "$DBI::errstr\n";
    while ($resultset = $sth->fetchrow_array)
    {
      $user_first_name = $resultset;
    }
    $sth->finish();
    $dbh->disconnect();


    ##################################################################################################################################################
    my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
    my $sth = $dbh->prepare("SELECT task_cat,task_comments,task_manhour,task_priority from task_global where task_username='$myname' and task_date='$dbdate';");
    $sth->execute() || die "$DBI::errstr\n";
    while (@resultset = $sth->fetchrow_array)
    {
      $task_cat = $resultset[0];
      $task_comments = $resultset[1];
      $task_manhour = $resultset[2];
      $task_priority = $resultset[3];
      $task_manhour = ($task_manhour/60);
      $message_body = $message_body . "<tr><td class='TableCellText'>$task_cat</td><td class='TableCellText'></td><td class='TableCellText'>$task_priority</td><td class='TableCellText'></td><td class='TableCellText'>$task_manhour</td><td class='TableCellText' colspan='4'>$task_comments</td></tr>";
    }
    $sth->finish();
    $dbh->disconnect();

    
    $mantis_username = getmantisusername($myname);

    #$message_body = $message_body .  "<table cellpadding=3 border=1>";
    ##############################################
  
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Bugs Logged</th>";
    #print  "</table>";
    #print  "<table border=0 cellpadding=3 >";
    $message_body = $message_body .  "<tr>";
    $message_body = $message_body .  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Logged By</td><td class=TableColumnHeader>Date Logged</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    $message_body = $message_body .  "</tr>";

  
    # Bugs logged today
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select a.id,b.name as 'Project',c.name as 'Category',d.username as 'Reported By', FROM_UNIXTIME(a.date_submitted,'%Y-%m-%d') as 'Logged Date',a.severity, a.priority,a.status,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e where a.project_id=b.id and a.category_id=c.id and a.id=e.id and a.reporter_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(a.date_submitted,'%Y-%m-%d') = '$mysql_date';");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
       $row_count++;
       $message_body = $message_body .  "<tr>";
       $message_body = $message_body .  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td></td><td class=TableCellText>$resultset[8]</td>";
       $message_body = $message_body .  "</tr>";
     }
    $sth->finish();
    
    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }
   
    ##############################################
  
     $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Bugs Reopened </th>";
    #print BUGREP "</table>";
    #print BUGREP "<table border=0 cellpadding=3 >";
    $message_body = $message_body .  "<tr>";
    $message_body = $message_body .  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Reopened By</td><td class=TableColumnHeader>Reopened On</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    $message_body = $message_body .  "</tr>";
  
  
    # Bugs reopened
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select f.bug_id as 'Bug ID', b.name as 'Project',c.name as 'Category',d.username as 'Updated By', FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') as 'Updated Date', a.severity, a.priority,f.new_value,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e , mantis_bug_history_table f where f.field_name='status' and ((f.old_value='80' and f.new_value='10') or (f.old_value='90' and f.new_value='10')) and f.bug_id=a.id and a.project_id=b.id and a.category_id=c.id and a.id=e.id and f.user_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') = '$mysql_date' order by f.bug_id ;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td><td class=TableCellText>$resultset[8]</td>";
      $message_body = $message_body .  "</tr>";
     }
    $sth->finish();
  
    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }
    ##############################################
  
    $message_body = $message_body .  "<th colspan=9 class='TableColumnHeader'>Bugs Closed </th>";
    #print BUGREP "</table>";
    #print BUGREP "<table border=0 cellpadding=3 >";
    $message_body = $message_body .  "<tr>";
    $message_body = $message_body .  "<td class=TableColumnHeader>Bug ID</td><td class=TableColumnHeader>Project</td><td class=TableColumnHeader>Category</td><td class=TableColumnHeader>Closed By</td><td class=TableColumnHeader>Closed On</td><td class=TableColumnHeader>Severity</td><td class=TableColumnHeader>Priority</td><td class=TableColumnHeader>Status</td><td class=TableColumnHeader>Description</td>";
    $message_body = $message_body .  "</tr>";
  
  
    # Bugs Closed
  
    my $dbh = DBI->connect("DBI:mysql:database=mantisbt_db;host=192.168.200.211;port=3307","mantistestbot", "apalya01",{'RaiseError' => 1});
    my $sth = $dbh->prepare("select f.bug_id as 'Bug ID', b.name as 'Project',c.name as 'Category',d.username as 'Updated By', FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') as 'Updated Date', a.severity, a.priority,f.new_value,e.description from mantis_bug_table a, mantis_project_table b, mantis_category_table c, mantis_user_table d, mantis_bug_text_table e , mantis_bug_history_table f where f.field_name='status' and f.old_value='80' and f.new_value='90' and f.bug_id=a.id and a.project_id=b.id and a.category_id=c.id and a.id=e.id and f.user_id=d.id and d.username='$mantis_username' and FROM_UNIXTIME(f.date_modified,'%Y-%m-%d') = '$mysql_date' order by f.bug_id ;");
    $sth->execute() || die "$DBI::errstr\n";
    my $row_count = 0;
    while (@resultset = $sth->fetchrow_array)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td class=TableCellText><a href=https://192.168.200.211/view.php?id=$resultset[0]>$resultset[0]</a></td><td class=TableCellText>$resultset[1]</td><td class=TableCellText>$resultset[2]</td><td class=TableCellText>$resultset[3]</td><td class=TableCellText>$resultset[4]</td><td class=TableCellText>$sev_name_id{$resultset[5]}</td><td class=TableCellText>$pri_name_id{$resultset[6]}</td><td class=TableCellText>$status_name_id{$resultset[7]}</td><td class=TableCellText>$resultset[8]</td>";
      $message_body = $message_body .  "</tr>";
     }
    $sth->finish();
  
    if ($row_count==0)
    {
      $message_body = $message_body .  "<tr>";
      $message_body = $message_body .  "<td colspan=9 class=TableCellText>None</td>";
      $message_body = $message_body .  "</tr>";
    }
    ##############################################
  
  
    $dbh->disconnect();
    $message_body = $message_body .  "</table>";

    #$message_body = $message_body . "<div align=left><font face=\"Arial, Helvetica, sans-serif\" size=\"-1\">Thanks,</font></div>";
    #$message_body = $message_body . "<p></p><p></p>";
    #$message_body = $message_body . "<div align=left><font face=\"Arial, Helvetica, sans-serif\" size=\"-1\">$user_first_name</font></div>";

    #$message_body = $message_body . "<table border='0' cellpadding='3'><tr class='TableColumnHeader' width=\"100%\">";
    #$message_body = $message_body . "<tr><td><font face=\"Arial, Helvetica, sans-serif\" size=\"-1\">Thanks,</font></td></tr>";
    #$message_body = $message_body . "<tr><td><font face=\"Arial, Helvetica, sans-serif\" size=\"-1\">$user_first_name</font></td></tr>";
    #$message_body = $message_body . "</table></body></html>";


    #### Sending the mail
    $msg->attach(
         Type     => 'text/html',
         Data     => $message_body
    );

   $msg->send('smtp','smtp.apalya.com', Debug=>1 ); # send via default


    print "<table width=87% border=0 cellpadding=3 width=350px border=1>";
    print "<th class='TableColumnHeader' width=100%></th>";
    print "<tr><td>Daily Status Report of $user_first_name for date $htmldate , sent successfully</td></tr>";
    print "</table>";
    print "</div>";
    &footer();
}


  sub createChartObject()
  {


    my %rev_months = ( "01" , "JAN",
                "02" , "FEB",
                "03",  "MAR",
                "04" , "APR",
                "05" , "MAY",
                "06",  "JUN",
                "07" , "JUL",
                "08" , "AUG",
                "09",  "SEP",
                "10" , "OCT",
                "11" , "NOV",
                "12",  "DEC");

    my $calday = @_[0];
    my $manhrload = @_[1];
    my $caldate = @_[2];
    my $clickuser = @_[3];

    my $Content = "";
    my $rowHTML= "";
    my $chartMaxValue = 8;
    my $chartHeight = 400;
    my $colNum;
    my $barHeight = 10;
    my $XAxisScale = 8 ;

    my @VerY = ();
    my @HorX = ();
    my $j = 0;
    
    if($manhrload >0)
    {
      $progressbarval = $manhrload * 18.90;
      $percentageloaded = ($manhrload/8)*100;
    }
    #else
    #{
    # $manhrload = 0.1;
    # $progressbarval = $manhrload * 18.90;
    # $percentageloaded = ($manhrload/8)*100;
    #}


    if($manhrload <=0)
    {
     $manhrload = 0.1;
     $progressbarval = $manhrload * 18.90;
     $percentageloaded = ($manhrload/8)*100;
     $taskcolor = "white";
    }
    elsif(($manhrload >0) and ($manhrload<=4))
    {
      $taskcolor = "green";
    }
    elsif($manhrload >4 && $manhrload <=7)
    {
      $taskcolor = "orange";
    }
    elsif(($manhrload >7) and ($manhrload <=8))
    {

      $taskcolor = "red";
    }
    else
    {
      $manhrload = 8;
      $progressbarval = $manhrload * 18.90;
      $percentageloaded = ($manhrload/8)*100;
      $taskcolor = "red";
    }



    for($i = 0; $i < 1; $i++)
    {
      $VerY[$j] = $calday;
      $HorX[$j] = $progressbarval;
      $j++;
    }

    # Reset the Column Count to the length of Array WITH VALUES

     $colNum = scalar(@VerY);
     $nSeriesType = 2;

     if ($colNum == 0)
     {
	#	print ("No data found.");
     }
     else
     {
	if ($nSeriesType == 2)
        {
         $Content = "<table id=tblgraph align=center cellpadding=1 cellspacing=0 border=1>";
         # Add the row for X Axis
	 $Content = $Content . "<tr bgcolor=white>";
	 # Add the first blank Cell

         if($caldate=~/(\d+)-(\d+)-(\d+)/)
         {
           $year = $1;
           $month = $rev_months{$2};
           $day = $3;
           $caldate = $day . "-" . $month . "-" . $year;
         }


         $Content = $Content . "<td colspan=9 align=center ><div><font color=blue face=arial size='-2'><a target='iframe_a' href='http://192.168.56.228:80/webapp/display_workload.pl?clickedusername=$clickuser&clickeduserdate=$caldate'>". $caldate ."</a></font></div></td>";
         $Content = $Content . "</tr>";
         $Content = $Content . "<tr bgcolor=white>";
           for ($i = 1; $i <= $XAxisScale; $i++)
           {
              $width1 = calculatewidth($chartMaxValue,$XAxisScale);
              $field1 = calculatefields($i,$chartMaxValue,$XAxisScale);
              $barheight1 = calculatebarheight($barHeight,2);

              $Content = $Content . "<td align=right><div style='background-color:white; width:" . $width1  . "; height:" . $barheight1 . ";'><font face=arial size='-2'>" . $field1 . "hr". "</font></div></td>";
    	   }

           $VerYlength = scalar(@VerY);

           for ($i = 0; $i < $VerYlength; $i++)
           {
              $w = $HorX[i];
              $rowHTML = "";
              $rowHTML = $rowHTML . "<tr style='width:100%'>";
              # Add the abels of Y Axis
              $barheight2 = calculatebarheight($barHeight,2);

              $rowHTML= $rowHTML . "<td name=caldate bgcolor=white align=left width=" . $chartMaxValue . " height=" . $barheight2 . " colspan=" . $XAxisScale . ">";
	      #if ($w>2)
              #{
                $width3 = calculatebarheight($w,1);
              #}

              $rowHTML = $rowHTML ."<div style='background-color:" . $taskcolor . "; width:" . $width3 . ";' />";
              # Display Value for each bar in graph
              $rowHTML = $rowHTML . "<p style='position:relative; left:" . $w . "'><font face=arial size='-2'>&nbsp;";
              # See if Values needs to be displayed on graphs
              #if (document.getElementById("chkvaluepoint").checked == true)
              #	rowHTML+= percentageloaded +"%"
              $rowHTML = $rowHTML . "</font></p>";
              $rowHTML = $rowHTML . "</td></tr>";
              $Content = $Content . $rowHTML;
	    }
            $Content = $Content . "</tr>";
            $Content = $Content . "</table>";
        }
     }
  return($Content);
  }

  sub calculatewidth()
  {
   my $chartMaxValue = @_[0];
   my $XAxisScale = @_[1];

   my $width = ($chartMaxValue/$XAxisScale - 4);
   return($width);

  }

  sub calculatefields()
  {
   my $i = @_[0];
   my $chartMaxValue = @_[1];
   my $XAxisScale = @_[2];

   my $field = ($i * $chartMaxValue / $XAxisScale);
   return($field);

  }

  sub calculatebarheight()
  {
   my $barh = @_[0];
   my $redby = @_[1];
   
   my $newbarh = ($barh - $redby);
   return($newbarh);
  }

  sub getfullname()
  {
   my $name = @_[0];
   my @resultset = ();
   my $name_title = "";
   #print "NAME RECIEVED IS [$name] ";
   my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
   my $sth = $dbh->prepare("SELECT first_name,last_name,title FROM resources WHERE username='$name';");
   $sth->execute() || die "$DBI::errstr\n";
   while (@resultset = $sth->fetchrow_array)
    {
      my $first_name = $resultset[0];
      my $last_name = $resultset[1];
      my $title = $resultset[2];
      $name_title = $first_name . " " . $last_name . " - ". $title;
    }

   $sth->finish();
   $dbh->disconnect();
   #print "NAME RECIEVED IS [$name_title] ";
   return($name_title);
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
#   #print "<div class=xright>";
#   print "<a href=http://192.168.56.228:80/webapp/reshome.pl?action=home><font GlobalLink:active'>Home</font></a>  |  <a href=http://192.168.56.228:80/webapp/login.pl?action=logout><font color='$usercolor'>$myname&nbsp;&nbsp;</font> Logout</a>";
# 
#   print "<table width='100%' align='left' border='1' cellpadding='3'>";
#   print  "<th class='TableColumnHeader' width='100%'><marquee> </font> Welcome Back <font color='brown'>$myname</font></marquee></th>";
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


sub getfullname()
{
  my $name = @_[0];
  my @resultset = ();
  my $full_name = "";
  my $first_name = "";
  my $last_name = "";


  my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
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


sub getmantisusername()
{
 my $name = @_[0];
 my $mantis_username = "";
 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 my $sth = $dbh->prepare("select mantis_username from resources where username='$name'");
 $sth->execute() || die "$DBI::errstr\n";
 while (@resultset = $sth->fetchrow_array)
 {
  $mantis_username =  $resultset[0];
 }
 $sth->finish();
 $dbh->disconnect();
 return($mantis_username);
}

sub getemailid()
{
 my $name = @_[0];
 my $email = "";
 
 my $dbh = DBI->connect("DBI:mysql:database=resdb;host=192.168.56.228","mysqluser", 'mysqluser$',{'RaiseError' => 1});
 my $sth = $dbh->prepare("select emailid from resources where username='$name'");
 $sth->execute() || die "$DBI::errstr\n";
 while (@resultset = $sth->fetchrow_array)
 {
  $email =  $resultset[0];
 }
 $sth->finish();
 $dbh->disconnect();
 return($email);
}


sub calculate_days_between_dates()
{
my $date1 = @_[0];
my $date2 = @_[1];

@date1 = split("-",$date1);
$date1_year = $date1[0];
$date1_mon = $date1[1];
$date1_date = $date1[2];

@date2 = split("-",$date2);
$date2_year = $date2[0];
$date2_mon = $date2[1];
$date2_date = $date2[2];


my $dt1 = DateTime->new(
      year      => $date1_year,
      month     => $date1_mon,
      day       => $date1_date,
      time_zone => 'America/Chicago',
     );

  # not DST

    my $dt2 = DateTime->new(
      year      => $date2_year,
      month     => $date2_mon,
      day       => $date2_date,
      time_zone => 'America/Chicago',
     );

  # is DST

     my $dur = $dt2->subtract_datetime($dt1);

}

