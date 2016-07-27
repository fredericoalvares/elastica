package elastica

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class NewSimulation extends Simulation {
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
      .get("/browse.html"))
    .exec(http("ViewItem")
      .get("/ViewItem.php"))
	.exec(http("homepage2")
      .get("/index1.php"))

  setUp(
    scn.inject(
  //    rampUsersPerSec(1) to(100) during(30 seconds),
  //    constantUsersPerSec(100) during(1 minutes),
  //	  rampUsersPerSec(100) to(250) during(2 minutes),
  //     constantUsersPerSec(250) during(1 minutes),
  //	  rampUsersPerSec(250) to(150) during(1 minutes),
  //     constantUsersPerSec(150) during(2 minutes),
  //	  rampUsersPerSec(150) to(500) during(2 minutes),
  //     constantUsersPerSec(500) during(2 minutes),
  //	  rampUsersPerSec(500) to(300) during(30 seconds)

     rampUsersPerSec(1) to(35) during(30 seconds),
      constantUsersPerSec(35) during(150 seconds),
        rampUsersPerSec(35) to(170) during(60 seconds),
        rampUsersPerSec(170) to(220) during(30 seconds),
        constantUsersPerSec(220) during(30 seconds),
       rampUsersPerSec(220) to(350) during(60 seconds),
        rampUsersPerSec(350) to(210) during(60 seconds),
        rampUsersPerSec(210) to(230) during(30 seconds),
        rampUsersPerSec(230) to(180) during(30 seconds),
        rampUsersPerSec(180) to(100) during(60 seconds),
        rampUsersPerSec(100) to(70) during(60 seconds),
        rampUsersPerSec(70) to(35) during(60 seconds),
        rampUsersPerSec(35) to(15) during(30 seconds)
  )
  ).maxDuration(720 seconds).protocols(httpConf)
}

