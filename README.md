# APM RaidList

Raid roster reporting for the moments when "just eyeball it" has already failed.

`APM RaidList` does one job and does it cleanly:

- prints class counts for your current party or raid
- prints a grouped member list by class
- keeps the output in chat where you can copy, read, and move on

## Install

1. Drop the `apm-raidlist` folder into your AAClassic `Addon` directory.
2. Make sure the addon is enabled in game.
3. Type `!raidclasses` or `!raidlist` in chat.

## Quick Start

1. Join or form a party or raid.
2. Type `!raidclasses` to get a quick class summary.
3. Type `!raidlist` to print the grouped member names.

If nobody is around, it will tell you that too, which is rude but accurate.

## How To

### Class Summary

Use `!raidclasses` to print a simple class count summary for the current group.

That is the fast answer when you only care about raid composition and not the full attendance sheet.

### Full Raid List

Use `!raidlist` to print members grouped by class.

That output is better when you want to see exactly who is on what and where the gaps are.

### Command Alias

You can also use `!apmraidlist` as an alias.

## Notes

- The addon reads the current live party or raid snapshot when you run the command.
- Output is chat-only on purpose, so it stays lightweight.

## Version

Current version: `1.1.0`
