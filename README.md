# DMUN-Poll for Slack

A polling app for Slack workspaces.

## Docker Usage

### Quick Start with Docker Compose

1. Copy the example environment file and configure it:
   ```bash
   cp .env.example .env
   # Edit .env with your Slack app credentials
   ```

2. Start the services:
   ```bash
   docker-compose up -d
   ```

3. Verify the app is running:
   ```bash
   curl http://localhost:5000/ping
   # Should return: pong
   ```

### Using the Pre-built Image

Pull from GitHub Container Registry:
```bash
docker pull ghcr.io/deutschemodelunitednations/openpollslack:latest
```

Run with environment variables:
```bash
docker run -d \
  -p 5000:5000 \
  -e DMUNPOLL_CLIENT_ID=your-client-id \
  -e DMUNPOLL_CLIENT_SECRET=your-client-secret \
  -e DMUNPOLL_SIGNING_SECRET=your-signing-secret \
  -e DMUNPOLL_STATE_SECRET=your-state-secret \
  -e DMUNPOLL_MONGO_URL=mongodb://your-mongo-host:27017 \
  -e DMUNPOLL_MONGO_DB_NAME=dmun_poll \
  ghcr.io/deutschemodelunitednations/openpollslack:latest
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DMUNPOLL_CLIENT_ID` | Slack OAuth client ID | Yes |
| `DMUNPOLL_CLIENT_SECRET` | Slack OAuth client secret | Yes |
| `DMUNPOLL_SIGNING_SECRET` | Slack request signing secret | Yes |
| `DMUNPOLL_STATE_SECRET` | Secret for OAuth state JWT | Yes |
| `DMUNPOLL_MONGO_URL` | MongoDB connection string | Yes |
| `DMUNPOLL_MONGO_DB_NAME` | MongoDB database name | No (default: `dmun_poll`) |
| `DMUNPOLL_COMMAND` | Slack slash command name | No (default: `poll`) |
| `DMUNPOLL_OAUTH_SUCCESS` | OAuth success redirect URL | No |
| `DMUNPOLL_OAUTH_FAILURE` | OAuth failure redirect URL | No |
| `PORT` | Server port | No (default: `5000`) |

## Command Usage

### Simple poll
```
/poll "What's your favourite color ?" "Red" "Green" "Blue" "Yellow"
```

### Anonymous poll
```
/poll anonymous "What's your favourite color ?" "Red" "Green" "Blue" "Yellow"
```

### Limited choice poll
```
/poll limit 2 "What's your favourite color ?" "Red" "Green" "Blue" "Yellow"
```

### Hidden poll votes
```
/poll hidden "What's your favourite color ?" "Red" "Green" "Blue" "Yellow"
```

### Anonymous limited choice poll
```
/poll anonymous limit 2 "What's your favourite color ?" "Red" "Green" "Blue" "Yellow"
```

For both question and choices, feel free to use slack's emoji, `*bold*` `~strike~` `_italics_` and `` `code` ``

## License

The code is under GNU GPL license. So, you are free to modify the code and redistribute it under same license.

Remember the four freedoms of the GPL:
> * the freedom to use the software for any purpose,
> * the freedom to change the software to suit your needs,
> * the freedom to share the software with your friends and neighbors, and
> * the freedom to share the changes you make.

## Migration from v2 to v3

If upgrading from v2, you need to migrate to MongoDB:

1. Setup your `config/default.json` with:
   - `mongo_url`: MongoDB connection string
   - `mongo_db_name`: MongoDB database name

2. Run the migration script:
   ```bash
   ./scripts/migrate-v3.sh mongodb://localhost:27017 dmun_poll
   ```

## Known Issues

### More than 15 options

If you have more than 15 options, you may encounter an error due to Slack limitations.
