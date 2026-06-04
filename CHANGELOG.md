# Changelog

All notable changes to the UCSD Bamboo Artifactory Plugin are documented here.

**Fork maintained by:** Claudio, Claude and Summer Lombardo

This project is a compatibility fork of the [JFrog Bamboo Artifactory Plugin](https://github.com/JFrogDev/bamboo-artifactory-plugin)
maintained to support **Bamboo Data Center 12.1 (LTS) on Java 21**.
Original plugin copyright JFrog Ltd, licensed under Apache 2.0.

## Version scheme

`{year}.{minor}.{patch}`

- `year` — the calendar year of the release series (e.g. `2026`)
- `minor` — increments for new features or significant fixes within the year
- `patch` — increments for small bug fixes
- Has no relation to the upstream JFrog version numbers
- Official JFrog releases use their own scheme and will never collide

**Examples:**
- `2026.1.0` — first release of the 2026 series
- `2026.1.1` — patch fix
- `2026.2.0` — new feature added in 2026
- `2027.1.0` — first release of the 2027 series

---

## [2026.1.2] - 2026-06-02

### Security

- **Removed `credentialsAccessor` service object from FreeMarker context** —
  `AbstractArtifactoryConfiguration.populateContextForAllOperations()` was placing the live
  Bamboo `CredentialsAccessor` service into the template context alongside the already-safe
  `allCredentialMaps` list. No FTL template referenced it, but its presence unnecessarily
  exposed a live service object to the template engine. Removed as a defense-in-depth measure.

---

## [2026.1.1] - 2026-05-29

### Fixed

- **Task configuration save (HTTP 500 on all plugin tasks)** — Root cause: Bamboo 12.1's
  task create/update action reaches `ReadOnlyConfigurationEditInterceptor` without a usable
  plan key. The interceptor calls `PlanInterceptorUtils.findPlan()` which reads from
  `ActionContext.getParameters()`; because the task edit forms did not include `planKey` /
  `buildKey` / `chainKey` / `jobKey` as POST body fields, the plan lookup returned `null`
  and Bamboo aborted with `IllegalArgumentException: object cannot be null` before
  `generateTaskConfigMap` was ever reached.
  Fix: added `templates/plugins/task/ensureTaskPlanKey.ftl` — a self-contained JavaScript
  snippet that reads the plan key from the rendered FreeMarker context, the form action URL,
  the current page URL, or the HTTP referrer, then injects the missing hidden inputs
  (`buildKey`, `planKey`, `chainKey`, `jobKey`) into the form before submission and strips
  any duplicate values from the action URL to prevent Bamboo collapsing them into a
  comma-separated string. The snippet is included at the bottom of all 14 task configuration
  templates. No Java changes and no form field renames were required.

- **Task configuration validation no longer crashes with `NoClassDefFoundError`** —
  `TaskConfigurationValidations.getConfiguredServerId()` previously called `params.getLong()`
  which internally used `org.apache.commons.configuration.ConversionException`, a class not
  present on the Bamboo 12.1 classpath. Replaced with `Long.parseLong()` catching
  `NumberFormatException`.

- **Removed `[CML]` diagnostic logging** from `AbstractArtifactoryConfiguration.java` —
  temporary stack-trace and lifecycle logs added during root-cause investigation were
  cleaned up; legitimate credentials-loader error handling retained as `log.warn`.

- **Stale plugin artifacts cleaned before each build** — added `maven-antrun-plugin` execution
  in the `initialize` phase to delete old JAR/OBR files from `target/` before packaging,
  preventing accidental upload of a previous build's artifact.

- **Versioning scheme changed** — switched from upstream-prefixed `3.3.5-cml-x.y.z` to
  `year.minor.patch` (e.g. `2026.1.1`). The year-based scheme avoids collision with the
  Atlassian Marketplace's version history for this plugin key, which caused Bamboo to flag
  earlier plain semver versions (e.g. `1.1.0`) as incompatible.

---

## [2026.1.0] - 2026-05-27 / 2026-05-28

Forked from upstream `3.3.5`. All changes are compatibility fixes only —
no functional behavior was added, removed, or altered.

**Validated on Bamboo 12.1.7 (DEV):** plugin install/enable, server
configuration CRUD, Artifactory Generic Deploy, Artifactory Maven 3,
Artifactory Gradle. Existing plan configurations required no changes.

### Changed

- **Bamboo target version** bumped from `9.6.0` to `12.1.7` (`bamboo.version` in `pom.xml`)
- **Java compiler target** bumped from `11` to `21` (`java.version` in `pom.xml`)
- **Servlet API** dependency changed from `javax.servlet:servlet-api:2.5` (removed in Jakarta EE 9)
  to `jakarta.servlet:jakarta.servlet-api:6.0.0` (Jakarta EE 10, used by Bamboo 12.1)
- **`javax.servlet` imports** migrated to `jakarta.servlet` in three files:
  `ArtifactoryConfigServlet.java`, `BuildServlet.java`, `ServerConfigManager.java`
- **`com.opensymphony.xwork2.ActionContext`** import in `ReleasePromotionAction.java` updated to
  `org.apache.struts2.ActionContext` — class relocated in Struts2 6.x (shipped with Bamboo 12.1)
- **`com.atlassian.struts.TextProvider`** (removed in Bamboo 12.1) replaced with
  `com.atlassian.sal.api.message.I18nResolver` in `GitManager.java`; setter name preserved
  to avoid breaking any existing Spring wiring
- **`com.atlassian.bamboo.repository.perforce.PerforceRepository`** (removed in Bamboo 12.1)
  import removed from `PerforceManager.java` — it was only referenced in a Javadoc comment,
  not in any compiled code
- **`atlassian-spring-scanner-annotation` and `-runtime`** changed from `compile`/`runtime` scope
  to `provided` — Bamboo 12.1 ships both as global plugins. Bundling them caused the plugin
  transformer to inject a mandatory `com.opensymphony.module.propertyset;version=1.6.0.atlassian_8`
  import (from their manifests) that Bamboo 12.1 cannot satisfy
- **XWork action package namespaces** made explicit in `atlassian-plugin.xml` — Struts2 6.x
  no longer infers the namespace from the parent package; `namespace="/admin"` added to
  `configureArtifactoryPlugin` and `namespace="/build"` added to `artifactoryReleasePlugin`
  and `brmpResults`
- **Struts2 6.x action method delegates** added to two action classes — the old XWork convention
  of prepending `do` to method names (`method="create"` → `doCreate()`) was dropped in Struts2 6.x;
  Struts2 now calls the method directly. Added thin public delegates in:
  - `ArtifactoryServerConfigAction`: `add()`, `create()`, `edit()`, `update()`, `delete()`
  - `ReleasePromotionAction`: `promote()`, `getLog()`, `releaseBuild()`
- **`@StrutsParameter` annotations** added to all form-bound setter methods — Struts2 7.0+
  (shipped with Bamboo 12.1) defaults `struts.parameters.requireAnnotations=true`; without
  this annotation on each `setXxx()` method, form field values are silently rejected during
  parameter binding, causing validation failures even when the form is correctly filled.
  Annotated setters in `ArtifactoryServerConfigAction` (url, username, password, timeout,
  serverId, mode, sendTest) and `ReleasePromotionAction` (20 setters for release and
  promotion fields)
- **`autofocus=true` removed** from `[@ww.textfield]` call in `artifactoryServerConfig.ftl` —
  Bamboo 12.1's FreeMarker macro wraps the boolean as a `string+extended_hash`, causing
  `freemarker.core.NonBooleanException` when the macro evaluates the parameter in an `#if`
  condition. The attribute is cosmetic only; removing it has no functional effect
- **`required='true'` → `required=true`** (string → boolean) in all 18 FTL template files —
  same `NonBooleanException` in Bamboo's `template/aui/controlheader.ftl` at `#if attributes.required!false`
  when the value is a string wrapper rather than a plain boolean
- **`action.getServerConfigs()` replaced with `serverConfigMaps??`** in `viewExistingArtifactoryServer.ftl` —
  Bamboo 12.1 FreeMarker security (`GenericObjectModel`) blocks explicit method invocations on
  non-Bamboo classes. Replaced with `serverConfigMaps` (a `List<Map<String, Object>>`) returned
  by a new `ExistingArtifactoryServerAction.getServerConfigMaps()` method; FreeMarker map key
  access bypasses the security restriction
- **`[@dj.simpleDialogForm]` removed** from `viewExistingArtifactoryServer.ftl` — the dialog macro's
  `width` and `height` parameters were removed in Bamboo 12.1; without them the delete dialog did
  not function. Delete links now navigate directly to `confirmDeleteServer.ftl` (a standard full-page
  confirmation) which works correctly
- **`toggle='true'/'false'` → `toggle=true/false`** (string → boolean) in all 24 task/deployment
  FreeMarker templates — same `NonBooleanException` pattern as `required`; the `toggle` parameter
  on Bamboo UI macros is checked as a boolean in Bamboo 12.1's AUI templates
- **`serverConfigManager.allServerConfigs` replaced with `allServerConfigMaps`** in all 19 task
  configuration FTL templates — same FreeMarker security block as `ServerConfig.getId()`; exposed
  as `List<Map<String,Object>>` from `AbstractArtifactoryConfiguration.populateContextForAllOperations`
  so FreeMarker map-key access bypasses the `GenericObjectModel` restriction
- **OSGi Import-Package: all mandatory declarations removed** — the previous
  `com.atlassian.*;resolution:=mandatory` declaration caused remote agents to fail enabling the
  bundle because agent OSGi containers only export a subset of Bamboo packages (task-essential
  only; no `com.atlassian.bamboo.ww2.*`, `com.atlassian.sal.api.*`, etc.). Changed to
  `*;resolution:=optional` for everything so the bundle resolves on both server and agents
- **`org.joda.time` removed from Import-Package exclusions** — was preemptively excluded as
  "probably not on agent" but is in fact exported by both the Bamboo server and remote agent
  OSGi containers; required at runtime by `ArtifactoryGenericDeployTask.initTask()`

### Fixed

- **JAXB dependency resolution** — old JAXB pre-release artifacts (`jaxb-api:2.3.0-b161121.1438`,
  `jaxb-runtime:2.2.x-bNNN`, `istack-commons-runtime:3.0.6`, `FastInfoset:1.2.14`) had POMs
  that referenced the defunct `http://maven.java.net/` HTTP repositories, which Maven 3.8.1+ blocks.
  Added `<dependencyManagement>` entries to force modern clean-POM versions:
  `jaxb-api:2.3.1`, `jaxb-runtime:2.3.6`, `istack-commons-runtime:3.0.12`, `FastInfoset:1.2.18`
- **`net.sf.ehcache:ehcache:2.10.9.4.10`** — Atlassian-patched build not published to any public
  Maven repository; excluded from `atlassian-bamboo-web`, `atlassian-bamboo-api`, and
  `atlassian-bamboo-core` (all `provided` scope — Bamboo ships this artifact at runtime)
- **Jakarta JAXB on compiler classpath** — Bamboo 12.1 uses the `jakarta.*` namespace throughout;
  the Hibernate JPA metamodel generator annotation processor references `jakarta.xml.bind.JAXBException`
  at init time. Added `jakarta.xml.bind:jakarta.xml.bind-api:4.0.0` as `provided` scope so the class
  is available during compilation without being bundled
- **OSGi bundle resolution — DmzResolverHook blocked packages** — Bamboo 12.1 marks numerous
  packages as "internal" and refuses to export them to third-party plugins. Added BND
  `Import-Package` exclusions (`!package`) for all packages referenced only from bundled
  transitive dependencies (not from the plugin's own source). Key blocked packages:
  `com.fasterxml.jackson.dataformat.yaml`, `org.glassfish.jersey.innate.*`, `org.objectweb.asm`,
  `org.objectweb.asm.commons`, `com.atlassian.plugins.rest.common.security`, and ~100 additional
  packages from bundled uber-jars (compression codecs, test libraries, JDK-internal packages,
  Jira/Confluence-specific packages, old Spring OSGi, old `javax.*` namespaces)
- **`com.opensymphony.module.propertyset` — Atlassian Platform 7 removal** — Bamboo 10+ removed
  this package from OSGi exports. Bamboo's plugin transformer generates a mandatory import for it
  (version `1.6.0.atlassian_8`) via transitive class analysis through Bamboo action base classes.
  Fixed by: (1) bundling `opensymphony:propertyset:1.3` from Maven Central so the classes are
  locally available, and (2) adding `Export-Package: com.opensymphony.module.propertyset.*;
  version="1.6.0.atlassian_8"` so the OSGi resolver wires the transformer-generated import
  back to our own bundle's export (standard OSGi self-import resolution)
- **`javax.activation`, `javax.xml.bind.*`** excluded from OSGi Import-Package — Bamboo 12.1
  exports `jakarta.activation` and `jakarta.xml.bind` instead; the old `javax.*` namespace
  variants are not available in Bamboo 12.1's OSGi runtime
- **`org.osgi.service.jdbc`** excluded — from bundled H2 database; not exported by Bamboo 12.1
- **`junit.framework`, `org.junit`** excluded — bundled JFrog libraries include test code; not
  exported by Bamboo 12.1
