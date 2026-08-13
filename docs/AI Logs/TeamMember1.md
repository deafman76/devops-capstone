## AI Prompts Used

I used AI mainly to understand the tasks and to help me when I was unsure about the next step.

Some of the prompts I used were:

- I gave the Team Member 1 instructions to AI and asked it to explain what I needed to do step by step.

- I asked how to test my Docker container using `tests/test-container.sh` and how to check the health and version endpoints.

- When my application was running on port 8081, I asked how I could add the NGINX reverse-proxy bonus without affecting the existing application.

- I asked why the application was using port 8081 while the reverse proxy was using port 8082, and how the two containers communicate with each other.

- I asked AI to explain how to create a separate NGINX reverse-proxy Docker container and configure `proxy_pass`.

- After creating the proxy, I asked how I could test that requests were actually going through the reverse proxy.

- I asked how to verify the NGINX configuration and confirm that `proxy_pass http://capstone-local:8080;` was being used.

- I also asked AI how to document the work I completed and how to explain it to my team.

AI was mainly used for guidance, explanations and troubleshooting. I ran the commands myself on the EC2 instance and checked the results before committing the changes to Git.
