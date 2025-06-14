![Architecture Diagram](./111.png)
## 🧩 My Cloud Resume Challenge Implementation

This project is my implementation of the **Cloud Resume Challenge**, a practical, end-to-end cloud project that highlights my ability to design, build, and deploy serverless cloud-native architectures using modern DevOps practices.

The frontend static site — built with **HTML, CSS, and JavaScript** — is hosted separately in this repo: [📁 Front-End](https://github.com/nwafdes/Front-End). The site displays a **live visitor counter** by calling a REST API backed by AWS Lambda and DynamoDB.

The infrastructure is defined and deployed using **Terraform**, and CI/CD is handled through **GitHub Actions**, which uses **OIDC (OpenID Connect)** to securely authenticate and assume roles in AWS — removing the need for static credentials.

---

### 📷 Architecture Overview

![Architecture Diagram](./22.png)

---

### 🧱 Technologies Used

**Frontend (Static Site)**
- 🔤 HTML/CSS for structure and styling
- 🧠 JavaScript to invoke API and reflect visitor count dynamically
- 🪣 S3 for hosting static files
- 🌐 CloudFront for global CDN and caching
- 🔒 Route 53 + ACM for domain, DNS, and SSL
- 🛠 GitHub Actions to deploy frontend + invalidate CloudFront TTL on push

**Backend (Serverless API)**
- 🛡️ WAF to throttle and protect API Gateway
- 🌐 API Gateway as a REST API entry point
- 🐍 AWS Lambda (Python) to handle logic (read/increment count)
- 💾 DynamoDB to store the visitor count
- 🧪 GitHub Actions to:
  - Run unit tests
  - Perform security scans (via **Bandit** and **Grype**)
  - Deploy infrastructure with Terraform upon success
- 🔐 Git + OIDC for secure source control and AWS access

---

### 🌟 What Makes It Stand Out?

- ✔️ Built with Terraform modules and remote state for scalability
- 🔄 CI/CD secured with **OIDC** – no static AWS credentials used
- 🛡️ Emphasis on security with WAF, IAM least privilege, and dependency scanning
- 🚀 Real-world architecture: Used in a deployed portfolio site

> 🔗 Live Site: [https://sahabanet.com](https://sahabanet.com)