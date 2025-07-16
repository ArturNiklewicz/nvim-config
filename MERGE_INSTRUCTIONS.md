# Merge Instructions for feat/git branch

Due to your worktree setup, you'll need to merge from a different location. Here are the steps:

## Option 1: Merge via GitHub Web Interface (Easiest)

1. Open the PR: https://github.com/ArturNiklewicz/nvim-config/pull/1
2. Click "Merge pull request" 
3. Choose "Squash and merge"
4. Confirm the merge

## Option 2: Merge from the main worktree

1. Navigate to the main worktree:
   ```bash
   cd /Users/arturniklewicz/Developer/worktrees/nvim/multicursor
   ```

2. Update and merge:
   ```bash
   git pull origin main
   git pull origin feat/git
   git merge feat/git
   git push origin main
   ```

3. Delete the branch:
   ```bash
   git branch -d feat/git
   git push origin --delete feat/git
   ```

## Option 3: Use GitHub CLI from main worktree

1. Navigate to the main worktree:
   ```bash
   cd /Users/arturniklewicz/Developer/worktrees/nvim/multicursor
   ```

2. Merge the PR:
   ```bash
   gh pr merge 1 --squash --delete-branch
   ```

## What's Being Merged

Your feat/git branch contains:
- Complete keybinding overhaul with new structure
- Single-key leaders for frequent operations
- Semantic grouping of commands
- Which-key integration
- Migration instructions
- Bug fixes for keymap errors

All changes have been properly committed and pushed to the remote repository.