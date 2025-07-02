git-clean-all() {
  local base_dir="${1:-$HOME/Repositories}"
  local repos
  repos=($(find "$base_dir" -type d -name ".git" -prune | xargs -n1 dirname))
  for repo in "${repos[@]}"; do
    echo "📁 Repository: $repo"
    cd "$repo" || continue
    echo "🔄 Fetching and pruning remotes..."
    git fetch --all --prune

    # Verifica se há commits no repositório
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
      current_branch=$(git rev-parse --abbrev-ref HEAD)
    else
      current_branch="(no commits yet)"
      echo "🚫 Repository '$repo' does not have any commits yet. Skipping branch cleanup. ⏭️"
      echo "-----------------------------------------------"
      continue
    fi

    # Avisar sobre alterações não comitadas/adicionadas, mostrando a branch atual
    if [[ -n $(git status --porcelain) ]]; then
      echo "⚠️  Uncommitted changes detected in $repo on branch '$current_branch'. Attempting to continue anyway... 🛠️"
    fi

    # Tenta sempre ficar em develop ou main
    echo "🔀 Switching to 'develop' or 'main' branch if possible..."
    git checkout develop 2>/dev/null || git checkout main 2>/dev/null

    local branches=()
    while IFS= read -r branch; do
      clean_branch="$(echo "$branch" | sed 's/^\* //;s/^[[:space:]]*//;s/[[:space:]]*$//')"
      if [[ -n "$clean_branch" && "$clean_branch" != "*" ]]; then
        branches+=("$clean_branch")
      fi
    done < <(git branch -vv | awk '/: gone]/{print $1}')

    if [[ ${#branches[@]} -eq 0 ]]; then
      echo "✨ No orphan branches found. 🍃"
    else
      echo "🗑️  Orphan branches to delete:"
      for branch in "${branches[@]}"; do
        if [[ "$branch" != "$(git rev-parse --abbrev-ref HEAD)" ]]; then
          if git branch -d "$branch"; then
            echo "  ✔️ Deleted: $branch 🧹"
          else
            echo "  ❌ Could not delete: $branch (it may have unmerged work) 🚫"
          fi
        else
          echo "  ⏭️  Skipping current branch: $branch 🚦"
        fi
      done
    fi
    echo "-----------------------------------------------"
  done
  cd ~
  echo "✅ All repositories processed! 🎉"
}