package elastica

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class fifa extends Simulation {
  val lbURL = System.getProperty("lbURL")
  val httpConf = http
    .baseURL(lbURL+"/PHP") // Here is the root for all relative URLs
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") // Here are the common headers
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:16.0) Gecko/20100101 Firefox/16.0")

  val headers_10 = Map("Content-Type" -> "application/x-www-form-urlencoded") // Note the headers specific to a given request

  val scn = scenario("RubisScenario") // A scenario is a chain of requests and pauses
    .exec(http("homepage1")
      .get("/index.html"))
	.exec(http("browseitem")
      .get("/BrowseCategories.php"))
    .exec(http("ViewItem")
      .get("/ViewItem.php"))
	.exec(http("sellerInfo")
      .get("/ViewUserInfo.php"))

 val time=80
 
  setUp(
    scn.inject(
rampUsersPerSec(4) to(6) during(time seconds) randomized,
rampUsersPerSec(6) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(8) during(time seconds) randomized,
rampUsersPerSec(8) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(12) during(time seconds) randomized,
rampUsersPerSec(12) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(14) during(time seconds) randomized,
rampUsersPerSec(14) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(6) during(time seconds) randomized,
constantUsersPerSec(6) during(time seconds) randomized,
rampUsersPerSec(6) to(8) during(time seconds) randomized,
rampUsersPerSec(8) to(27) during(time seconds) randomized,
rampUsersPerSec(27) to(29) during(time seconds) randomized,
rampUsersPerSec(29) to(31) during(time seconds) randomized,
rampUsersPerSec(31) to(168) during(time seconds) randomized,
rampUsersPerSec(168) to(21) during(time seconds) randomized,
rampUsersPerSec(21) to(142) during(time seconds) randomized,
rampUsersPerSec(142) to(46) during(time seconds) randomized,
rampUsersPerSec(46) to(77) during(time seconds) randomized,
rampUsersPerSec(77) to(39) during(time seconds) randomized,
rampUsersPerSec(39) to(31) during(time seconds) randomized,
constantUsersPerSec(31) during(time seconds) randomized,
rampUsersPerSec(31) to(54) during(time seconds) randomized,
rampUsersPerSec(54) to(147) during(time seconds) randomized,
rampUsersPerSec(147) to(58) during(time seconds) randomized,
rampUsersPerSec(58) to(115) during(time seconds) randomized,
rampUsersPerSec(115) to(35) during(time seconds) randomized,
rampUsersPerSec(35) to(94) during(time seconds) randomized,
rampUsersPerSec(94) to(39) during(time seconds) randomized,
rampUsersPerSec(39) to(79) during(time seconds) randomized,
rampUsersPerSec(79) to(29) during(time seconds) randomized,
rampUsersPerSec(29) to(16) during(time seconds) randomized,
rampUsersPerSec(16) to(31) during(time seconds) randomized,
rampUsersPerSec(31) to(48) during(time seconds) randomized,
rampUsersPerSec(48) to(33) during(time seconds) randomized,
rampUsersPerSec(33) to(75) during(time seconds) randomized,
rampUsersPerSec(75) to(111) during(time seconds) randomized,
rampUsersPerSec(111) to(48) during(time seconds) randomized,
rampUsersPerSec(48) to(46) during(time seconds) randomized,
rampUsersPerSec(46) to(189) during(time seconds) randomized,
rampUsersPerSec(189) to(35) during(time seconds) randomized,
rampUsersPerSec(35) to(21) during(time seconds) randomized,
rampUsersPerSec(21) to(42) during(time seconds) randomized,
rampUsersPerSec(42) to(94) during(time seconds) randomized,
rampUsersPerSec(94) to(33) during(time seconds) randomized,
rampUsersPerSec(33) to(94) during(time seconds) randomized,
rampUsersPerSec(94) to(126) during(time seconds) randomized,
rampUsersPerSec(126) to(23) during(time seconds) randomized,
rampUsersPerSec(23) to(27) during(time seconds) randomized,
rampUsersPerSec(27) to(39) during(time seconds) randomized,
rampUsersPerSec(39) to(16) during(time seconds) randomized,
rampUsersPerSec(16) to(168) during(time seconds) randomized,
rampUsersPerSec(168) to(16) during(time seconds) randomized,
rampUsersPerSec(16) to(210) during(time seconds) randomized,
rampUsersPerSec(210) to(16) during(time seconds) randomized,
rampUsersPerSec(16) to(35) during(time seconds) randomized,
rampUsersPerSec(35) to(29) during(time seconds) randomized,
rampUsersPerSec(29) to(23) during(time seconds) randomized,
rampUsersPerSec(23) to(21) during(time seconds) randomized,
rampUsersPerSec(21) to(16) during(time seconds) randomized,
rampUsersPerSec(16) to(165) during(time seconds) randomized,
rampUsersPerSec(165) to(14) during(time seconds) randomized,
rampUsersPerSec(14) to(33) during(time seconds) randomized,
rampUsersPerSec(33) to(178) during(time seconds) randomized,
rampUsersPerSec(178) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(21) during(time seconds) randomized,
rampUsersPerSec(21) to(6) during(time seconds) randomized,
rampUsersPerSec(6) to(2) during(time seconds) randomized,
rampUsersPerSec(2) to(90) during(time seconds) randomized,
rampUsersPerSec(90) to(2) during(time seconds) randomized,
constantUsersPerSec(2) during(time seconds) randomized,
constantUsersPerSec(2) during(time seconds) randomized
	)
  ).protocols(httpConf)
}
