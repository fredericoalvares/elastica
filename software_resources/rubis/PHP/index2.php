<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>

<head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   <meta name="GENERATOR" content="Mozilla/4.72 [en] (X11; U; Linux 2.2.14-5.0 i686) [Netscape]">
   <meta name="Author" content="Emmanuel Cecchet">
   <title>RUBiS: Rice University Bidding System</title>
</head>
<body text="#000000" bgcolor="#FFFFFF" link="#0000EE" vlink="#551A8B" alink="#FF0000">
&nbsp;
<center><table COLS=6 WIDTH="100%" NOSAVE >
<tr NOSAVE>
<td NOSAVE>
<center><IMG SRC="/PHP/RUBiS_logo.jpg" height=91 width=150 align=ABSCENTER></center>
</td>

<td>
<center>
<h2>
<a href="/PHP/index.html">Home</a></h2></center>
</td>

<td>
<center>
<h2>
<a href="/PHP/register.html">Register</a></h2></center>
</td>

<td>
<center>
<h2>
<a href="/PHP/browse.html">Browse</a></h2></center>
</td>

<td>
<center>
<h2>
<a href="/PHP/sell.html">Sell</a></h2></center>
</td>

<td>
<center>
<h2>
<a href="/PHP/about_me.html">About me</a></h2></center>
</td>
</tr>
</table></center>

<br>&nbsp;
<center>
<h2>
Welcome to RUBiS's home page !</h2></center>

<p><br>RUBiS is a bidding system prototype that is used to evaluate the
bottlenecks of such application.
<br>This version is the <b><blink>PHP</blink></b> implementation of RUBiS.
<br>&nbsp;
<br>&nbsp;
<h3>
How to use RUBiS</h3>
RUBiS can be used from a web browser for testing purposes or with the provided
benchmarking tools.
<br>Here is how to use RUBiS from your web browser :
<p>1. If you are lost, at any time just click on the <b><i>Home</i></b>
link that brings you back to this page.
<br>2. You first have to register yourself as a new user by selecting
<b><i>Register</i></b>
<br>3. You can browse the items to sell and bid on them by selecting
<b><i>Browse</i></b>.
Note that you can't bid if you are not a registered user.
<br>4. Select <b><i>Sell</i></b> if you want to sell a new item.
<br>5. The <b><i>About me</i></b> link gives you a report of your personal
information and the current items you are selling or bidding on.
<p>Good luck !
<p>
<hr WIDTH="100%">
<br><i>RUBiS (C) 2001 - Rice University/INRIA</i>

<?php
include("PHPprinter.php");
$mode = getMode(); //file_get_contents("/var/tmp/modeFile"); // get the value of mode i.e., in our case 0,1 or 2.
    $a = 2;
    $Extra = ($mode == $a);

if ($Extra) 
 {

getDatabaseLink($link);
//begin($link);
  // mysql query:
  $categoryId = rand(1, 20);
  $query = "SELECT SQL_NO_CACHE id, name, nb_of_bids, initial_price FROM items WHERE category=$categoryId ORDER BY nb_of_bids DESC LIMIT 10";
  $result = mysql_query($query, $link);
  
     
      if (!$result) {
                 echo "Could not execute the query\n";
                 trigger_error(mysql_error(), E_USER_ERROR);
                    } 
           else {
                echo "Top Trending Products\n";
           }

     echo "<Table>";
     
     while ($row = mysql_fetch_assoc($result)) {
              
           /*   echo  $row['id'] . " " . "\n";
              echo  $row['name'] . " " . "\n";
              echo  $row['category'] . " " . "\n";
              echo  $row['initial_price'] . " " . "\n"; */
          
             $id = $row['id'];
	     $name = $row['name'];
	     $bid = $row['nb_of_bids'];
	     $initial_price = $row['initial_price'];
             echo "<tr><td>".$id."<td><td>".$name."<td><td>".$bid."<td><td>".$initial_price."</td></tr>";
               }

              echo "</Table>";

     mysql_close();
}
    
?>
</html>
