package elastica // 1

import io.gatling.core.Predef._ // 2
import io.gatling.http.Predef._
import scala.concurrent.duration._

class IncreasingWorkload extends Simulation { // 3
  val lbURL = System.getProperty("lbURL")
  val httpConf = http // 4
    .baseURL(lbURL) // 5
    .acceptHeader("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8") // 6
    .doNotTrackHeader("1")
    .acceptLanguageHeader("en-US,en;q=0.5")
    .acceptEncodingHeader("gzip, deflate")
    .userAgentHeader("Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0")

  val scn = scenario("IncreasingWorkload") // 7
    .exec(http("request_1")  // 8
    .get("/")) // 9
    .pause(1) // 10

  setUp( // 11
    scn.inject(
     rampUsersPerSec(1) to 340 during(850 seconds) randomized
    ).protocols(httpConf) // 13 
  ) 
}
