<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <body>
    <?php
    $scriptName = "ViewItem.php";
    include("PHPprinter.php");
    $startTime = getMicroTime();
    $itemId = rand(1, 32000);
    $mode = getMode(); // file_get_contents("/var/tmp/controller-green/mode.txt"); // get the value of mode i.e., in our case 0,1 or 2.
    $a = 1;
    $REC1 = ($mode == $a);
    header("X-Recommendation1 : $REC1");
    $REC2 = ($mode > $a);
   header("X-Recommendation2 : $REC2");


    if (!isset($itemId)) /* Allow ViewItem.php to be included from RandomItem.php */
      $itemId = $_REQUEST['itemId'];
    if ($itemId == null)
    {
      printError($scriptName, $startTime, "Viewing item", "You must provide an item identifier!<br>");
      exit();
    }
     
 
    getDatabaseLink($link);
    begin($link);
    $result = mysql_query("SELECT * FROM items WHERE items.id=$itemId");


	if (!$result)
	{
		error_log("[".__FILE__."] Query 'SELECT * FROM items WHERE items.id=$itemId' failed: " . mysql_error($link));
		die("ERROR: Query failed for item '$itemId': " . mysql_error($link));
	}
    if (mysql_num_rows($result) == 0)
	{ 
      $result = mysql_query("SELECT * FROM old_items WHERE old_items.id=$itemId");

	  if (!$result)
	  {
		error_log("[".__FILE__."] Query 'SELECT * FROM old_items WHERE old_items.id=$itemId' failed: " . mysql_error($link));
		die("ERROR: Query failed: " . mysql_error($link));
	  }
	}
    if (mysql_num_rows($result) == 0)
    {
    //  commit($link);
      die("<h3>ERROR: Sorry, but this item '$itemId' does not exist.</h3><br>\n");
    }

    $row = mysql_fetch_array($result);
    $maxBidResult = mysql_query("SELECT  MAX(bid) AS bid FROM bids WHERE item_id=".$row["id"], $link);
	if (!$maxBidResult)
	{
		error_log("[".__FILE__."] Query 'SELECT MAX(bid) AS bid FROM bids WHERE item_id=".$row["id"]."' failed: " . mysql_error($link));
		die("ERROR: Max bid query failed for item '".$row["id"]."': " . mysql_error($link));
	}
    $maxBidRow = mysql_fetch_array($maxBidResult);
    $maxBid = $maxBidRow["bid"];
    $buyNow = 0;
    if ($maxBid == 0)
    {
      $maxBid = $row["initial_price"];
      $buyNow = $row["buy_now"];
      $firstBid = "none";
      $nbOfBids = 0;
    }
    else
    {
      if ($row["quantity"] > 1)
      {
        $xRes = mysql_query("SELECT bid,qty FROM bids WHERE item_id=".$row["id"]." ORDER BY bid DESC LIMIT ".$row["quantity"], $link);
		if (!$xRes)
		{
			error_log("[".__FILE__."] Query 'SELECT bid,qty FROM bids WHERE item_id=".$row["id"]." ORDER BY bid DESC LIMIT ".$row["quantity"]."' failed: " . mysql_error($link));
			die("ERROR: Quantity query failed for item '".$row["id"]."': " . mysql_error($link));
		}
        $nb = 0;
        while ($xRow = mysql_fetch_array($xRes))
        {
          $nb = $nb + $xRow["qty"];
          if ($nb > $row["quantity"])
          {
            $maxBid = $xRow["bid"];
            break;
          }
        }
      }
      $firstBid = $maxBid;
      $nbOfBidsResult = mysql_query("SELECT COUNT(*) AS bid FROM bids WHERE item_id=".$row["id"], $link);
	  if (!$nbOfBidsResult)
	  {
		error_log("[".__FILE__."] Query 'SELECT COUNT(*) AS bid FROM bids WHERE item_id=".$row["id"]."' failed: " . mysql_error($link));
		die("ERROR: Nb of bids query failed: " . mysql_error($link));
	  }
      $nbOfBidsRow = mysql_fetch_array($nbOfBidsResult);
      $nbOfBids = $nbOfBidsRow["bid"];
      mysql_free_result($nbOfBidsResult);
    }
// Counter file


    printHTMLheader("RUBiS: Viewing ".$row["name"]);
    printHTMLHighlighted($row["name"]);
    print("<TABLE>\n".
          "<TR><TD>Currently<TD><b><BIG>$maxBid</BIG></b>\n");    

    // Check if the reservePrice has been met (if any)
    $reservePrice = $row["reserve_price"];
    if ($reservePrice > 0)
    {
	if ($maxBid >= $reservePrice)
	{
	  print("(The reserve price has been met)\n");
	}
	else
	{
          print("(The reserve price has NOT been met)\n");
	}
    }

    $sellerNameResult = mysql_query("SELECT users.nickname FROM users WHERE id=".$row["seller"], $link);
	if (!$sellerNameResult)
	{
		error_log("[".__FILE__."] Query 'SELECT users.nickname FROM users WHERE id=".$row["seller"]."' failed: " . mysql_error($link));
		die("ERROR: Seller name query failed for user '".$row["seller"]."': " . mysql_error($link));
	}
    $sellerNameRow = mysql_fetch_array($sellerNameResult);
    $sellerName = $sellerNameRow["nickname"];
    mysql_free_result($sellerNameResult);

    print("<TR><TD>Quantity<TD><b><BIG>".$row["quantity"]."</BIG></b>\n");
    print("<TR><TD>First bid<TD><b><BIG>$firstBid</BIG></b>\n");
    print("<TR><TD># of bids<TD><b><BIG>$nbOfBids</BIG></b> (<a href=\"/PHP/ViewBidHistory.php?itemId=".$row["id"]."\">bid history</a>)\n");
    print("<TR><TD>Seller<TD><a href=\"/PHP/ViewUserInfo.php?userId=".$row["seller"]."\">$sellerName</a> (<a href=\"/PHP/PutCommentAuth.php?to=".$row["seller"]."&itemId=".$row["id"]."\">Leave a comment on this user</a>)\n");
    print("<TR><TD>Started<TD>".$row["start_date"]."\n");
    print("<TR><TD>Ends<TD>".$row["end_date"]."\n");
    print("</TABLE>\n");

    // Can the user by this item now ?
    if ($buyNow > 0)
	print("<p><a href=\"/PHP/BuyNowAuth.php?itemId=".$row["id"]."\">".
              "<IMG SRC=\"/PHP/buy_it_now.jpg\" height=22 width=150></a>".
              "  <BIG><b>You can buy this item right now for only \$$buyNow</b></BIG><br><p>\n");

    print("<a href=\"/PHP/PutBidAuth.php?itemId=".$row["id"]."\"><IMG SRC=\"/PHP/bid_now.jpg\" height=22 width=90> on this item</a>\n");

    printHTMLHighlighted("Item description");
    print($row["description"]);
    print("<br><p>\n");



if ($REC1 || $REC2)
{
    
// Recommendation of ICSE paper  

$recommenderItemIdsQuery1 =
        "SELECT ".
          "bids2.item_id AS id, ".
          "COUNT(bids2.item_id) AS popularity ".
        "FROM ".
          "bids ".
          "LEFT JOIN bids AS bids2 ON bids.user_id = bids2.user_id ".
        "WHERE ".
          "bids.item_id = " . $row["id"] . " AND " .
          "bids2.item_id != " . $row["id"] . " " .
        "GROUP BY bids2.item_id ".
        "ORDER BY popularity DESC ".
        "LIMIT 5;" ;
      //echo $recommenderItemIdsQuery; // For debugging
      $recommenderItemIdsResult1 = mysql_query($recommenderItemIdsQuery1, $link);
      $itemIds1 = array();
      array_push($itemIds1, 0); // Make sure at least one item is recommended
      while ($row1 = mysql_fetch_array($recommenderItemIdsResult1))
        array_push($itemIds1, $row1["id"]);
     // mysql_free_result($recommenderItemIdsResult1);

      // Step 2: get all information about the items
      $recommenderQuery1 = "SELECT * FROM items WHERE id IN (" . join(",", $itemIds1) . ")";
      //echo $recommenderQuery; // For debugging
      $recommenderResult1 = mysql_query($recommenderQuery1, $link);

      if (mysql_num_rows($recommenderResult1) != 0)
      {
        
        printHTMLHighlighted("Other items you might like");
        print("<TABLE border=\"1\" summary=\"Other items you might like\">".
              "<THEAD>".
              "<TR><TH>Designation<TH>Price<TH>Bids<TH>End Date<TH>Bid Now".
              "<TBODY>");
   

        while ($row1 = mysql_fetch_array($recommenderResult1))
        {
          $maxBid = $row1["max_bid"];
          if ($maxBid == 0)
            $maxBid = $row1["initial_price"];

          print("<TR><TD><a href=\"/PHP/ViewItem.php?itemId=".$row1["id"]."\">".$row1["name"].
              "<TD>$maxBid".
              "<TD>".$row1["nb_of_bids"].
              "<TD>".$row1["end_date"].
              "<TD><a href=\"/PHP/PutBidAuth.php?itemId=".$row1["id"]."\"><IMG SRC=\"/PHP/bid_now.jpg\" height=22 width=90></a>");
        }
        print("</TABLE>");

       
      }

    //  mysql_free_result($recommenderResult1);   

}

if ($REC2)

{
/*
//Recommendation part from Mine
$recommenderItemIdsQuery =
        "SELECT  ".
          "i1.id , ".
          "i1.nb_of_bids AS popularity ".
        "FROM ".
          "items AS i1 ".
          "JOIN items AS i2 ON i1.category = i2.category ".
          "JOIN bids AS b ON i2.id = b.item_id ".
        "WHERE ".
          "b.item_id = " . $row["id"] . " AND " .
          "i1.id != " . $row["id"] . " " .
        "GROUP BY i1.id ASC ".
        "ORDER BY popularity DESC ".
        "LIMIT 10;" ;
      //echo $recommenderItemIdsQuery; // For debugging
      $recommenderItemIdsResult = mysql_query($recommenderItemIdsQuery, $link);
      $itemIds = array();
      array_push($itemIds, 0); // Make sure at least one item is recommended
     while ( $row2 = mysql_fetch_array($recommenderItemIdsResult))
     array_push($itemIds, $row2["id"]);
  //   mysql_free_result($recommenderItemIdsResult);

      // Step 2: get all information about the items
      $recommenderQuery = "SELECT  * FROM items WHERE id IN (" . join(",", $itemIds) . ")";
      //echo $recommenderQuery; // For debugging
      $recommenderResult = mysql_query($recommenderQuery, $link);
      

      if (mysql_num_rows($recommenderResult) != 0)
      {
        printHTMLHighlighted("Similar products you can consider");
        print("<TABLE border=\"2\" summary=\"Similar products you can consider\">".
              "<THEAD>".
              "<TR><TH>Designation<TH>Price<TH>Bids<TH>End Date<TH>Category<TH>Bid Now".
              "<TBODY>");


        while ($row2 = mysql_fetch_array($recommenderResult))
        {
          $maxBid = $row2["max_bid"];
          if ($maxBid == 0)
            $maxBid = $row2["initial_price"];
           
            

          print("<TR><TD><a href=\"/PHP/ViewItem.php?itemId=".$row2["id"]."\">".$row2["name"].
              "<TD>$maxBid".
              "<TD>".$row2["nb_of_bids"].
              "<TD>".$row2["end_date"].
              "<TD>".$row2["category"].
              "<TD><a href=\"/PHP/PutBidAuth.php?itemId=".$row2["id"]."\"><IMG SRC=\"/PHP/bid_now.jpg\" height=22 width=90></a>");
        }
        print("</TABLE>");
      } 

    //  mysql_free_result($recommenderResult);   
*/
$recommenderItemIdsQuery2 =
        "SELECT ".
          "i1.id ".
        "FROM ".
          "items AS i1 ".
          "JOIN comments AS c ON i1.id = c.item_id ".
          "JOIN items AS i2 ON i1.category = i2.category " .
        "WHERE ".
          "i2.id = " . $row["id"] . " AND " .
          "i1.nb_of_bids >= " . $row["nb_of_bids"] . " AND " .          
          "i1.id != " . $row["id"] . " " .
        "ORDER BY rating DESC ".
        "LIMIT 10;" ;
      //echo $recommenderItemIdsQuery; // For debugging
      $recommenderItemIdsResult2 = mysql_query($recommenderItemIdsQuery2, $link);
      $itemIds2 = array();
      array_push($itemIds2, 0); // Make sure at least one item is recommended
     while ( $row3 = mysql_fetch_array($recommenderItemIdsResult2))
     array_push($itemIds2, $row3["id"]);
 //    mysql_free_result($recommenderItemIdsResult2);

      // Step 2: get all information about the items
      $recommenderQuery2 = "SELECT * FROM items WHERE id IN (" . join(",", $itemIds2) . ")";
      //echo $recommenderQuery; // For debugging
      $recommenderResult2 = mysql_query($recommenderQuery2, $link);
      

      if (mysql_num_rows($recommenderResult2) != 0)
      {
        printHTMLHighlighted("Products from same seller with high customer satisfaction rating");
        print("<TABLE border=\"2\" summary=\"Products from same seller with high customer satisfaction rating\">".
              "<THEAD>".
              "<TR><TH>Designation<TH>Price<TH>Bids<TH>quantity<TH>Seller<TH>Category<TH>Bid Now".
              "<TBODY>");


        while ($row3 = mysql_fetch_array($recommenderResult2))
        {
          $maxBid = $row3["max_bid"];
          if ($maxBid == 0)
            $maxBid = $row3["initial_price"];
           
            

          print("<TR><TD><a href=\"/PHP/ViewItem.php?itemId=".$row3["id"]."\">".$row3["name"].
              "<TD>$maxBid".
              "<TD>".$row3["nb_of_bids"].
              "<TD>".$row3["quantity"].
              "<TD>".$row3["seller"].
              "<TD>".$row3["category"].
              "<TD><a href=\"/PHP/PutBidAuth.php?itemId=".$row3["id"]."\"><IMG SRC=\"/PHP/bid_now.jpg\" height=22 width=90></a>");
        }
        print("</TABLE>");
      }

     mysql_free_result($recommenderResult2); 
   }                                               
  mysql_free_result($maxBidResult);
  mysql_free_result($result);
  mysql_close($link);
    
    printHTMLfooter($scriptName, $startTime);
    ?>  
  </body>
</html>
