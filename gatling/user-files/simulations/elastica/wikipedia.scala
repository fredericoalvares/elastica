package elastica

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class wikipedia extends Simulation {
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
rampUsersPerSec(11) to(14) during(time seconds) randomized,
rampUsersPerSec(14) to(21) during(time seconds) randomized,
rampUsersPerSec(21) to(15) during(time seconds) randomized,
rampUsersPerSec(15) to(11) during(time seconds) randomized,
constantUsersPerSec(11) during(time seconds) randomized,
rampUsersPerSec(11) to(14) during(time seconds) randomized,
rampUsersPerSec(14) to(5) during(time seconds) randomized,
rampUsersPerSec(5) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(2) during(time seconds) randomized,
rampUsersPerSec(2) to(5) during(time seconds) randomized,
rampUsersPerSec(5) to(15) during(time seconds) randomized,
rampUsersPerSec(15) to(5) during(time seconds) randomized,
constantUsersPerSec(5) during(time seconds) randomized,
constantUsersPerSec(5) during(time seconds) randomized,
rampUsersPerSec(5) to(8) during(time seconds) randomized,
rampUsersPerSec(8) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(14) during(time seconds) randomized,
constantUsersPerSec(14) during(time seconds) randomized,
rampUsersPerSec(14) to(15) during(time seconds) randomized,
rampUsersPerSec(15) to(25) during(time seconds) randomized,
rampUsersPerSec(25) to(33) during(time seconds) randomized,
rampUsersPerSec(33) to(43) during(time seconds) randomized,
rampUsersPerSec(43) to(61) during(time seconds) randomized,
rampUsersPerSec(61) to(70) during(time seconds) randomized,
rampUsersPerSec(70) to(86) during(time seconds) randomized,
rampUsersPerSec(86) to(93) during(time seconds) randomized,
rampUsersPerSec(93) to(103) during(time seconds) randomized,
rampUsersPerSec(103) to(100) during(time seconds) randomized,
rampUsersPerSec(100) to(116) during(time seconds) randomized,
constantUsersPerSec(116) during(time seconds) randomized,
rampUsersPerSec(116) to(123) during(time seconds) randomized,
rampUsersPerSec(123) to(151) during(time seconds) randomized,
rampUsersPerSec(151) to(140) during(time seconds) randomized,
rampUsersPerSec(140) to(162) during(time seconds) randomized,
rampUsersPerSec(162) to(128) during(time seconds) randomized,
rampUsersPerSec(128) to(151) during(time seconds) randomized,
rampUsersPerSec(151) to(147) during(time seconds) randomized,
rampUsersPerSec(147) to(141) during(time seconds) randomized,
rampUsersPerSec(141) to(131) during(time seconds) randomized,
rampUsersPerSec(131) to(159) during(time seconds) randomized,
rampUsersPerSec(159) to(154) during(time seconds) randomized,
rampUsersPerSec(154) to(137) during(time seconds) randomized,
rampUsersPerSec(137) to(145) during(time seconds) randomized,
rampUsersPerSec(145) to(151) during(time seconds) randomized,
rampUsersPerSec(151) to(190) during(time seconds) randomized,
rampUsersPerSec(190) to(184) during(time seconds) randomized,
rampUsersPerSec(184) to(176) during(time seconds) randomized,
rampUsersPerSec(176) to(173) during(time seconds) randomized,
rampUsersPerSec(173) to(197) during(time seconds) randomized,
rampUsersPerSec(197) to(184) during(time seconds) randomized,
rampUsersPerSec(184) to(201) during(time seconds) randomized,
rampUsersPerSec(201) to(169) during(time seconds) randomized,
rampUsersPerSec(169) to(197) during(time seconds) randomized,
rampUsersPerSec(197) to(179) during(time seconds) randomized,
rampUsersPerSec(179) to(179) during(time seconds) randomized,
rampUsersPerSec(179) to(176) during(time seconds) randomized,
rampUsersPerSec(176) to(163) during(time seconds) randomized,
rampUsersPerSec(163) to(172) during(time seconds) randomized,
rampUsersPerSec(172) to(159) during(time seconds) randomized,
rampUsersPerSec(159) to(149) during(time seconds) randomized,
rampUsersPerSec(149) to(137) during(time seconds) randomized,
rampUsersPerSec(137) to(147) during(time seconds) randomized,
rampUsersPerSec(147) to(149) during(time seconds) randomized,
rampUsersPerSec(149) to(158) during(time seconds) randomized,
rampUsersPerSec(158) to(151) during(time seconds) randomized,
rampUsersPerSec(151) to(141) during(time seconds) randomized,
rampUsersPerSec(141) to(137) during(time seconds) randomized,
rampUsersPerSec(137) to(128) during(time seconds) randomized,
rampUsersPerSec(128) to(162) during(time seconds) randomized,
rampUsersPerSec(162) to(158) during(time seconds) randomized,
rampUsersPerSec(158) to(11) during(time seconds) randomized
)
  ).protocols(httpConf).maxDuration(5760 seconds)
}
