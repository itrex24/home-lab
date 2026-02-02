# Homelab

This repo contains my personal homelab: a Linux-first infrastructure I use to learn how systems actually behave when you build, deploy, break, and operate them over time.

It's not a demo environment or a showcase, it's a place where I try things, hit limits, redesign parts, and occasionally throw work away.

---

## What I'm trying to learn

I'm using this lab to understand the full path from "idea" to "running system", including:

- How services are planned and structured
- How infrastructure is laid out and configured
- How applications are deployed and operated
- What breaks in practice, not in diagrams
- How monitoring, logging, and security fit in once things exist
- When abstraction actually helps, and when it just hides problems

---

## Scope and focus

The focus is deliberately narrow:

- Linux-based infrastructure
- Backend services and their operation
- Networking, identity, and access
- Automation where it removes real friction
- Operational concerns (failure modes, dependencies, recovery)

Frontend work, data engineering, and “production polish” are secondary unless they become necessary to reason about the system.

---

## How I approach it

A few rules I try to stick to:

- I don’t introduce tools until there’s a clear reason
- I avoid premature abstractions
- I prefer manual setup first so I understand what I’m automating
- I expect to break things and redesign them
- Documentation only appears once something proves it’s sticking around

This means the lab will look messy at times. That’s expected.

---

## Rough structure

The layout changes as the project evolves, but the intent is roughly:
- apps/ # Services and applications
- infra/ # Infrastructure configs and scripts
- vm-definitions/ # VM roles and base assumptions
- scripts/ # Automation and operational helpers
- docs/ # Notes once systems stabilise
- diagrams/ # Architecture diagrams (added sparingly)

---

## Status

Active and unfinished.

Things get rewritten.  
Assumptions change.  
Parts disappear.

That’s part of the point.

---

## Why this exists

I’m building this to get better at infrastructure and platform engineering by doing the work end-to-end, not by copying patterns or collecting tools.

If something here looks simple or manual, it’s probably because I haven’t earned the abstraction yet.
