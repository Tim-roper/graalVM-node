# Introduction

## What is GraalVM?

GraalVM is a virtual machine with a focus on performance, and polyglot capabilities. Currently JVM and LLVM based languages are supported such as Java/Scala/Kotlin (and any other JVM-targeted language), as well as C and C++. Support exists for Javascript, Python and Ruby as well.

## Why would you bother?

Because I had a 2-day hackathon at work, and we have a NodeJS application I work on that would be interesting to run on a non-NodeJS runtime. Above and beyond the technical challenge, comparing performance is of interest, to understand if it possible to squeeze more performance out of the application.

## Links to tools and projects etc.

* [Artillery](https://artillery.io) for load testing
* [GraalVM](https://www.graalvm.org) website
* [GraalJS](https://github.com/graalvm/graaljs) Javascript/Node Graal Implementation
* [Example GraalVM JDK Polyglot Project](https://github.com/graalvm/graal-js-jdk11-maven-demo) to demonstrate how to build a polyglot JAR.

## Running nodeJS Application on GraalVM

### Approach/Methodology

The approach is to run the BFF on both GraalJS and Vanilla NodeJS runtimes, with other components in the stack setup to facilitate, as much as possible, isolating the BFF as the focus point. A load test is carried out, using the same metrics and supporting componenents, with the BFF running on GraalVM and NodeJS respectively to compare performance.

It is worth noting that the GraalVM can execute Javascript code (Node Runtime) in 2 modes. See [cthe documentation for details](https://github.com/graalvm/graaljs/blob/master/docs/user/JavaInterop.md). The testing includes results for both of these modes.

### Tools & source code used

To carry out the testing, the artillery load test is run against the running BFF instances. The configuration file `test-artillery-config.yml` in the repository is used.

### Test process

#### Caveats

* Running locally
* Not real-world workload
* Not runnning on K8s
* BFF is probably Network bound 
* Some production components not included, such as token exchange

#### Disadvantages of this approach

* To squeeze the most performance out of the GraalVM, a JRE of 11 or greater is required with experimental features such as JIT compilation is required. The GraalVM installation includes the version 8 JRE by default, and will not perform as well. More work is required to configure the graalVM to use the non-included JRE.
* The approach used runs the transpiled BFF code directly on the Graal NodeJS interpreter. To leverage advanced performance the code needs to be compiled into Java bytecode. This can be done by leveraging the `org.graalvm.polyglot` API, or some other way that I didn't stumble upon. This API interface involves importing the Javascript source code to a Java project, and building a JAR or other bytecode package for executing on the JRE. See the link above to an example project for nmore details.
* Leveraging performance configuration of the GraalVM requires some experimental features to be enabled, which are not available without building from source, or using the Oracle distribution. I don't want to use the Oracle distribition, [because Oracle and Larry Ellis](https://news.ycombinator.com/item?id=10040429).

#### Setup

See the [repository](https://github.com/Tim-roper/graalVM-node) here for some helper scripts and test results. The *sme-web-bff* project is included as a submodule, for performance testing purposes. This guide assumes the project is checked out and dependencies have been installed via `yarn install`.

1. install GraalVM, as per instructions on the website. This involves downloading [distribution binary](https://github.com/oracle/graal/releases), and extracting. This appears to be a MacOS Application container, and it includes a JRE to execute on.
2. Build the SME-WEB-BFF project, by running `yarn build` in the root directory.
3. Prepend the GraalVM `/bin` directory to your path. This needs to take precedence over any other NodeJS runtimes (such as nvm or the system node runtime) to run on GraalVM. The path to the GraalVM from it's extracted root is `/Contents/Home/bin`.
4. Start a stub of the Gateway container, which will provide integration for testing purposes. See [The Fakeit repository](https://github.com/JustinFeng/fakeit) for more details. This can be pulled to run a container with `./start-gateway-stub.sh`.
5. Start the SME-WEB-BFF on the GraalVM runtime, the helper script `./start-sme-web-bff-graalvm.sh` can be used for this.
6. Run the load test, via artillery with `yarn run load-test`

## Results

These results are output from the artillery run. Of main interest is the RPS (Requests per Second)

### Local (Not in container)

### Standard NodeJS Runtime

Execute the BFF on the standard NodeJS runtime version v10.16.0.

```
All virtual users finished
Summary report @ 11:51:41(+1000) 2019-09-05
  Scenarios launched:  1200
  Scenarios completed: 1200
  Requests completed:  6000
  RPS sent: 99.27
  Request latency:
    min: 4.4
    max: 1346
    median: 22.6
    p95: 440.8
    p99: 695.4
  Scenario counts:
    0: 1200 (100%)
  Codes:
    200: 6000
```
### GraalVM Runtime - standard options

Execute the BFF on the GraalVM, non-JVM runtime.

```
All virtual users finished
Summary report @ 11:26:01(+1000) 2019-09-05
  Scenarios launched:  1200
  Scenarios completed: 936
  Requests completed:  4741
  RPS sent: 26.29
  Request latency:
    min: 27.1
    max: 93375.8
    median: 18008.9
    p95: 54199.5
    p99: 81021
  Scenario counts:
    0: 1200 (100%)
  Codes:
    200: 4676
    500: 65
  Errors:
    ECONNRESET: 3
    ESOCKETTIMEDOUT: 261
```
### GraalVM Runtime - standard options

Execute the BFF on the GraalVM, JVM runtime with polyglot enabled

```
All virtual users finished
Summary report @ 14:14:55(+1000) 2019-09-05
  Scenarios launched:  1200
  Scenarios completed: 1200
  Requests completed:  6000
  RPS sent: 99.24
  Request latency:
    min: 4.4
    max: 1789.6
    median: 30.5
    p95: 496.4
    p99: 883.5
  Scenario counts:
    0: 1200 (100%)
  Codes:
    200: 6000
```


