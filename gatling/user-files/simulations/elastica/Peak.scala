package elastica

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class Peak extends Simulation {
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
            rampUsersPerSec(11) to 201 during(1200 seconds) randomized,
	    constantUsersPerSec(201) during(150 seconds) randomized,
            rampUsersPerSec(201) to 11 during(1200 seconds) randomized
)
  ).protocols(httpConf).maxDuration(2550 seconds)
}

