---
description: Sync and push project changes to GitHub
---

This workflow helps you identify the GitHub account linked to the current directory and safely stage, commit, and push your changes to the remote repository.

1. First, verify the current git configuration to identify the linked GitHub account and check the remote repository URL.
```bash
git config user.name
git config user.email
git remote -v
```

2. Check the current git status to see what files are modified, new, or deleted.
```bash
git status
```

3. Review the changes if necessary (e.g., using `git diff`), and then formulate a clear, descriptive commit message summarizing the work completed.

4. Stage all changes, commit with your descriptive message, and push to the remote repository. Modify the commit message in the command below before running.
// turbo
```bash
git add . && git commit -m "Your descriptive commit message" && git push origin HEAD
```
