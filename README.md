# Bitcoin Core and Lightning Network Daemon (LND) Setup

This repository contains documentation and scripts for setting up a Bitcoin Core node in regtest mode and configuring multiple Lightning Network Daemon (LND) nodes for testing and development purposes.

## Overview

This project demonstrates how to:
- Install and configure Bitcoin Core in regtest mode
- Set up multiple LND nodes
- Create Lightning channels between nodes
- Perform multi-hop payments across the Lightning Network
- Compare Multi-path Payments (MPP) vs Atomic Multi-path Payments (AMP)
- Close Lightning channels

## Prerequisites

- Operating system: Unix-based systems recommended (Ubuntu/Debian used in examples)
- Hardware: Minimum 2GB RAM, 1 GHz quad core, 5GB storage (SSD recommended)
- Bitcoin Core v27.0 or higher
- Go (for LND installation)
- LND v0.13 or higher (for AMP functionality)

## Repository Structure

- `docs/`: Detailed documentation
  - `full-documentation.md`: Complete setup and operation guide
  - `assignment.md`: Original assignment requirements
- `config/`: Configuration files for Bitcoin Core and LND nodes
- `scripts/`: Helper scripts for automating setup and operations
- `images/`: Diagrams and visual aids

## Quick Start

1. Clone this repository:
