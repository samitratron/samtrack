#!c:/perl/bin/perl.exe
  use DBI;
  use DBD::mysql;
  use DBI qw(:sql_types);
  use CGI;
  use CGI::Carp qw/fatalsToBrowser warningsToBrowser/;
  use CGI::Session ( '-ip_match' );



  $cgi = new CGI;

  $usr = $cgi->param('usr');
  $pwd = $cgi->param('pwd');

  @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
 @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
 ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
 $year = 1900 + $yearOffset;
 $date = "$weekDays[$dayOfWeek] $months[$month] $dayOfMonth, $year";

  if($usr ne '' and $pwd ne '')
  {
      # process the form

       my $dbh = DBI->connect("DBI:mysql:database=resdb;host=127.0.0.1","mysqluser", 'mysqluser$',{'RaiseError' => 1});
       my $sth = $dbh->prepare("SELECT username FROM resources WHERE username='$usr' AND password=MD5('$pwd')");

       $sth->execute() || die "$DBI::errstr\n";
       $name = $sth->fetchrow();
       $sth->finish();
       $dbh->disconnect();

        #$temp_file = "/home/samitra/public_html/spool";
        #open(FILE,">>$temp_file");
        #print FILE "Name: $name \t Login Date :  $date  ";
        #close(FILE);


       if($name eq $usr)
      {
          #$session = new CGI::Session(undef, $cgi, {Directory=>'/usr/local/apache2/cgi-bin/webapp/session'});
          $session = new CGI::Session();
          $session->expire('+30m');
          $session->save_param($cgi);
          $session->clear(["pwd"]);
          print $session->header(-location=>'reshome.pl?action=home');
          #$session->redirect(-location=>'reshome.pl');
      }
      else
      {
            print $cgi->header;
            print qq~
           <script language=javascript type=text/javascript>
          window.location.href='http://127.0.0.1:80/webapp/login.pl';
          </script>
          ~;


          #print $cgi->header(-type=>"text/html",-location=>"login.pl");
      }
  }
  elsif($cgi->param('action') eq 'logout')
  {
      $session = CGI::Session->load() or die CGI::Session->errstr;
      $session->delete();
      print $session->header(-location=>'login.pl');
  }
  else
  {

      print $cgi->header;
                        print "<html>\n";
			print "<head>\n";
			print "<title>SaMTrack</title>\n";
			#print "<link rel=stylesheet href=http://127.0.0.1/~samitra/css/.css type=text/css>\n";
			print "<link rel='SHORTCUT ICON' href='http://127.0.0.1/webapp/images/favicon.ico'>";
                        print "<link rel=stylesheet href=    type=text/css>\n";
			print "<link rel=stylesheet href=http://127.0.0.1/webapp/css/jsDatePick_ltr.min.css>\n";
                        print "<style type=\"text/css\" media=print></style></head>\n";
			print "<script src=http://127.0.0.1/~samitra/javascript/jsDatePick.min.1.3.js></script>\n";
                        print qq~


                        <div style="background-color:#cfe0f1;" id="header">

                        <div class="logo"><img width="100%" src=http://127.0.0.1/webapp/images/samtrack_header.png></div>

                        <p></p>
                        </div></div>
                        <body bgcolor="#cfe0f1">
                        <div style="background-color:#cfe0f1;">


                        <script type="text/javascript">
                        function formReset()
                        {
                         document.getElementById("login_form").reset();
                        }


                        </script>


                        <form id=login_form >

                        <table border="0" width="400"  align=center height=47 cellspacing="0" cellpadding="1" background="">
		        <tr>
			<td align=left valign=middle colspan=2>
				&nbsp;&nbsp;<img src="http://127.0.0.1/webapp/images/rotating_earth.gif" border=0></img>
			</td>
			<td height=47 align=left>&nbsp;</td>
			<td align=right valign=middle><img src=""></img>&nbsp;</td>
		        </tr>
	                </table>


                        <table bgcolor=#666666 align=center border="1" width="400"  cellspacing="0" cellpadding="5" style="border-width: 0px;border-color: #CCCCCC;">
		<tr>
			<td style="border-style:none; border-width:medium; " height="15">
				<font face="Arial" color="#00BFFF" size="2"><b><i>username </font></b>
			</td>
		</tr>
		<tr>
			<td style="border-style:none; border-width:medium; " height="15">
				<input type="text" style="width: 390px;" name="usr" tabindex="1" style="font-family: Arial; font-size: 9pt;">
			</td>
		</tr>
		<tr>
			<td style="border-style:none; border-width:medium; " height="15">
				<font face="Arial" color="#00BFFF" size="2"><b><i>password </font></b>
			</td>
		</tr>
		<tr>
			<td style="border-style:none; border-width:medium; " height="15">
				<input type="password" style="width: 390px;" name="pwd" tabindex="2" >
			</td>
		</tr>

		<tr>
			<td style="border-style:none; border-width:medium; " align=center colspan="3">
			<input type=submit class='GlobalButtonText' value="Submit" />
			<input type=button class='GlobalButtonText' value="Clear" onclick="formReset()" />
		</tr>
		</table>



                        </form>


                        </div>
                        </body>
                        </head>
                        </html>

          ~;
  }
