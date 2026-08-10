> **Region:** Europe (Ireland), AWS region code `eu-west-1`.  
> **Team size:** 5 people.  
> **Shared repository:** `devops-capstone`.  
> **Recommended beginner-friendly design:** two Amazon Linux 2023 EC2 instances, one for Jenkins and one for the application with k3s Kubernetes.  
> **Never commit passwords, tokens, private keys, `.tfstate`, kubeconfig, or Jenkins secrets to Git.

# 👤 Team Member 1: Static Website and Docker Image

## 🎯 Your mission

You own the application source code and the Docker image that every later stage will deploy.  
Keeping the website simple lets the team demonstrate more DevOps automation without spending most of the effort on application development.

## 📦 Files you own

```text
app/index.html
app/health.html
app/version.json
docker/Dockerfile
docker/nginx.conf
tests/test-container.sh
docs/application.md
```

You may edit other files only through agreement with the file owner.

## 🔗 Inputs you need from teammates

- **From Team Member 4:** the image tag format, expected build variables, and Docker Hub repository name.
- **From Team Member 5:** the Kubernetes container port and health-check path.
- **From the whole team:** the project name and visual text shown on the page.

## 📤 Outputs you give to teammates

- **To Team Member 4:** a Dockerfile that builds successfully and a health endpoint that returns success.
- **To Team Member 5:** container port `8080`, health path `/health.html`, and immutable image naming rules.
- **To Team Member 3:** no server installation instructions are required because Team Member 3 installs Docker, not the application manually.

# ✅ Step-by-step tasks

## Step 1: Prepare your branch

```bash
git checkout main
git pull
git checkout -b feature/application-docker
```

**Checkpoint A1:** `git status` shows the new branch and no unexpected local changes.

## Step 2: Create the website

Create `app/index.html`.  
The page should visibly show the release version so the mentor can see a blue/green change in the browser.

Use these placeholders:

```text
__VERSION__
__GIT_COMMIT__
__BUILD_NUMBER__
__DEPLOYMENT_SLOT__
```

Team Member 4 will replace these placeholders during the Jenkins build.

Create `app/health.html`:

```html
OK
```

Create `app/version.json`:

```json
{
  "version": "__VERSION__",
  "gitCommit": "__GIT_COMMIT__",
  "buildNumber": "__BUILD_NUMBER__",
  "deploymentSlot": "__DEPLOYMENT_SLOT__"
}
```

## Step 3: Test the website without Docker

```bash
cd app
python3 -m http.server 8000
```

Open a second terminal:

```bash
curl -f http://localhost:8000/
curl -f http://localhost:8000/health.html
curl -f http://localhost:8000/version.json
```

**Checkpoint A2:** all three commands succeed.  
**Collaboration:** show the page and the three endpoint paths to Team Members 4 and 5 before creating the Dockerfile.

## Step 4: Create the Dockerfile

Use an unprivileged NGINX image and port `8080` for a clearer container-security story.

```dockerfile
FROM nginxinc/nginx-unprivileged:alpine

COPY app/index.html /usr/share/nginx/html/index.html
COPY app/health.html /usr/share/nginx/html/health.html
COPY app/version.json /usr/share/nginx/html/version.json

EXPOSE 8080

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -q -O - http://127.0.0.1:8080/health.html || exit 1
```

## Step 5: Build and run locally

From the repository root:

```bash
docker build -f docker/Dockerfile -t devops-capstone:local .
docker run --rm -d --name capstone-local -p 8080:8080 devops-capstone:local
curl -f http://localhost:8080/
curl -f http://localhost:8080/health.html
curl -f http://localhost:8080/version.json
docker inspect capstone-local --format='{{json .State.Health}}'
docker stop capstone-local
```

**Checkpoint A3:** the container starts, all endpoints respond, and Docker reports a healthy container.  
**Collaboration:** Team Member 4 runs these commands independently before accepting your interface.

## Step 6: Create an intentionally bad release for testing

Add a documented test method that causes the candidate health check to fail without changing the healthy main version.  
A simple method is a test branch where `health.html` is omitted from the image.

**Checkpoint A4:** Team Members 4 and 5 agree how the failed-release demonstration will be triggered and reversed.

## Step 7: Document the contract

Create `docs/application.md` with:

```text
Container port: 8080
Main path: /
Health path: /health.html
Metadata path: /version.json
Image repository: agreed Docker Hub repository
Image tag: BUILD_NUMBER-short_git_sha
Required placeholders: version, commit, build number, slot
```

## Step 8: Open a pull request

```bash
git add app docker tests docs/application.md
git commit -m "feat: add static application and Docker image"
git push -u origin feature/application-docker
```

**Checkpoint A5:** Team Member 4 reviews the Docker build interface and Team Member 5 reviews health and security settings.  
Merge only after both reviewers confirm their parts.

# 🤝 Collaboration map

| Moment | Collaborator | What you agree |
|---|---|---|
| Before coding | Team Member 5 | Port, paths, blue/green labels |
| Before Docker PR | Team Member 4 | Build variables and image tag |
| Before first deployment | Team Member 5 | Probe reaches `/health.html` on port `8080` |
| Before demo | Team Members 4 and 5 | Healthy and deliberately unhealthy releases work |

# 🏁 Your Definition of Finished

- The page works locally.
- The Docker image builds from a clean clone.
- The container runs as a non-root image design.
- `/health.html` returns success.
- `/version.json` contains build placeholders.
- Team Member 4 can build and tag the image in a script.
- Team Member 5 can use the image in Kubernetes probes.
- The PR is reviewed and merged.
