# UCSD Bamboo Artifactory Plugin

**Maintained by:** Claudio, Claude and Summer Lombardo — University of California, San Diego

A compatibility fork of the [JFrog Bamboo Artifactory Plugin](https://github.com/JFrogDev/bamboo-artifactory-plugin),
fully updated for **Bamboo Data Center 12.1 (LTS) on Java 21**.

The upstream JFrog plugin was abandoned in 2024 and is incompatible with Bamboo 12.1.
This fork was created to allow UCSD to upgrade from Bamboo 9.6 (EOL August 2026) to
Bamboo 12.1 without requiring any changes to existing plans or task configurations.

---

## Compatibility

| Component | Version |
|-----------|---------|
| Bamboo Data Center | 12.1.x (LTS) |
| Java | 21 (OpenJDK / Temurin) |
| Original upstream | JFrog `3.3.5` |

---

## What works

All original task types are fully functional with no plan reconfiguration required:

- Artifactory Generic Deploy / Resolve
- Artifactory Maven 3
- Artifactory Gradle
- Artifactory Ivy
- Artifactory npm / NuGet / .NET Core / Docker
- Artifactory Publish Build Info / Collect Build Issues / Xray Scan
- Artifactory Deployment Download / Upload
- Release management and promotion

All plugin keys, task keys, and configuration field names are identical to the upstream
plugin. Existing plans continue working after the Bamboo upgrade with no changes.

---

## Installation

1. Download the latest JAR from [Releases](https://github.com/UCSD/bamboo-12.1-LTS-artifactory-plugin/releases)
2. In Bamboo: **Administration → Manage apps → Upload app**
3. Select the JAR and upload
4. The plugin will appear as **UCSD Bamboo Artifactory Plugin** in the app list

---

## Building from source

Requirements: Java 21, Maven 3.8+

```bash
git clone https://github.com/ucsd/bamboo12.1-artifactory-plugin.git
cd bamboo12.1-artifactory-plugin
mvn clean package -DskipTests
# Output: target/bamboo-artifactory-plugin-{version}.jar
```

---

## Version scheme

`{year}.{minor}.{patch}` — e.g. `2026.1.2`

- `year` — release year
- `minor` — new features or significant fixes within the year
- `patch` — bug fixes

See [CHANGELOG.md](CHANGELOG.md) for the full history.

---

## Key changes from upstream

See [CHANGELOG.md](CHANGELOG.md) for the complete list. Summary of what was required
to make the plugin work on Bamboo 12.1 / Java 21:

- Jakarta EE migration (`javax.servlet` → `jakarta.servlet`)
- Struts2 6.x / 7.x compatibility (action delegates, `@StrutsParameter` annotations, namespace declarations)
- FreeMarker security model compatibility (string → boolean attribute values, Map-based wrappers)
- OSGi bundle resolution fixes for Bamboo 12.1's plugin framework
- Task configuration save fix (plan key injection via `ensureTaskPlanKey.ftl`)
- `commons-configuration` dependency removal (`NoClassDefFoundError` fix)

---

## How this fork was built

This fork was developed using an adversarial two-AI approach:
[Claude](https://claude.ai) (Anthropic) and [Codex](https://openai.com) (OpenAI) each
independently worked on different aspects of the migration and cross-reviewed each other's
solutions. Issues that one AI could not solve alone were caught and fixed by the other.
Development was closely guided by Claudio Lombardo, who provided architectural direction,
troubleshooting insights, and production validation.

---

## License

Licensed under the [Apache License 2.0](LICENSE), the same license as the upstream plugin.

Original plugin copyright © JFrog Ltd.
Fork maintained by Claudio, Claude and Summer Lombardo — UCSD.

> This project is not affiliated with or endorsed by JFrog Ltd. or Atlassian.
