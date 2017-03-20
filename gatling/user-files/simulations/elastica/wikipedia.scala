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
rampUsersPerSec(19) to(25) during(time seconds) randomized,
rampUsersPerSec(25) to(37) during(time seconds) randomized,
rampUsersPerSec(37) to(27) during(time seconds) randomized,
rampUsersPerSec(27) to(19) during(time seconds) randomized,
constantUsersPerSec(19) during(time seconds) randomized,
rampUsersPerSec(19) to(25) during(time seconds) randomized,
rampUsersPerSec(25) to(9) during(time seconds) randomized,
rampUsersPerSec(9) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(3) during(time seconds) randomized,
rampUsersPerSec(3) to(9) during(time seconds) randomized,
rampUsersPerSec(9) to(27) during(time seconds) randomized,
rampUsersPerSec(27) to(9) during(time seconds) randomized,
constantUsersPerSec(9) during(time seconds) randomized,
constantUsersPerSec(9) during(time seconds) randomized,
rampUsersPerSec(9) to(14) during(time seconds) randomized,
rampUsersPerSec(14) to(1) during(time seconds) randomized,
rampUsersPerSec(1) to(25) during(time seconds) randomized,
constantUsersPerSec(25) during(time seconds) randomized,
rampUsersPerSec(25) to(27) during(time seconds) randomized,
rampUsersPerSec(27) to(45) during(time seconds) randomized,
rampUsersPerSec(45) to(59) during(time seconds) randomized,
rampUsersPerSec(59) to(77) during(time seconds) randomized,
rampUsersPerSec(77) to(109) during(time seconds) randomized,
rampUsersPerSec(109) to(126) during(time seconds) randomized,
rampUsersPerSec(126) to(154) during(time seconds) randomized,
rampUsersPerSec(154) to(167) during(time seconds) randomized,
rampUsersPerSec(167) to(185) during(time seconds) randomized,
rampUsersPerSec(185) to(180) during(time seconds) randomized,
rampUsersPerSec(180) to(208) during(time seconds) randomized,
rampUsersPerSec(208) to(208) during(time seconds) randomized,
rampUsersPerSec(208) to(221) during(time seconds) randomized,
rampUsersPerSec(221) to(271) during(time seconds) randomized,
rampUsersPerSec(271) to(252) during(time seconds) randomized,
rampUsersPerSec(252) to(291) during(time seconds) randomized,
rampUsersPerSec(291) to(230) during(time seconds) randomized,
rampUsersPerSec(230) to(271) during(time seconds) randomized,
rampUsersPerSec(271) to(264) during(time seconds) randomized,
rampUsersPerSec(264) to(253) during(time seconds) randomized,
rampUsersPerSec(253) to(235) during(time seconds) randomized,
rampUsersPerSec(235) to(286) during(time seconds) randomized,
rampUsersPerSec(286) to(277) during(time seconds) randomized,
rampUsersPerSec(277) to(246) during(time seconds) randomized,
rampUsersPerSec(246) to(261) during(time seconds) randomized,
rampUsersPerSec(261) to(271) during(time seconds) randomized,
rampUsersPerSec(271) to(342) during(time seconds) randomized,
rampUsersPerSec(342) to(331) during(time seconds) randomized,
rampUsersPerSec(331) to(316) during(time seconds) randomized,
rampUsersPerSec(316) to(311) during(time seconds) randomized,
rampUsersPerSec(311) to(354) during(time seconds) randomized,
rampUsersPerSec(354) to(331) during(time seconds) randomized,
rampUsersPerSec(331) to(361) during(time seconds) randomized,
rampUsersPerSec(361) to(304) during(time seconds) randomized,
rampUsersPerSec(304) to(354) during(time seconds) randomized,
rampUsersPerSec(354) to(322) during(time seconds) randomized,
rampUsersPerSec(322) to(322) during(time seconds) randomized,
rampUsersPerSec(322) to(316) during(time seconds) randomized,
rampUsersPerSec(316) to(293) during(time seconds) randomized,
rampUsersPerSec(293) to(309) during(time seconds) randomized,
rampUsersPerSec(309) to(286) during(time seconds) randomized,
rampUsersPerSec(286) to(268) during(time seconds) randomized,
rampUsersPerSec(268) to(246) during(time seconds) randomized,
rampUsersPerSec(246) to(264) during(time seconds) randomized,
rampUsersPerSec(264) to(268) during(time seconds) randomized,
rampUsersPerSec(268) to(284) during(time seconds) randomized,
rampUsersPerSec(284) to(271) during(time seconds) randomized,
rampUsersPerSec(271) to(253) during(time seconds) randomized,
rampUsersPerSec(253) to(246) during(time seconds) randomized,
rampUsersPerSec(246) to(230) during(time seconds) randomized,
rampUsersPerSec(230) to(291) during(time seconds) randomized,
rampUsersPerSec(291) to(284) during(time seconds) randomized,
rampUsersPerSec(284) to(19) during(time seconds) randomized
)
  ).protocols(httpConf).maxDuration(5760 seconds)
}
