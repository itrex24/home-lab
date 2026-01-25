## Purpose

Build a small, Linux-based system that hosts multiple client applications with clear boundaries and evolves naturally from manual operations to automation and platform engineering.

This project exists to develop deep understanding of:
- Linux infrastructure
- Platform design
- Application lifecycle
- Automation and operations
- Identity, security, and observability

---

## Constraints

- Windows 11 Pro host
- No dual boot
- Hyper-V virtualization
- No public exposure
- No Kubernetes initially
- No GUIs on servers
- SSH only
- Minimal resource usage
- Learn by building and operating, not tutorials

---

## Repository Structure

infra-lab/
├── README.md
├── docs/
├── scripts/
├── apps/
├── diagrams/
└── notes.md


Everything lives in this repository:
- architecture
- scripts
- applications
- decisions
- lessons learned

---

## Phase 0 — Ground Rules

Decisions locked in from day one:

- Virtualization: Hyper-V
- Linux distribution: Ubuntu Server LTS
- Access: SSH keys only
- One Git repository for everything
- Manual first, automate later

No tooling is introduced without a clear reason.

---

## Phase 1 — Minimal Linux Data Centre

### VM Layout (Initial)

#### core-01 — Control + State

Purpose:
- Persistent services
- Trust and control plane

Runs:
- PostgreSQL
- Identity service (token-based)
- Logging and monitoring (later)
- Backups

Specs:
- 2 vCPU
- 4–5 GB RAM
- 40–50 GB disk

---

#### workload-01 — Edge + Applications

Purpose:
- Disposable workloads
- Application runtime

Runs:
- Reverse proxy (Nginx or Caddy)
- Application services
- Containers (later)

Specs:
- 2 vCPU
- 3–4 GB RAM
- 30–40 GB disk

---

## Networking

- Single Hyper-V Internal NAT switch
- Static private IPs

core-01 192.168.100.10
workload-01 192.168.100.20


Rules:
- Host → VMs: SSH only
- workload-01 → core-01: database and auth access
- No inbound internet exposure

---

## Phase 2 — Linux Fundamentals

On both VMs:

- Create non-root admin user
- Disable root SSH login
- Enforce SSH key authentication
- Enable firewall
- Install minimal packages only
- Document every command executed

Focus:
- Users and permissions
- Services and processes
- Networking
- Logs
- Failure recovery

---

## Phase 3 — First Product

Build one intentionally simple backend service:
- Notes API
- Todo API
- Simple CRUD service

Requirements:
- Stateless
- Configuration via environment variables
- Logs to stdout
- Uses a database

Deployment:
- Application runs on workload-01
- Database runs on core-01
- Managed manually using systemd

---

## Phase 4 — Clients

Define what a client is.

A client consists of:
- A database
- Database credentials
- Application configuration
- Routing rule

Manually create:
- Client A
- Client B

The goal is to experience repetition, risk, and operational friction.

---

## Phase 5 — Containers

Containerise the application only.

- One image
- One container per client
- Configuration injected at runtime
- External database remains on core-01

This replaces systemd for application services only.

---

## Phase 6 — Platform Primitive

Implement lifecycle commands:

create-client <name>
delete-client <name>


These commands must:
- Create or remove databases
- Manage credentials
- Start or stop application containers
- Update routing
- Cleanly tear down all resources

Implementation can be Bash or Python.
Correctness matters more than elegance.

---

## Phase 7 — Observability and Backups

Introduce observability when lack of visibility becomes painful.

- Centralised logs
- Basic metrics
- Database backups
- Restore testing (mandatory)

A successful restore is required to consider this phase complete.

---

## Phase 8 — Reflection and Consolidation

- Document architecture decisions
- Draw system diagrams
- Record failures and fixes
- Write scaling considerations
- Identify design limitations

Only after this phase:
- Consider orchestration
- Consider additional VMs
- Consider physical homelab hardware

---

## Outcome

By completing this plan, the system owner will have:

- Strong Linux fluency
- Infrastructure intuition
- Platform engineering mindset
- Real deployment and operations experience
- Clear understanding of why containers and orchestration exist

---

## Final Note

This plan is intentionally constrained and boring.

That constraint is what makes it effective.
