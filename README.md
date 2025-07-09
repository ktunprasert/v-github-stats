# GitHub Language Statistics Server

A simple V web server that generates SVG language statistics from GitHub repositories.

![ktunprasert-35-10 2025-07-08](https://github.com/user-attachments/assets/ab4ae120-6682-4792-8871-57a0ade711ed)

Currently, it's aimed for dark mode, tranlucent gradient background.

## Features

- Generates SVG visualizations of programming language usage
- Caches results for 24 hours in `public/` directory
- Configurable number of repositories and languages to analyze
- Built with [V](https://vlang.io) and the veb web framework

## Setup

### Prerequisites

- V compiler
- GitHub Personal Access Token with `read:user` and `repo` permissions

### Environment Variables

```bash
GH_USER=your-github-username
GH_TOKEN=your-github-personal-access-token
DEBUG=false
```

### Installation

```bash
# Clone and build
git clone https://github.com/ktunprasert/v-github-stats
cd v-gh-stats
# If Linux you have to use `-d use_openssl`
v -d use_openssl run .
# Other platforms normal
v run .
```

### Docker

```bash
# Build and run with Docker Compose
docker-compose up --build
```

Or with Docker:

```bash
docker build -t v-gh-stats .
docker run -p 8199:8199 -e GH_USER=username -e GH_TOKEN=token v-gh-stats
```

### Just Commands

```bash
# Available commands
just          # Run in bare-metal
just dev      # Hot reload server
just run      # Run with docker-compose
just build    # Prepares the binary and build the image
just clear    # Clear cached files
```

## Usage

The server runs on port 8199 and accepts the following query parameters:

```
GET /?user=username&num_repos=50&num_languages=10
```

**Parameters:**

- `user` - GitHub username (required)
- `num_repos` - Number of repositories to analyze (default: 50)
- `num_languages` - Number of top languages to display (default: 10)

**Example:**

```
http://localhost:8199/?user=octocat&num_repos=100&num_languages=8
```

## GitHub Token Permissions

Your GitHub Personal Access Token needs:

- `read:user` - Read user profile information
- `repo` - Access repository information

## Caching

- Results are cached in the `public/` directory
- Cache automatically resets every 24 hours
- Cached files are named based on query parameters

## Development

```bash
# Run in debug mode
DEBUG=true v run .

# Or with command line flags
v run . --debug --user=username --token=your-token
```
