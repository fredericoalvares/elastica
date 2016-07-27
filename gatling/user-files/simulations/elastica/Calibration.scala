package elastica

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class Calibration extends Simulation {
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
      .get("/index1.php"))
        .exec(http("browseitem")
      .get("/BrowseCategories.php"))
    .exec(http("ViewItem")
      .get("/ViewItem.php"))
        .exec(http("sellerInfo")
      .get("/ViewUserInfo.php"))

  setUp(
    scn.inject(
      rampUsersPerSec(1) to(150) during(3 minutes),
      constantUsersPerSec(150) during(8 minutes),
	  rampUsersPerSec(150) to(1) during(1 minutes)
	)
  ).protocols(httpConf)
}
