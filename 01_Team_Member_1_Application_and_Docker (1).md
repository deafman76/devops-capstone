## 👤 Team Member 1: Presentation Web App, NGINX Proxy Image, and Docker

### 🎯 Your role

You own **the web application — which is now the team's presentation about the week's work** — and the container images that serve it. Your work ends when the presentation app can be built and tested as a Docker image ready for Amazon ECR and AWS Fargate, and when the **NGINX reverse-proxy image** that fronts it is ready.

The web application must **not** run on EC2. EC2 is used only for the Jenkins automation server.

> 🟢 Per the organizer: "ALL, WEB application must be your Presentation about your week work!" So the app is a **presentation SPA**, not a throwaway page.

### 🧭 Final application path
```
Presentation source (SPA)
→ Docker image (app)      ┐
→ Amazon ECR              ├→ Amazon ECS / AWS Fargate (blue + green)
NGINX reverse-proxy image ┘        │
→ Amazon ECR                       ▼
                            NGINX proxy (Fargate) → active color
                                   ▲
                          Application Load Balancer → Public browser
```

### 📦 Files you own
```
app/index.html                 # presentation SPA (all sections)
app/assets/**                  # css, js, images, exported architecture.png
app/sections/**                # optional per-section partials
app/health.html                # returns OK
app/version.json               # build number, git commit, active color
docker/Dockerfile              # app image (NGINX serving static SPA)
docker/nginx-app.conf          # app container server config
proxy/Dockerfile               # NGINX reverse-proxy image
proxy/nginx-proxy.conf.tmpl    # reverse-proxy + upstream (blue/green) template
tests/test-container.sh        # local build+health+version test
docs/application.md            # ECS runtime contract
docs/ai-usage/team-member-1.md # AI-usage log for your work
```

### 📥 What you need from others
**From TM2:** ECR repo URIs (app + proxy); ECS container port; ALB health-check path; how NGINX upstream targets each color (Cloud Map DNS or internal target group).
**From TM4:** image tag format; build variables injected by Jenkins; exact files/paths expected by the pipeline; how the pipeline reloads/switches the proxy upstream.
**From TM3:** the exported **draw.io** architecture PNG to embed in the presentation; the compiled AI-usage content to render.

### 📤 What you give to others
**To TM2:** container port; health path; CPU/memory suggestion; confirmation the images start without EC2-specific assumptions; proxy port (80).
**To TM4:** working app Dockerfile + build context; working proxy Dockerfile + config template; health/version paths; metadata placeholders; how the SPA reads the active color.
**To TM3:** application + proxy descriptions for the docs; your AI-usage entries.

### ✅ Tasks

#### Step 1: Build the presentation SPA
Create `app/index.html` as a single-page presentation of the week's work, with these sections:
1. **Title / team** — project name, four members, week dates.
2. **Objective & constraints** — Docker Hub banned, app not on EC2, app-as-presentation, all bonuses attempted.
3. **Architecture** — embed TM3's exported draw.io PNG + short narration of each flow.
4. **What each member did** — TM1–TM4.
5. **Pipeline walkthrough** — CI/CD stages + blue/green switch.
6. **Bonus challenges** — the coverage table + evidence links.
7. **AI usage** — prompts, **platform**, **model/LLM**, how & why (from `docs/ai-usage/*`).
8. **Evidence** — success run, failed-release run, teardown.
9. **Live status** — reads `/version.json` to show current **build number, Git commit, and active color**.

Use placeholders replaced by Jenkins at build time:
```
__VERSION__   __GIT_COMMIT__   __BUILD_NUMBER__   __COLOR__
```

> Keep it a **static** SPA (HTML/CSS/vanilla JS). No backend runtime — this keeps it Fargate-friendly and EC2-free.

#### Step 2: Health and version endpoints
`app/health.html`:
```
OK
```
`app/version.json`:
```json
{
  "version": "__VERSION__",
  "gitCommit": "__GIT_COMMIT__",
  "buildNumber": "__BUILD_NUMBER__",
  "color": "__COLOR__"
}
```

#### Step 3: Test the static files locally
Start a temporary web server and check `/`, `/health.html`, `/version.json`, and that all presentation sections render (including the AI-usage section placeholder).
**Checkpoint A1 with TM4:** the pipeline can find all required files and placeholders.

#### Step 4: Create the app Dockerfile
`docker/Dockerfile` must:
- use an **NGINX** base image (Amazon Linux 2023-compatible or official NGINX);
- copy the SPA into the correct NGINX directory;
- expose the agreed **container port**;
- include a **container health check** hitting `/health.html`;
- avoid secrets and environment-specific addresses;
- run cleanly in a managed container environment (no EC2 assumptions).

#### Step 5: Create the NGINX reverse-proxy image (BONUS: reverse proxy + blue/green switch)
`proxy/Dockerfile` builds an NGINX image whose config `proxy/nginx-proxy.conf.tmpl` defines:
- a `server` on **port 80** that reverse-proxies to an **`upstream app_backend`**;
- the upstream target is the **active color** (`app-blue` or `app-green`) — resolved via the mechanism TM2 provides (Cloud Map DNS name or internal target);
- pass-through of `/health.html` and `/version.json`;
- sane proxy headers (`X-Forwarded-For`, `Host`), timeouts, and gzip.

> 🟡 The proxy is the single component that satisfies **both** the "NGINX reverse proxy in front of the app" bonus **and** acts as the blue/green traffic switch. TM4 reloads/redeploys it to flip the active color after GREEN passes health.

**Checkpoint A2 with TM4:** TM4 independently builds+tests both images with the same commands planned for Jenkins.

#### Step 6: Build and run locally
Verify for the app image: builds, starts, main presentation loads, `/health.html` returns success, `/version.json` returns valid JSON, container stops cleanly.
Verify for the proxy image: builds, starts, proxies to a local app container, forwards health/version correctly.

#### Step 7: Agree the ECS runtime contract
Write `docs/application.md` with: app Dockerfile path; build context; app container name; container port; **proxy container name + port 80**; health-check path; version path; required build variables; expected image tag format; how the SPA displays the active color.
**Checkpoint A3 with TM2:** ECS task definitions, target group(s), and ALB health check use the same port and path; proxy service front-ends the ALB.

#### Step 8: Create a controlled failed release (for blue/green rollback)
Create a safe test method that makes a **candidate (GREEN) image unhealthy** — e.g., omit `health.html` in a dedicated test branch. Do not damage the main branch.
**Checkpoint A4 with TM4:** Jenkins deploys GREEN, detects it is unhealthy, **never switches the proxy**, and BLUE keeps serving. Clear evidence recorded.

#### Step 9: AI-usage logging (MANDATORY)
Maintain `docs/ai-usage/team-member-1.md`. For every AI interaction record: date/time, **AI platform**, **model/LLM**, the **exact prompt**, what was produced, how you reviewed/changed it, and **why** you used AI. Mark any AI-generated code in your files with the standard block:
```html
<!-- === AI-GENERATED (Generated by AI) ===
     Platform: <e.g., Microsoft Copilot>
     Model/LLM: <e.g., Claude / GPT-4o>
     Reviewed & adapted by: Team Member 1
     === END AI-GENERATED === -->
```
Render the compiled AI-usage content in the app's **AI Usage** section.
**Checkpoint A5 with TM3:** documentation + architecture accurately describe the app + proxy; AI-usage section is complete and correct.

### 🤝 Collaboration summary

| Checkpoint | Collaborator | Result |
|---|---|---|
| A1 | TM4 | Pipeline input paths and placeholders agreed |
| A2 | TM4 | App **and proxy** images build and pass local tests |
| A3 | TM2 | ECS port + ALB health path + proxy front-end match |
| A4 | TM4 | Blue/green failed-release (no-switch) behavior verified |
| A5 | TM3 | Docs + AI-usage section accurate |

### 🏁 Definition of Finished
- The **presentation SPA** is complete and documents the week's work (all 9 sections).
- Health + version endpoints work; `/version.json` exposes build number, commit, **and active color**.
- The **app image** builds from a clean clone and runs locally without EC2 assumptions.
- The **NGINX reverse-proxy image** builds, proxies to the app, and supports the blue/green upstream switch.
- Container port matches the ECS task definition; health path matches the ALB target group.
- Jenkins can insert release metadata (version, commit, build number, color).
- A controlled unhealthy image exists for blue/green rollback testing.
- **AI usage is fully logged** (platform + model + prompts + how/why) and rendered in the app; all AI code blocks are marked.
- Application documentation is reviewed and merged.
