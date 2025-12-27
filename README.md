# Apache HTTP Installation Automation (Bash + Ansible)

This repository provides an **interactive Bash wrapper script** and an **Ansible playbook** to install, configure, and validate **Apache HTTP Server** on both **RedHat-based** and **Debian-based** Linux distributions.

The solution is designed for **enterprise environments**, supporting both **sudo** and **dzdo (Delinea/Centrify)** privilege escalation methods.

---

## 📌 Features

- Interactive user selection for Ansible remote login
- Supports **sudo** and **dzdo** become methods
- Works across:
  - RedHat / CentOS / AlmaLinux / Rocky Linux
  - Ubuntu / Debian
- Automatically:
  - Installs Apache (`httpd` / `apache2`)
  - Installs SSL dependencies (`mod_ssl`, `openssl`) on RHEL
  - Generates a self-signed TLS certificate if missing (RHEL)
  - Backs up existing `index.html` with timestamp
  - Deploys a sample `index.html`
  - Validates Apache configuration
  - Enables and starts Apache service
  - Verifies HTTP response on port `80`

---

## 📁 Repository Structure

```text
.
├── install_apache2_http.yml   # Ansible playbook
├── run_apache_install.sh      # Bash wrapper script
├── index.html                 # Sample web page
├── hosts                      # Ansible inventory
└── README.md
````

---

## ⚙️ Prerequisites

* Ansible **2.12+**
* SSH access to target hosts
* One of the following privilege escalation tools on managed nodes:

  * `sudo`
  * `dzdo` (Delinea / Centrify)
* Python installed on target hosts
* Internet or internal repo access for package installation

---

## 🧠 How It Works

### 1️⃣ Bash Wrapper Script

The Bash script:

* Dynamically builds a list of allowed users
* Prompts for:

  * **Remote Ansible user**
  * **Become method** (`sudo` or `dzdo`)
* Passes the selected become method to Ansible using `--extra-vars`

```bash
--extra-vars "play_become_method=sudo"
```

### 2️⃣ Ansible Playbook

The playbook:

* Detects OS family using Ansible facts
* Executes OS-specific installation logic
* Performs validation and service checks
* Confirms Apache is reachable via HTTP

---

## ▶️ Usage

### Step 1: Update Inventory

Edit the `hosts` file:

```ini
[webservers]
server1 ansible_host=192.168.1.10
server2 ansible_host=192.168.1.11
```

---

### Step 2: Run the Bash Script

```bash
chmod +x run_apache_install.sh
./run_apache_install.sh
```

You will be prompted to:

1. Select the **remote Ansible user**
2. Select the **become method** (`sudo` or `dzdo`)
3. Enter SSH and become passwords (if required)

---

## 🖥️ OS Support Matrix

| OS Family                       | Package   | Service Name |
| ------------------------------- | --------- | ------------ |
| RedHat (RHEL/CentOS/Alma/Rocky) | `httpd`   | `httpd`      |
| Debian / Ubuntu                 | `apache2` | `apache2`    |

---

## 🔐 TLS Handling (RedHat Only)

* Checks for:

  * `/etc/pki/tls/certs/localhost.crt`
  * `/etc/pki/tls/private/localhost.key`
* Generates a **self-signed certificate** if:

  * Files are missing, or
  * File size is `0`
* Applies secure permissions:

  * Private key: `0600`
  * Certificate: `0644`

---

## 🧪 Validation & Health Checks

The playbook validates:

* Apache binary presence (`httpd` / `apache2ctl`)
* Configuration syntax:

  * `httpd -t`
  * `apache2ctl -t`
* Service status (enabled & started)
* Port `80` availability
* HTTP response using Ansible `uri` module

Example output:

```text
===== APACHE2 HTTP RESPONSE =====
URL: http://127.0.0.1/
Status: 200
Elapsed: 0.02
```

---

## 📄 Index Page Handling

* Existing `/var/www/html/index.html` is:

  * Backed up with timestamp suffix
* New `index.html` is deployed from the repository

Example backup name:

```text
index.html.bak.2025-12-27-154233
```

---

## ⚠️ Notes & Best Practices

* Ensure the selected Ansible user has:

  * SSH access
  * sudo/dzdo privileges
* For **dzdo environments**, confirm:

  * Proper role mapping
  * No interactive TTY restrictions
* The playbook uses `/tmp` for Ansible remote execution:

  ```yaml
  ansible_remote_tmp: /tmp
  OR
  ansible_remote_tmp: /tmp/.ansible-${USER}
  ```

---

## 🛠️ Troubleshooting

| Issue               | Possible Cause                            |
| ------------------- | ----------------------------------------- |
| Apache not starting | Stale PID file (auto-cleaned by playbook) |
| `which httpd` fails | Package installation failed               |
| HTTP check fails    | Firewall or SELinux restrictions          |
| dzdo errors         | Incorrect Centrify/Delinea policy         |

---

## ✍️ Author

**Sandeep Reddy Bandela**
* Linux • Ansible • Automation • Infrastructure Engineering
