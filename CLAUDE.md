Panboticon is a command-line tool organized into subcommands. It runs on its user's local machine and manages EC2 instances where they can safely run AI agents.

The main entrypoint is `bin/panboticon`. It dispatches to subcommands in `libexec/panboticon`. Reusable files and functions are defined in `lib/panboticon`.

Panboticon is implemented in POSIX shell. Use my rules for shell programs from `~/.claude/CLAUDE.md`.
