
## docs/05-troubleshooting.md

```md
# Troubleshooting

## App cannot connect to Ollama

Check:

- Phone and server are on the same Wi-Fi/network
- Ubuntu server IP is correct
- Ollama is running
- Port `11434` is accessible
- Firewall is not blocking the port
- CasaOS container exposes the port correctly

## Test from phone browser

Open:

```txt
http://SERVER_IP:11434/api/tags