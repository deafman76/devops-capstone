# Team Member 1 - Application and Docker Work

I worked on the application Docker container and the NGINX reverse proxy.

## 1. Application Docker

The application is running inside a Docker container called:

capstone-local

The application listens on port 8080 inside the container.

The EC2 server exposes the application on port 8081.

## 2. Application Testing

I tested the application health endpoint using:

curl http://localhost:8081/health.html

Result:

OK

I also checked the container using:

docker ps

The capstone-local container was running and healthy.

## 3. NGINX Reverse Proxy

I created a separate NGINX reverse-proxy container called:

capstone-reverse-proxy

The reverse proxy listens on port 8080 inside the container.

The EC2 server exposes the reverse proxy on port 8082.

## 4. Reverse Proxy Configuration

I created these files:

docker/reverse-proxy/Dockerfile
docker/reverse-proxy/nginx.conf

The NGINX configuration uses:

proxy_pass http://capstone-local:8080;

This forwards requests from the reverse proxy to the application container.

## 5. Reverse Proxy Testing

I tested the application directly using:

curl http://localhost:8081/health.html

Result:

OK

I then tested the same endpoint through the reverse proxy:

curl http://localhost:8082/health.html

Result:

OK

This confirmed that the NGINX reverse proxy is forwarding requests successfully.

## 6. NGINX Verification

I checked the active NGINX configuration using:

docker exec capstone-reverse-proxy nginx -T | grep proxy_pass

The output showed:

proxy_pass http://capstone-local:8080;

NGINX also confirmed that the configuration syntax was valid.

## 7. Container Status

Both containers were running and healthy.

Application:

capstone-local
Port 8081 -> 8080

Reverse proxy:

capstone-reverse-proxy
Port 8082 -> 8080

The request flow is:

Browser -> Port 8082 -> NGINX Reverse Proxy -> capstone-local -> Application

## 8. Git

I added:

docker/reverse-proxy/Dockerfile
docker/reverse-proxy/nginx.conf

I committed the reverse-proxy work with:

feat: add nginx reverse proxy

I pushed the reverse-proxy changes to:

feature/application-docker

I also added my AI usage notes in:

docs/AI Logs/TeamMember1.md

The AI log was committed and pushed to the main branch.

## 9. Jenkins Deployment

The application is also deployed through our Jenkins CI/CD pipeline.

Jenkins is running on port 8080.

The Jenkins deployment is part of the team's overall CI/CD process.

## 10. Final Status

My application Docker work is completed.

The NGINX reverse proxy has been implemented and tested successfully.

The application container and reverse-proxy container are both running and healthy.
