#!/usr/bin/perl -w

use CGI;
#########################################################################
# Change History: Service password-encryption : Paresh - 07102009
# Change History: logging buffered 16384 informational : Crone - 09/12/2011
# Change History: remove access-list 1 permit 10.78.1.0 0.0.0.255 : Crone - 2/26/2013
# Change History: Change TACACS Servers for new ACS : Crone - 8/1/2013
#########################################################################
# Create the CGI object
$query = new CGI;

# Output the HTTP header
print $query->header();

# Process form if submitted; otherwise display it
if ( $query->param("submit") ) {
	process_form();
}
else {
	display_form();
}

sub process_form {
	if ( validate_form() ) {
		&printdata;
	}
}

sub validate_form {
	$DeviceType = $query->param("DeviceType");
	$Country    = $query->param("Country");
	$City       = $query->param("City");
	$Hostname   = $query->param("Hostname");
	$EnablePW   = $query->param("EnablePW");
	$SourceInt  = $query->param("SourceInt");
	$DCLogging  = $query->param("DCLogging");
	$SNMPAnswer = $query->param("SNMPAnswer");
	if ( $SNMPAnswer eq 'Yes' ) {
		$IPSNMP    = $query->param("IPSNMP");
		$Community = $query->param("Community");
	}

	$error_message = "";

	$error_message .= "ERROR!  Please specify the Device Type<br>"
	  if ( !$DeviceType );
	$error_message .= "ERROR!  Please specify the Country<br>" if ( !$Country );
	$error_message .= "ERROR!  Please specify the City<br>"    if ( !$City );
	$error_message .= "ERROR!  Please specify the Hostname<br>"
	  if ( !$Hostname );
	$error_message .= "ERROR!  Please specify the Enable Password<br>"
	  if ( !$EnablePW );
	$error_message .= "ERROR!  Please specify the Source Interface<br>"
	  if ( !$SourceInt );
	$error_message .= "ERROR!  Please specify the Data Center for Logging<br>"
	  if ( !$DCLogging );
	$error_message .=
	  "ERROR!  Please specify if Local IT will monitor the device<br>"
	  if ( !$SNMPAnswer );

	if ( $SNMPAnswer eq 'Yes' ) {
		$error_message .=
		  "Please specify the IP Address of the Local IT Monitoring Device<br>"
		  if ( !$IPSNMP );
		$error_message .=
		  "Please specify the Community String Local IT will use<br>"
		  if ( !$Community );
	}

	if ($error_message) {

		# Errors with the form - redisplay it and return failure
		display_form(
			$error_message, $DeviceType, $Country,   $City,
			$Hostname,      $EnablePW,   $SourceInt, $DCLogging,
			$SNMPAnswer,    $IPSNMP,     $Community
		);
		return 0;
	}
	else {

		# Form OK - return success
		return 1;
	}
}

sub display_form {
	$error_message = shift;
	$DeviceType    = shift;
	$Country       = shift;
	$City          = shift;
	$Hostname      = shift;
	$EnablePW      = shift;
	$SourceInt     = shift;
	$DCLogging     = shift;
	$SNMPAnswer    = shift;
	$IPSNMP        = shift;
	$Community     = shift;

	# Remove any potentially malicious HTML tags
	$Country   =~ s/<([^>]|\n)*>//g;
	$City      =~ s/<([^>]|\n)*>//g;
	$Hostname  =~ s/<([^>]|\n)*>//g;
	$EnablePW  =~ s/<([^>]|\n)*>//g;
	$SourceInt =~ s/<([^>]|\n)*>//g;
	$IPSNMP    =~ s/<([^>]|\n)*>//g;
	$Community =~ s/<([^>]|\n)*>//g;

	# Build "selected" HTML for the "Device Type" radio buttons
	$DeviceType_ap_sel = $DeviceType eq "Access_Point" ? " checked" : "";
	$DeviceType_f_sel  = $DeviceType eq "Firewall"     ? " checked" : "";
	$DeviceType_r_sel  = $DeviceType eq "Router"       ? " checked" : "";
	$DeviceType_s_sel  = $DeviceType eq "Switch"       ? " checked" : "";

	# Build "selected" HTML for the "Data Center Logging" radio buttons
	$DCLogging_d_sel = $DCLogging eq "Denton"    ? " checked" : "";
	$DCLogging_l_sel = $DCLogging eq "Lund"      ? " checked" : "";
	$DCLogging_s_sel = $DCLogging eq "Singapore" ? " checked" : "";

	# Build "selected" HTML for the "Local IT SNMP Monitoring" radio buttons
	$SNMPAnswer_y_sel = $SNMPAnswer eq "Yes" ? " checked" : "";
	$SNMPAnswer_n_sel = $SNMPAnswer eq "No"  ? " checked" : "";

	# Display the form
	print <<END_HTML;
  <html>
   <head><title>Network Security Baseline</title></head>
  <body>
  &nbsp;<table border="0" width="100%" id="table1">
	<tr>
		<td width="121">
		<img border="0" src="Motto.jpg" width="106" height="101"></td>
		<td><i><b><font color="#000099" face="Arial" size="5">Network Security 
		Baseline Configuration Tool</font></b></i></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
   </table>
  
  <form action="security_baseline.pl" method="post">
  <input type="hidden" name="submit" value="Submit">

  <p>$error_message</p>

 
  <p>Device Type:<br>
  <input type="radio" name="DeviceType" value="Access_Point"$DeviceType_ap_sel>Access Point
  <input type="radio" name="DeviceType" value="Firewall"$DeviceType_f_sel>Firewall
  <input type="radio" name="DeviceType" value="Router"$DeviceType_r_sel>Router
  <input type="radio" name="DeviceType" value="Switch"$DeviceType_s_sel>Switch
  </p>
  
  <p>Country:<br>
  <input type="text" name="Country" value="$Country">
  </p>

  <p>City:<br>
  <input type="text" name="City" value="$City">
  </p>
    
  <p>Hostname:<br>
  <input type="text" name="Hostname" value="$Hostname">
  </p>

  <p>Enable Secret Password:<br>
  <input type="text" name="EnablePW" value="$EnablePW">
  </p>    
    
  <p>Source Interface for Logging and TACACS+:<br>
  <input type="text" name="SourceInt" value="$SourceInt">
  </p>        
        
  <p>Regional Data Center for Logging:<br>
  <input type="radio" name="DCLogging" value="Denton"$DCLogging_d_sel>Denton
  <input type="radio" name="DCLogging" value="Lund"$DCLogging_l_sel>Lund
  <input type="radio" name="DCLogging" value="Singapore"$DCLogging_s_sel>Singapore
  </p>
  
  <p>Will Local IT Monitor the Device using a Local SNMP Monitoring Solution?<br>
  <input type="radio" name="SNMPAnswer" value="Yes"$SNMPAnswer_y_sel><font color="#FF0000">Yes</font>
  <input type="radio" name="SNMPAnswer" value="No"$SNMPAnswer_n_sel>No
  </p>
  
  <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;If the answer above was <font color="#FF0000">Yes</font>, please fill out fields below:<br>
  
  <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#FF0000">IP Address of Local IT Monitoring Solution:</font><br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="IPSNMP" value="$IPSNMP">
  </p> 
    
  <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font color="#FF0000">SNMP Community String used by Local IT Monitoring Solution:</font><br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="text" name="Community" value="$Community">
  </p> 
 
  <input type="submit" name="submit" value="Submit">

  </form>
  
  </body></html>
END_HTML

  #*****************************************************************************
  #*****************************************************************************
  #Begin of Output Subroutines for
  #Subroutine to print Network Security Baseline
	sub printdata {
		$output = $output
		  . "Your Security Baseline configuration is displayed below:\n";
		$output = $output . "\n";    #line break}
		&prthost;
		&prtenablepw;
		&prthttp;
		&prtlogging;
		&prtSNMP;
		&prtauthentication;
		&prtaccounting;
		&prtauthorization;
		&prtoutput;
	}

	#Subroutine to print Hostname & Domain Name
	sub prthost {
		$output = $output . "Service password-encryption\n";
		$output = $output . "hostname $Hostname\n";
		$output = $output . "ip domain-name nvv.net.tetrapak.com\n";
		$output = $output . "service timestamps log datetime localtime\n";
		$output = $output . "\n";    #line break
	}

	#Subroutine to print Hostname & Domain Name
	sub prtenablepw {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "enable password $EnablePW\n";
			$output = $output . "clear passwd\n";
			$output = $output . "\n";                            #line break
		}
		else {
			$output = $output . "enable secret $EnablePW\n";
			$output = $output . "no enable password\n";
			$output = $output . "\n";                            #line break
		}
	}

	#Subroutine to print HTTP settngs
	sub prthttp {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "no http server enable\n";
			$output = $output . "\n";                            #line break
		}
		else {
			$output = $output . "no ip http server\n";
			$output = $output . "\n";                            #line break
		}
	}

	#Subroutine to print Logging settngs
	sub prtlogging {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "logging on\n";
			$output = $output . "logging timestamp\n";
			$output = $output . "trap informational\n";
			$output = $output . "logging facility 4\n";
			if ( $DCLogging eq 'Denton' ) {
				$output = $output . "logging host inside 10.192.4.80\n";
				$output = $output . "logging host inside 10.192.4.81\n";
				$output = $output . "logging host inside 10.192.4.82\n";
				$output = $output . "ntp server 10.192.4.210 prefer\n";
				$output = $output . "ntp server 10.138.1.12\n";
				$output = $output . "ntp server 10.67.1.250\n";
				$output = $output . "\n";    #line break
			}
			elsif ( $DCLogging eq 'Lund' ) {
				$output = $output . "logging host inside 10.67.1.40\n";
				$output = $output . "logging host inside 10.67.1.111\n";
				$output = $output . "logging host inside 10.67.1.112\n";
				$output = $output . "ntp server 10.67.1.250 prefer\n";
				$output = $output . "ntp server 10.138.1.12\n";
				$output = $output . "ntp server 10.192.4.210\n";
				$output = $output . "\n";    #line break
			}
			else {
				$output = $output . "logging host inside 10.138.1.60\n";
				$output = $output . "logging host inside 10.138.1.63\n";
				$output = $output . "logging host inside 10.138.1.64\n";
				$output = $output . "ntp server 10.138.1.12 prefer\n";
				$output = $output . "ntp server 10.192.4.210\n";
				$output = $output . "ntp server 10.67.1.250\n";
				$output = $output . "\n";
			}    #line break
		}
		else {
			$output = $output . "logging on\n";
			$output = $output . "logging trap notifications\n";
			$output = $output . "logging source-interface $SourceInt\n";
			$output = $output . "service timestamps log datetime\n";
			$output = $output . "logging buffered 16384 informational\n";
			if ( $DeviceType eq 'Router' ) {
				$output = $output . "logging facility local7\n";
			}
			else {
				$output = $output . "logging facility local6\n";
			}
			if ( $DCLogging eq 'Denton' ) {
				$output = $output . "logging 10.192.4.81\n";
				$output = $output . "logging 10.192.4.82\n";
				$output = $output . "ntp server 10.192.4.210 prefer\n";
				$output = $output . "ntp server 10.138.1.12\n";
				$output = $output . "ntp server 10.67.1.250\n";
				$output = $output . "\n";    #line break
			}
			elsif ( $DCLogging eq 'Lund' ) {
				$output = $output . "logging 10.67.1.111\n";
				$output = $output . "logging 10.67.1.112\n";
				$output = $output . "ntp server 10.67.1.250 prefer\n";
				$output = $output . "ntp server 10.138.1.12\n";
				$output = $output . "ntp server 10.192.4.210\n";
				$output = $output . "\n";    #line break
			}
			else {
				$output = $output . "logging 10.138.1.63\n";
				$output = $output . "logging 10.138.1.64\n";
				$output = $output . "ntp server 10.138.1.12 prefer\n";
				$output = $output . "ntp server 10.192.4.210\n";
				$output = $output . "ntp server 10.67.1.250\n";
				$output = $output . "\n";    #line break
			}
		}
	}

	#Subroutine to print SNMP settngs
	sub prtSNMP {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "snmp-server community H3lo0fcer\n";
			$output = $output . "snmp-server host inside 10.67.1.22 poll\n";
			$output = $output . "snmp-server host inside 10.192.4.5 poll\n";
			if ( $SNMPAnswer eq 'Yes' ) {
				$output = $output . "snmp-server host inside $IPSNMP\n";
			}
		}
		else {
			$output = $output . "access-list 1 permit 10.138.1.0 0.0.0.255\n";
			$output = $output . "access-list 1 permit 10.67.1.0 0.0.0.255\n";
			$output = $output . "access-list 1 permit 10.67.4.0 0.0.0.255\n";
			$output = $output . "access-list 1 permit 10.192.4.0 0.0.0.255\n";
			$output = $output . "access-list 2 permit 10.67.1.22\n";
			$output = $output . "access-list 2 permit 10.67.4.114\n";
			$output = $output . "access-list 2 permit 10.67.4.115\n";
			$output = $output . "access-list 2 permit 10.67.4.105\n";
			$output = $output . "snmp ifmib ifalias long\n";
			$output = $output . "snmp-server community Ixlr8byU RO 1\n";
			$output = $output . "snmp-server community H3lo0fcer  RW 2\n";
			$output = $output . "snmp-server location $City, $Country\n";

			if ( $SNMPAnswer eq 'Yes' ) {
				$output = $output . "access-list 3 permit $IPSNMP\n";
				$output = $output . "snmp-server community $Community RO 3\n";
			}
		}
	}

	#Subroutine to print AAA authentication settngs
	sub prtauthentication {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "\n";    #line break
			$output = $output . "aaa-server TACACS+ protocol tacacs+\n";
			$output = $output . "aaa-server TACACS+ max-failed-attempts 3\n";
			$output = $output . "aaa-server TACACS+ deadtime 10\n";
			if ( $DCLogging eq 'Denton' ) {
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.192.8.121 6A4taXunaTre9aTRafuz timeout 50\n";
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.67.4.105 6A4taXunaTre9aTRafuz timeout 50\n";
			}
			elsif ( $DCLogging eq 'Lund' ) {
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.67.4.105 6A4taXunaTre9aTRafuz timeout 50\n";
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.192.8.121 6A4taXunaTre9aTRafuz timeout 50\n";
			}
			else {
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.138.1.66 6A4taXunaTre9aTRafuz timeout 50\n";
				$output = $output
				  . "aaa-server TACACS+ (inside) host 10.67.4.105 6A4taXunaTre9aTRafuz timeout 50\n";
			}
			$output = $output . "aaa authentication ssh console TACACS+\n";
			$output = $output . "aaa authentication serial console TACACS+\n";
		}
		else {
			$output = $output . "\n";                #line break
			$output = $output . "aaa new-model\n";
			$output =
			  $output . "aaa authentication login ADMIN group tacacs+ enable\n";
			$output = $output . "ip tacacs  source-interface $SourceInt\n";
			if ( $DCLogging eq 'Denton' ) {
				$output = $output . "tacacs-server host 10.192.8.121\n";
				$output = $output . "tacacs-server host 10.67.4.105\n";
				$output = $output . "tacacs-server host 10.138.1.66\n";
			}
			elsif ( $DCLogging eq 'Lund' ) {
				$output = $output . "tacacs-server host 10.67.4.105\n";
				$output = $output . "tacacs-server host 10.192.8.121\n";
				$output = $output . "tacacs-server host 10.138.1.66\n";
			}
			else {
				$output = $output . "tacacs-server host 10.138.1.66\n";
				$output = $output . "tacacs-server host 10.67.4.105\n";
				$output = $output . "tacacs-server host 10.192.8.121\n";
			}
			$output = $output . "no tacacs-server directed-request\n";
			$output = $output . "tacacs-server key 6A4taXunaTre9aTRafuz\n";
			$output = $output . "line con 0\n";
			$output = $output . "login authentication ADMIN\n";
			$output = $output . "no password\n";
			$output = $output . "line vty 0 4\n";
			$output = $output . "login authentication ADMIN\n";
			$output = $output . "no password\n";
			$output = $output . "exec-timeout 30 0\n";
			$output = $output . "line vty 5 15\n";
			$output = $output . "login authentication ADMIN\n";
			$output = $output . "no password\n";
			$output = $output . "exec-timeout 30 0\n";

			if ( $DeviceType eq 'Router' ) {
				$output = $output . "line aux 0\n";
				$output = $output . "login authentication ADMIN\n";
				$output = $output . "no password\n";
			}
			elsif ( $DeviceType eq 'Access Point' ) {
				$output = $output . "\n";    #line break
				$output = $output
				  . "radius-server authorization permit missing Service-Type\n";
				$output = $output . "ip radius source-interface $SourceInt\n";
			}
		}
	}

	#Subroutine to print AAA Accounting settngs
	sub prtaccounting {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "aaa accounting ssh console TACACS+\n";
		}
		else {
			$output = $output . "\n";    #line break
			$output = $output . "aaa accounting exec default start-stop tacacs+\n";
			$output = $output . "aaa accounting commands 15 default start-stop tacacs+\n";
		}
	}

	#Subroutine to print AAA Authorization settngs
	sub prtauthorization {
		if ( $DeviceType eq 'Firewall' ) {
			$output = $output . "\n";    #line break
		}
		else {
			$output = $output . "\n";    #line break
			$output = $output . "no aaa authorization exec default local\n";
			$output = $output . "aaa authorization exec default group tacacs+ none\n";
			$output = $output . "aaa authorization commands 15 default group tacacs+ none\n";
			$output = $output . "aaa authorization config-commands\n";
		}
	}

	#Subroutine to The End
	sub prtoutput {
		$output  = $output . "\n";       #line break
		$output  = $output . "\n";
		$htmlout = $output;
		$htmlout =~ s/\n/<br>/g;
		print "$htmlout";
	}
}
