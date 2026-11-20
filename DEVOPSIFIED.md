# FAQS

I am answering FAQs (asked by myself) for this project.

## 0. What does it really mean to DEVOPSIFY the project? Where do you even start?

Let's start with the second one – We as a DevOps engineer generally starts after the application development phase has been completed i.e. developers have developed applicaiton and other teams like team has performed testing, performance benchmarking, security checks, etc. Well but all or some of these can be part of Continious Deployment too. Now, it doesn't mean we are going against the DevOps principle by saying "after developers have completed thir work". It just means real work begin there but what DevOps practice says is that even if we are not active developers, we should understand what's going on. This is achieved by using same set of tools for example: we are in same Jira project the developers are working on means we are aware of what features and issues are being developed and fix. Furthermore, we may have been writing scripts that helps developers perform some testing or proof of concept or anything that makes their work faster and automated.

So, now the first question. After development is completed, the application should ultimately made available to end users. To DevOpsify is to develop and implement the process of deliverying the application. The application might be deployed on VM or as containers. According to how the application is meant to deploy, we need to write files or automate process accordingly. But as k8s has become go to these days the real task is generally:
- write production grade `Dockerfile`
- optionally write `docker-compose.yaml`
- wirte k8s manifests and helm charts
- branching strategy (this is actually done before development starts or during development for flexibility)
- designing and writing robost CI/CD pipeline
- creating infra in cloud
- deploying application in standard clusters like EKS/AKS/GKE/OpenShift
- optionally setting up monitoring or observability, etc.

This project is deployed in EKS because I know AWS and not other cloud platforms is explored yet. Sorry!

## 1. What makes `Dockerfile` for **fronend** and **backend** production grade? How do you build the image and where do you push your image?

The `Dockerfile` follows the following principles or practices:
- pinned base image
- non-root user
- multi stage build
- use of distroless image
- efficient use of build cache and `.dockerignore`

The application is meant to be public but not the image itself. The image is pushed into public repository which should not be the case but just for ease of deployment it has been pushed to public repository. In production, you have to push into private repo and use image pull secrets in k8s Deployment manifest.

## 2. Why need `docker-compose.yaml` if the application is meant to be deployed in entreprise level k8s cluster such as EKS (for this project)?

This might not be required but still nice to have it becasue we can test how the application runs easily and more faster than manually launching containers and the real benifit is in reusability with less maintenace and can be shared to other team members without any extra setup (obviously docker and docker compose has to be installed).

## 3. Does your CI/CD pipeline follow DevSecOps principles? Do you think it needs to be improved or you opt not to break what's "already working fine"?

Yes, it does to some extent because I am thinking about secuirty too. Both frontend and backend are subject to SCA and also `Dockerfile` itself is linted and more importantly scanned for vulnerabilities before even building and publishing. While building, sha is tagged using metadata action. Not only Dockerfile but also k8s manifests is scanned and obviously terraform files are scanned too. I won't say this is full safeguard because yet SAST and DAST has to be performed but it is actually good start and yes these improvements are expected but not limited to these only. Currently there are no other branches but `devlop/terraform`, `feature/feat`, `bugfix/bug`, etc. are in my mind. This will eventually improve CI/CD because we can efficiently discuss, approval on pull request and also run different CI on merge than on opened PR which efficient hepls `terraform plan` and `terraform apply`.

Currently terraform is not implemented in CI/CD which is bad practice not to implement becasue only your pipeline should be the one applying changes to infra generally but this requires designing and building secure pipeline as such infra is terraform plan and apply are sensitive and security related things where one bad thing could break infrastructure eventually impacting application "unavailability". This should be implememted carefully with approval gates.


## 4. You choose ArgoCD for deployment. Why can't you just manually deploy your application with only `kubectl apply` or `helm install`?

ArgoCD is dedicated tool for CD which can pick any code changes and deploy automatically instead of doing it manually (this can be automated however). The use of dedicate tool always helps in maintenance and there is more to learn about ArgoCD. While we can deploy with `kubectl apply` or `helm install`. If we don't use ArgoCD we lose benefits like auto healing, auto sync, deploying using k8s manifests themselves, etc. (I only know very very basics of ArgoCD now, will explore more).

## 5. You write three helm charts – each for your application, load balancer and ArgoCD itself. Why three and why not one? Won't it have been much simpler to maintain over the time?

This is intentional. I believe you rarely modify helm for ArgoCD so no real need to maintain that one. Because load balancer is implemented both internal and external, I believe keeping them seperate is more visible and helps maintainence more than not. This is also seperated from application because technically (but not ideally) application doesn't require load balancer to run.

## 6. What skills you were testing deploying this application? Have you used any branching strategy while DEVOPSIFYING the application? Why?

No branching strategy were used which is again bad idea for long running projects. Trunk based deployment works now but this is never way to go if the team is scaling.

I would prefer to say required skills than the term Tested skills - linux, bash, docker, k8s, CI/CD, github actions, etc.

## 7. What issues you faced while deploying the application? What makes you stuck or everthing goes smoothly? Have you felt that anything in your application needs to be improved so that it can be managed more easily and efficiently?

The issues are listed in `temp/issues.md`. One thing I felt is that instead of manually managing database layer (postgres as statefulset), we can use AWS RDS for PostgreSQL.