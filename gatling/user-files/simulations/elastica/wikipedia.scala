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
rampUsersPerSec(8) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(15) during(time seconds) randomized,
rampUsersPerSec(15) to(11) during(time seconds) randomized,
rampUsersPerSec(11) to(8) during(time seconds) randomized,
constantUsersPerSec(8) during(time seconds) randomized,
rampUsersPerSec(8) to(10) during(time seconds) randomized,
rampUsersPerSec(10) to(4) during(time seconds) randomized,
rampUsersPerSec(4) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(2) during(time seconds) randomized,
rampUsersPerSec(2) to(4) during(time seconds) randomized,
rampUsersPerSec(4) to(11) during(time seconds) randomized,
rampUsersPerSec(11) to(4) during(time seconds) randomized,
constantUsersPerSec(4) during(time seconds) randomized,
constantUsersPerSec(4) during(time seconds) randomized,
rampUsersPerSec(4) to(6) during(time seconds) randomized,
rampUsersPerSec(6) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(10) during(time seconds) randomized,
constantUsersPerSec(10) during(time seconds) randomized,
rampUsersPerSec(10) to(11) during(time seconds) randomized,
rampUsersPerSec(11) to(18) during(time seconds) randomized,
rampUsersPerSec(18) to(24) during(time seconds) randomized,
rampUsersPerSec(24) to(31) during(time seconds) randomized,
rampUsersPerSec(31) to(44) during(time seconds) randomized,
rampUsersPerSec(44) to(50) during(time seconds) randomized,
rampUsersPerSec(50) to(62) during(time seconds) randomized,
rampUsersPerSec(62) to(67) during(time seconds) randomized,
rampUsersPerSec(67) to(74) during(time seconds) randomized,
rampUsersPerSec(74) to(72) during(time seconds) randomized,
rampUsersPerSec(72) to(83) during(time seconds) randomized,
constantUsersPerSec(83) during(time seconds) randomized,
rampUsersPerSec(83) to(88) during(time seconds) randomized,
rampUsersPerSec(88) to(108) during(time seconds) randomized,
rampUsersPerSec(108) to(100) during(time seconds) randomized,
rampUsersPerSec(100) to(116) during(time seconds) randomized,
rampUsersPerSec(116) to(92) during(time seconds) randomized,
rampUsersPerSec(92) to(108) during(time seconds) randomized,
rampUsersPerSec(108) to(105) during(time seconds) randomized,
rampUsersPerSec(105) to(101) during(time seconds) randomized,
rampUsersPerSec(101) to(94) during(time seconds) randomized,
rampUsersPerSec(94) to(114) during(time seconds) randomized,
rampUsersPerSec(114) to(110) during(time seconds) randomized,
rampUsersPerSec(110) to(98) during(time seconds) randomized,
rampUsersPerSec(98) to(104) during(time seconds) randomized,
rampUsersPerSec(104) to(108) during(time seconds) randomized,
rampUsersPerSec(108) to(136) during(time seconds) randomized,
rampUsersPerSec(136) to(132) during(time seconds) randomized,
rampUsersPerSec(132) to(126) during(time seconds) randomized,
rampUsersPerSec(126) to(124) during(time seconds) randomized,
rampUsersPerSec(124) to(141) during(time seconds) randomized,
rampUsersPerSec(141) to(132) during(time seconds) randomized,
rampUsersPerSec(132) to(144) during(time seconds) randomized,
rampUsersPerSec(144) to(121) during(time seconds) randomized,
rampUsersPerSec(121) to(141) during(time seconds) randomized,
rampUsersPerSec(141) to(128) during(time seconds) randomized,
constantUsersPerSec(128) during(time seconds) randomized,
rampUsersPerSec(128) to(126) during(time seconds) randomized,
rampUsersPerSec(126) to(117) during(time seconds) randomized,
rampUsersPerSec(117) to(123) during(time seconds) randomized,
rampUsersPerSec(123) to(114) during(time seconds) randomized,
rampUsersPerSec(114) to(107) during(time seconds) randomized,
rampUsersPerSec(107) to(98) during(time seconds) randomized,
rampUsersPerSec(98) to(105) during(time seconds) randomized,
rampUsersPerSec(105) to(107) during(time seconds) randomized,
rampUsersPerSec(107) to(113) during(time seconds) randomized,
rampUsersPerSec(113) to(108) during(time seconds) randomized,
rampUsersPerSec(108) to(101) during(time seconds) randomized,
rampUsersPerSec(101) to(98) during(time seconds) randomized,
rampUsersPerSec(98) to(92) during(time seconds) randomized,
rampUsersPerSec(92) to(116) during(time seconds) randomized,
rampUsersPerSec(116) to(113) during(time seconds) randomized,
rampUsersPerSec(113) to(8) during(time seconds) randomized
)
  ).protocols(httpConf).maxDuration(5760 seconds)
}
