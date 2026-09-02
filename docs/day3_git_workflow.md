# Day 3 — Git Workflow

## Analytics Engineering Git Workflow

Typical workflow:

1. Create a feature branch from `main`
2. Make changes
3. Check changes using `git status`
4. Stage changes using `git add`
5. Commit changes using `git commit`
6. Push the feature branch
7. Create a Pull Request
8. Review the changes
9. Merge into `main`
10. Pull the latest `main` locally

## Useful Commands

```bash
git status
git branch
git checkout -b feature/<name>
git add <file>
git commit -m "<message>"
git push origin <branch>
git log --oneline --graph --decorate
git branch -vv


## personal notes:
### A useful distinction
| Screen                                | What you're in | Exit                      |
| ------------------------------------- | -------------- | ------------------------- |
| `(END)`                               | `less` pager   | `q`                       |
| Lots of `~` and editing a Git message | Vim            | `:q` / `:wq`              |
| `%` prompt                            | zsh            | You're ready for commands |

