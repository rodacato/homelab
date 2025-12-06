# RustDesk Setup Guide

## Server Info
- **ID Server (HBBS):** `rustdesk-hbbs` (Port 21116)
- **Relay Server (HBBR):** `rustdesk-hbbr` (Port 21117)
- **Key (Public):** Stored in `./volumes/rustdesk/id_ed25519.pub`

## How to Connect (Client)
1.  **Download RustDesk Client** on your devices.
2.  Go to **Settings** > **Network** > **ID/Relay Server**.
3.  **ID Server**: `192.168.68.64`
4.  **Relay Server**: `192.168.68.64:21117`
5.  **Key**: You MUST enter the public key.
    - To get the key, run this command in your server terminal:
      ```bash
      cat volumes/rustdesk/id_ed25519.pub
      ```
    - Copy the output string and paste it into the "Key" field on your client.

## Internet Access
- **Current Status**: Local Only.
- **Future Options**:
    - **Cloudflare WARP**: Install WARP on laptop -> Connect to Tunnel -> Use `rustdesk.notdefined.dev` as Host.
    - **Port Forwarding**: Open ports `21115-21119` on router -> Use Public IP/DDNS.
