# Cryptomator Web Browser

A lightweight container that unlocks a Cryptomator vault and provides secure browser-based access to the decrypted files through Filebrowser and an interactive terminal through ttyd.

## What it solves?

Cryptomator on mobile hardware can be painfully slow, especially with huge vaults. The same system has to handle file I/O plus encryption and decryption, which can make browsing sluggish, error-prone, and unreliable. In practice, that can lead to crashes, corruption, or data loss during heavy use. This project moves that work into a container so the vault can be unlocked and shared from a more capable environment.

## How it works?

The container starts Cryptomator CLI, unlocks the vault, mounts the decrypted contents, and launches Filebrowser on the mounted path. 

The Filebrowser web application and ttyd are exposed on ports `8080` and `7681` respectively, so you can access the files from a browser. The container is ephemeral, so the setup is meant to be started fresh from the script each time.

## Requirements

- Docker or Podman.
- A Cryptomator vault (only one vault per container).
- A `.env` file in the project directory.
- Your vault password when the script starts.

## `.env` file

Create a `.env` file next to the script:

```env
CONTAINER_NAME="cryptomator-web-browser"
CONTAINER_IMAGE="cryptomator-web-browser:0.6.2"
VAULT_PATH=/path/to/your/vault
```

### `.env` values
- `VAULT_PATH`: Path to the Cryptomator vault that should be mounted into the container.

## Usage

1. Create the `.env` file with `VAULT_PATH`.
2. Run the script:
   ```bash
   bash unlock.sh
   ```
3. Enter your Cryptomator vault password when prompted.
4. Open Filebrowser in your browser:
   ```text
   http://<device.i.p.address>:8080
   ```
5. The Filebrowser `admin` and ttyd `browser` passwords are generated when the container starts and are displayed on the screen.